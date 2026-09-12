from collections import defaultdict
from datetime import datetime
from typing import Annotated, Literal, cast
from zoneinfo import ZoneInfo

import requests
from fastapi import Depends, FastAPI, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

session = requests.Session()
session.mount(
    "https://",
    HTTPAdapter(
        max_retries=Retry(
            total=3, backoff_factor=1, status_forcelist=[429, 500, 502, 503, 504]
        )
    ),
)
session.headers.update(
    {"Accept": "application/json", "Content-Type": "application/json"}
)


def mdblist_post(api_key: str, path: str, json: dict[str, object]) -> dict[str, object]:
    resp = session.post(
        f"https://api.mdblist.com{path}",
        params={"apikey": api_key},
        json=json,  # pyright: ignore[reportArgumentType]
    )
    resp.raise_for_status()
    if resp.content:
        data: object = resp.json()  # pyright: ignore[reportAny]
        if isinstance(data, dict):
            d = cast(dict[object, object], data)
            return {str(k): v for k, v in d.items()}
    return {}


class Item(BaseModel):
    id: str
    type: Literal["movie", "show", "episode"]
    rating: str | None = None
    watched_at: datetime | None = None
    season: int = 0
    episode: int = 0

    @property
    def score(self) -> int | None:
        if self.rating is None:
            return None
        return int(
            float(self.rating.encode("ascii", "ignore").decode("ascii").strip()) * 2
        )

    @property
    def timestamp(self) -> str | None:
        return (
            self.watched_at.astimezone(ZoneInfo("America/New_York")).isoformat()
            if self.watched_at
            else None
        )


class WebhookPayload(BaseModel):
    items: list[Item]


def flatten_episodes(
    grouped: dict[str, defaultdict[int, list[dict[str, object]]]],
) -> list[dict[str, object]]:
    return [
        {
            "ids": {"tmdb": show_id},
            "seasons": [
                {"number": season, "episodes": episodes}
                for season, episodes in seasons.items()
            ],
        }
        for show_id, seasons in grouped.items()
    ]


security = HTTPBearer()
app = FastAPI()


@app.post("/")
def webhook(
    payload: WebhookPayload,
    auth: Annotated[HTTPAuthorizationCredentials, Depends(security)],
) -> dict[str, object]:
    api_key = auth.credentials
    watchlist_movies: list[dict[str, object]] = []
    watchlist_shows: list[dict[str, object]] = []
    watched_movies: list[dict[str, object]] = []
    rating_movies: list[dict[str, object]] = []
    rating_shows: list[dict[str, object]] = []

    episode_watches: defaultdict[str, defaultdict[int, list[dict[str, object]]]] = (
        defaultdict(lambda: defaultdict(list))
    )
    episode_ratings: defaultdict[str, defaultdict[int, list[dict[str, object]]]] = (
        defaultdict(lambda: defaultdict(list))
    )

    episode_show_ids = {i.id for i in payload.items if i.type == "episode"}

    for item in payload.items:
        tmdb_ids = {"tmdb": item.id}

        if item.type == "movie":
            if item.timestamp:
                watched_movies.append({"ids": tmdb_ids, "watched_at": item.timestamp})
            else:
                watchlist_movies.append({"ids": tmdb_ids})
            if item.score is not None:
                rating_movies.append({"ids": tmdb_ids, "rating": item.score})

        elif item.type == "show":
            if item.id not in episode_show_ids:
                watchlist_shows.append({"ids": tmdb_ids})
            if item.score is not None:
                rating_shows.append({"ids": tmdb_ids, "rating": item.score})

        elif item.type == "episode":
            if item.timestamp:
                episode_watches[item.id][item.season].append(
                    {"number": item.episode, "watched_at": item.timestamp}
                )
            if item.score is not None:
                episode_ratings[item.id][item.season].append(
                    {"number": item.episode, "rating": item.score}
                )

    sync_tasks = [
        ("watchlist", "/watchlist/items/add", watchlist_movies, watchlist_shows),
        ("watched", "/sync/watched", watched_movies, flatten_episodes(episode_watches)),
        (
            "ratings",
            "/sync/ratings",
            rating_movies,
            rating_shows + flatten_episodes(episode_ratings),
        ),
    ]

    results: dict[str, object] = {}
    try:
        for key, path, movies, shows in sync_tasks:
            if movies or shows:
                results[key] = mdblist_post(
                    api_key, path, {"movies": movies, "shows": shows}
                )
    except requests.HTTPError as e:
        error_msg = e.response.text if e.response is not None else str(e)
        raise HTTPException(
            status_code=502, detail=f"MDBList API error: {error_msg}"
        ) from e

    return results
