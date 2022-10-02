import {
  cyan,
  green,
  red,
  yellow,
} from "https://deno.land/std@0.158.0/fmt/colors.ts";

export class Logger {
  public static info(message: string) {
    console.log(`${cyan("[ Info ]")} ${message}`);
  }

  public static success(message: string) {
    console.log(`${green("[ Success ]")} ${message}`);
  }

  public static warn(message: string) {
    console.log(`${yellow("[ Warning ]")} ${message}`);
  }

  public static error(message: string) {
    console.log(`${red("[ Error ]")} ${message}`);
  }
}
