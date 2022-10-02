import { cyan, green } from "https://deno.land/std@0.158.0/fmt/colors.ts";

export class Logger {
  public static info(message: string) {
		console.log(`${cyan("[ Info ]")} ${message}`);
	}

  public static success(message: string) {
    console.log(`${green("[ Success ]")} ${message}`);
  }

  public static warn(_message: string) {}

  public static error(_message: string) {}
}
