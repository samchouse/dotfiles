import { Logger } from "./logger.ts";
import { runGitRepositoriesTasks } from "./util/gitRepositories.ts";
import { runPackageManagerTasks } from "./util/packageManagers.ts";

Logger.info("Loaded config");

await runPackageManagerTasks();
// runGitRepositoriesTasks();
