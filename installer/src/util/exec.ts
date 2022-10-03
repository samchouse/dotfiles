export const exec = async (
  options: Pick<Deno.RunOptions, "cwd" | "cmd" | "env"> & { silent?: boolean },
) => {
  const process = Deno.run({
    ...options,
    ...(options.silent ? { stdout: "null", stderr: "null" } : {}),
  });

  const { code } = await process.status();
  return code;
};