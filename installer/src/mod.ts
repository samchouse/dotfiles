import { Logger } from "./util/mod.ts";
import {
  runCopierTasks,
  runGitRepositoriesTasks,
  runPackageManagerTasks,
  runCustomCommandTasks,
} from "./tasks/mod.ts";

Logger.info("Loaded config");

await runPackageManagerTasks();
await runGitRepositoriesTasks();
await runCustomCommandTasks();
await runCopierTasks();

Logger.success("Finished installing");
