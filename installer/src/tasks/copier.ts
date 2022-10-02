import * as fs from "https://deno.land/std@0.158.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.158.0/path/mod.ts";

import { config, Logger } from "../util/mod.ts";

export const runCopierTasks = async () => {
  for await (const entry of Deno.readDir(config.copier.configDir)) {
    await fs.copy(
      `${config.copier.configDir}/${entry.name}`,
      path.join(
        Deno.env.get("HOME") ?? "",
        entry.name,
      ),
    );
  }

  Logger.success("Moved all configs into place");
};
