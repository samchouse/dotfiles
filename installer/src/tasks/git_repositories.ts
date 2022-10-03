import { config, exec, Logger } from "../util/mod.ts";

const pathWithGhCli = `${
  Deno.env.get("PATH") ?? ""
}:/home/linuxbrew/.linuxbrew/bin`;

export const runGitRepositoriesTasks = async () => {
  Logger.info("Running Git repository tasks");

  const gitProjects = config.git.projects.reduce(
    (
      acc,
      project,
    ) => [
      ...acc,
      ...project.repositories.map((repo) => {
        const cwd = project.cwd.replace(
          "~",
          Deno.env.get("HOME") ?? "",
        );

        return typeof repo === "string"
          ? ({ cwd, name: repo })
          : ({ cwd, ...repo });
      }),
    ],
    [] as { cwd: string; name: string; folder?: string }[],
  );

  await exec({
    cmd: [
      "gh",
      "auth",
      "login",
      "-w",
      "-p",
      "https",
    ],
    env: {
      PATH: pathWithGhCli,
    },
  });

  for await (const configKey of Object.keys(config.git.config)) {
    await exec({
      cmd: [
        "git",
        "config",
        "--global",
        configKey,
        config.git.config[configKey],
      ],
    });
  }

  for await (const project of gitProjects) {
    const stat = await Deno.stat(project.cwd).catch(() => undefined);
    if (!stat) {
      await Deno.mkdir(project.cwd, { recursive: true });
    }

    await exec({
      silent: true,
      cwd: project.cwd,
      cmd: [
        "gh",
        "repo",
        "clone",
        project.name,
        ...(project.folder ? [project.folder] : []),
      ],
      env: {
        PATH: pathWithGhCli,
      },
    });
    Logger.info(
      `Cloned ${project.name}${
        project.folder
          ? ` into ${
            project.cwd.replace(Deno.env.get("HOME") ?? "", "~")
          }/${project.folder}`
          : ""
      }`,
    );
  }

  Logger.info("Finished running Git repository tasks");
};
