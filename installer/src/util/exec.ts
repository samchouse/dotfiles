export class NullStream implements Deno.Writer {
  public write = (data: Uint8Array) => {
    return Promise.resolve(data.byteLength);
  };
}
