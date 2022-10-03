import { config, Instructions, Logger } from "../util/mod.ts";

export const runCopierTasks = async () => {
  Logger.info("Running all custom command tasks");

  for await (const cc of config.customCommands) {
    const instructions = new Instructions();

    instructions.add(...cc.commands);

    await instructions.execute();

    Logger.success(
      `Ran ${cc.name} commands`,
    );
  }

  Logger.info("Finished running all custom command tasks");
};
