import { persistentAtom } from "@nanostores/persistent";

export type Theme = "dark" | "light" | "system";

export const themeAtom = persistentAtom<Theme>("vite-ui-theme", "system");
