import { exec } from "https://deno.land/x/denoexec@v1.1.5/mod.ts";

import { config } from "../config.ts";
import { Logger } from "../logger.ts";

export const runGitRepositoriesTasks = () => {
  config.gitProjects.map((gitProjects) => {
    const cwd = gitProjects.cwd.replace("~", Deno.env.get("HOME") ?? "");

    gitProjects.repositories.map(async (repository) => {
      const repositoryName = typeof repository === "string"
        ? repository
        : repository.name;
      const repositoryFolder = typeof repository === "string"
        ? undefined
        : repository.folder;

      const stat = await Deno.stat(cwd).catch(() => undefined);
      if (!stat) {
        await Deno.mkdir(cwd, { recursive: true });
      }

      await exec({
        cmd: [
          "gh",
          "auth",
          "login"
        ],
      });

      await exec({
        cwd,
        cmd: [
          "gh",
          "repo",
          "clone",
          repositoryName,
          ...(repositoryFolder ? [repositoryFolder] : []),
        ],
      });
      Logger.info(
        `Cloned ${repositoryName}${
          repositoryFolder ? ` into ${repositoryFolder}` : ""
        }`,
      );
    });
  });
};
