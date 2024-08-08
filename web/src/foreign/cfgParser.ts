export interface IniFileSection {
  [key: string]: parsedValue;
}

export interface IniFileContent {
  game_settings: IniFileSection;
  user_settings: IniFileSection;
}

export async function parseGodotSettings(
  content: string,
): Promise<IniFileContent> {
  const result: IniFileContent = {
    game_settings: {},
    user_settings: {},
  };
  const lines = content.split("\n");
  let currentSection: keyof IniFileContent;

  lines.forEach((line) => {
    line = line.trim();
    if (!line || line.startsWith("#")) return; // Skip empty lines and comments

    if (line.startsWith("[") && line.endsWith("]")) {
      // Section header
      currentSection = line.slice(1, -1) as keyof IniFileContent;
    } else if (currentSection && result[currentSection]) {
      // Key-value pair
      const [key, value] = line.split("=");
      result[currentSection][key.trim()] = parseValue(value.trim());
    }
  });

  return result;
}

export type parsedValue = string | number | boolean;

export function parseValue(value: string): parsedValue {
  // Attempt to parse boolean values
  if (value.toLowerCase() === "true") {
    return true;
  } else if (value.toLowerCase() === "false") {
    return false;
  }
  // Attempt to parse numeric values
  const numericValue = Number(value);
  if (!Number.isNaN(numericValue)) {
    return numericValue;
  }
  return value;
}
