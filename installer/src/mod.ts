import { Logger } from "./util/mod.ts";
import {
  runGitRepositoriesTasks,
  runPackageManagerTasks,
  runCopierTasks,
} from "./tasks/mod.ts";

Logger.info("Loaded config");

await runPackageManagerTasks();
await runGitRepositoriesTasks();
await runCopierTasks();

Logger.success("Finished installing");
