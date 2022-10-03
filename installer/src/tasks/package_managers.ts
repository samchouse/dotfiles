import { config, Instructions, Logger } from "../util/mod.ts";

export const runPackageManagerTasks = async () => {
  Logger.info("Running package manager tasks");

  for await (const pm of config.packageManagers) {
    const instructions = new Instructions();

    if ((pm.preInstall?.length ?? 0) > 0) {
      instructions.add(...(pm.preInstall ?? []));
    }

    if (pm.isSingleCommand) {
      instructions.add(
        [
          pm.command,
          ...pm.args,
          ...pm.packages,
        ].join(" "),
      );
    } else {
      instructions.add(
        ...(pm.packages.map((pkg) => [pm.command, ...pm.args, pkg].join(" "))),
      );
    }

    if ((pm.postInstall?.length ?? 0) > 0) {
      instructions.add(...(pm.postInstall ?? []));
    }

    await instructions.execute();

    Logger.success(
      `Installed ${pm.name} packages`,
    );
  }

  Logger.info("Finished running package manager tasks");
};
