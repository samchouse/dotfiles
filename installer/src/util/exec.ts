export const exec = async (
  options: Pick<Deno.RunOptions, "cwd" | "cmd" | "env"> & { silent?: boolean },
) => {
  const procOptions: Deno.RunOptions = {
    ...options,
    ...(options.silent ? { stdout: "null", stderr: "null" } : {}),
  };

  const process = Deno.run(procOptions);
  return await process.status();
};
