import { Logger } from "./util/mod.ts";
import {
  runCopierTasks,
  runCustomCommandTasks,
  runGitRepositoriesTasks,
  runPackageManagerTasks,
} from "./tasks/mod.ts";

Logger.info("Loaded config");

await runPackageManagerTasks();
await runGitRepositoriesTasks();
await runCustomCommandTasks();
await runCopierTasks();

Logger.success("Finished installing");
