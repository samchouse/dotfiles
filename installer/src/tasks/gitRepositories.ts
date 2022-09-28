import { exec } from "https://deno.land/x/denoexec@v1.1.5/mod.ts";

import { config } from "../config.ts";
import { Logger } from "../logger.ts";

export const runGitRepositoriesTasks = async () => {
  const gitProjects = config.gitProjects.reduce(
    (
      acc,
      project,
    ) => [
      ...acc,
      ...project.repositories.map((repo) => {
        const cwd = project.cwd.replace("~", Deno.env.get("HOME") ?? "");

        return typeof repo === "string"
          ? ({ cwd, name: repo })
          : ({ cwd, ...repo });
      }),
    ],
    [] as { cwd: string; name: string; folder?: string }[],
  );

  for await (const project of gitProjects) {
    const stat = await Deno.stat(project.cwd).catch(() => undefined);
    if (!stat) {
      await Deno.mkdir(project.cwd, { recursive: true });
    }

    await exec({
      cmd: [
        "gh",
        "auth",
        "login",
      ],
    });

    await exec({
      cwd: project.cwd,
      cmd: [
        "gh",
        "repo",
        "clone",
        project.name,
        ...(project.folder ? [project.folder] : []),
      ],
    });
    Logger.info(
      `Cloned ${project.name}${
        project.folder ? ` into ${project.folder}` : ""
      }`,
    );
  }
};
