/// <reference types="vite/client" />
interface ImportMetaEnv {
  readonly VITE_GAME_VERSION: string;
  readonly VITE_GAME_COMMIT: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
