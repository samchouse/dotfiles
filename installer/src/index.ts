import { Logger } from "./logger.ts";
import { runGitRepositoriesTasks } from "./tasks/gitRepositories.ts";
import { runPackageManagerTasks } from "./tasks/packageManagers.ts";

Logger.info("Loaded config");

await runPackageManagerTasks();
await runGitRepositoriesTasks();

Logger.success("Finished installing");
