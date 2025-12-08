import GLib from "gi://GLib?version=2.0";
import { readFile, writeFile } from "ags/file";
import { type Accessor, createState } from "gnim";

export function clsx(...classes: (string | boolean)[]) {
  const finalClasses = [];
  for (const cssClass of classes) {
    if (!!cssClass && typeof cssClass === "string") finalClasses.push(cssClass);
  }
  return finalClasses.join(" ");
}

interface Config {
  version: Accessor<number>;

  pinnedTray: Set<string>;

  write: () => void;
}

export function readConfig(): Config {
  const path = `${GLib.get_user_config_dir()}/dev.chouse.shell.json`;

  let contents = "";
  try {
    contents = readFile(path);
  } catch (_) {
    contents = "{}";
  }
  const rawConfig = JSON.parse(contents);

  const [version, setVersion] = createState(0);

  return {
    version,

    pinnedTray: new Set(rawConfig.pinnedTray ?? []),

    write() {
      writeFile(
        path,
        JSON.stringify({ ...this, pinnedTray: [...this.pinnedTray] }),
      );
      setVersion((v) => v + 1);
    },
  };
}
