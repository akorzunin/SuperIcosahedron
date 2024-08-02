interface GameVarsion {
  VERSION: string;
  COMMIT: string;
}

export async function getGameVersionInfo() {
  const req = await fetch("/download/latest_version.json");
  const data = (await req.json()) as GameVarsion;

  return {
    version: data.VERSION,
    commit: data.COMMIT,
  };
}
