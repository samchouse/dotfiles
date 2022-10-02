import { configSchema } from "../schemas/mod.ts";
import rawConfig from "../../config.json" assert { type: "json" };

export const config = configSchema.parse(rawConfig);
