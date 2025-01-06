{ pkgs, ... }:
{
  services.glance = {
    enable = true;
    package = (
      pkgs.glance.overrideAttrs (oldAttrs: rec {
        version = "latest";
        src = (
          pkgs.fetchFromGitHub {
            owner = "glanceapp";
            repo = "glance";
            rev = "e524dd111e014dda9c38d388732e8b73823a4879";
            hash = "sha256-Wn9TL6Eu8r59G6LoBuP33aMcFdlefDRdZFJ5OCC6zAk=";
          }
        );

        vendorHash = "sha256-6lYlfiUJpXANv9D7Ssc0yZ2iCz1VwrOzw8rhMo4HgkQ=";
      })
    );

    settings = {
      server = {
        host = "0.0.0.0";
        port = 8090;
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                }
                {
                  type = "group";
                  widgets = [
                    {
                      title = "ace";
                      type = "repository";
                      repository = "samchouse/ace";
                      token = "\${GLANCE_GH_TOKEN}";
                    }
                    {
                      title = "adrastos";
                      type = "repository";
                      repository = "samchouse/adrastos";
                      token = "\${GLANCE_GH_TOKEN}";
                    }
                  ];
                }
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "SPY";
                      name = "S&P 500";
                    }
                    {
                      symbol = "NVDA";
                      name = "NVIDIA";
                    }
                    {
                      symbol = "AAPL";
                      name = "Apple";
                    }
                    {
                      symbol = "MSFT";
                      name = "Microsoft";
                    }
                    {
                      symbol = "GOOGL";
                      name = "Google";
                    }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  search-engine = "google";
                  autofocus = true;
                  bangs = [
                    {
                      title = "MyNixOS";
                      shortcut = "!n";
                      url = "https://mynixos.com/search?q={QUERY}";
                    }
                  ];
                }
                {
                  type = "hacker-news";
                }
                {
                  type = "reddit";
                  subreddit = "unixporn";
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = "Montreal, Canada";
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Services";
                  sites = [
                    {
                      title = "Open WebUI";
                      url = "https://ai.xenfo.dev";
                      icon = "si:openai";
                    }
                  ];
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "General";
                      links = [
                        {
                          title = "Home Assistant";
                          url = "https://ha.xenfo.dev";
                        }
                        {
                          title = "Tailscale";
                          url = "https://login.tailscale.com/admin/machines";
                        }
                      ];
                    }
                    {
                      title = "AI";
                      links = [
                        {
                          title = "OpenAI";
                          url = "https://platform.openai.com/usage";
                        }
                        {
                          title = "Anthropic";
                          url = "https://console.anthropic.com/settings/usage";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
