/// <reference types="vite/client" />
interface ImportMetaEnv {
  readonly VITE_GAME_VERSION: string;
  readonly VITE_GAME_COMMIT: string;
  readonly VITE_HOST_URL: string;
  readonly VITE_OG_DESCRIPTION: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
