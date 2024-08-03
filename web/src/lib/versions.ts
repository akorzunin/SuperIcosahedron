interface GameVersion {
  version: string;
  commit: string;
}

export async function getGameVersionInfo(): Promise<GameVersion> {
  const req = await fetch("/download/latest_version.json");
  if (!req.ok) {
    return {
      version: import.meta.env.VITE_GAME_VERSION ?? "v0.0.0",
      commit: import.meta.env.VITE_GAME_COMMIT ?? "devbld01",
    };
  }
  const data = (await req.json()) as GameVersion;
  return data;
}
