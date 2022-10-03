import { config } from "./config.ts";

export const exec = async (
  options: Pick<Deno.RunOptions, "cwd" | "cmd" | "env"> & { silent?: boolean },
) => {
  const process = Deno.run({
    ...options,
    ...(options.silent ? { stdout: "null", stderr: "null" } : {}),
  });

  const { code } = await process.status();
  return code;
};

export class Instructions extends Set<string> {
  private static fileName = "instructions.sh";

  public add(...commands: string[]) {
    commands.forEach((command) =>
      super.add(
        command.replace("sudo", `echo ${config.sudoPassword} | sudo -S`),
      )
    );

    return this;
  }

  public execute = async () => {
    await Deno.writeTextFile(
      Instructions.fileName,
      ["#!/usr/bin/env bash", "", ...[...this.values()], ""].join("\n"),
      {
        mode: 0o755,
      },
    );

    await exec({
      silent: true,
      cmd: [`./${Instructions.fileName}`],
    });

    await Deno.remove(Instructions.fileName);
  };
}
