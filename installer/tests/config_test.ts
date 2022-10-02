import { assertInstanceOf } from "https://deno.land/std@0.158.0/testing/asserts.ts";

import { configSchema } from "../src/schemas/mod.ts";
import exampleConfig from "../config.example.json" assert { type: "json" };

Deno.test("example config test", () => {
  const parsedConfig = configSchema.parse(exampleConfig);
  assertInstanceOf(parsedConfig, Object);
});
