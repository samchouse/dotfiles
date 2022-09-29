import { Logger } from "./util/mod.ts";
import {
  runGitRepositoriesTasks,
  runPackageManagerTasks,
} from "./tasks/mod.ts";

Logger.info("Loaded config");

await runPackageManagerTasks();
await runGitRepositoriesTasks();

Logger.success("Finished installing");
