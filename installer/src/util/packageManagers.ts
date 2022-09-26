import { exec } from "https://deno.land/x/denoexec@v1.1.5/mod.ts";

import { config } from "../config.ts";
import { Logger } from "../logger.ts";

const instructionsFile = "instructions.sh";

const createInstructionsFile = async (instructions: string[]) => {
  await Deno.writeTextFile(
    instructionsFile,
    ["#!/usr/bin/env bash", "", ...instructions, ""].join("\n"),
    {
      mode: 0o755,
    },
  );
};

export const runPackageManagerTasks = async () => {
  for await (const pm of config.packageManagers) {
    const instructions: string[] = [];

    if ((pm.preInstall?.length ?? 0) > 0) {
      instructions.push(...(pm.preInstall ?? []));

      // Logger.success(
      //   `Ran pre install commands for ${pm.name}`,
      // );
    }

    instructions.push(
      [
        ...(pm.needsSudo
          ? ["echo", config.sudoPassword, "|", "sudo", "-S"]
          : []),
        pm.command,
        ...pm.args,
        ...pm.packages,
      ].join(" "),
    );
    // Logger.success(
    //   `Installed ${pm.name} packages`,
    // );

    if ((pm.postInstall?.length ?? 0) > 0) {
      instructions.push(...(pm.postInstall ?? []));

      // Logger.success(
      //   `Ran pre install commands for ${pm.name}`,
      // );
    }

    await createInstructionsFile(instructions);
    await exec({ cmd: [`./${instructionsFile}`] });
    Logger.success(
      `Installed ${pm.name} packages`,
    );
  }

  await Deno.remove(instructionsFile);
};
