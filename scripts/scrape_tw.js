// https://tailwindcss.com/docs/customizing-colors

const colors = {};
function hexToRgbNormalized(hex) {
  // Ensure the input starts with a #
  if (!/^#/.test(hex)) {
    throw new Error("Invalid hex color format. Expected starting with #.");
  }

  // Remove the leading #
  hex = hex.slice(1);

  // Check if the length is 3 (short version of hex)
  if (hex.length === 3) {
    hex = hex
      .split("")
      .map((char) => char + char)
      .join("");
  }

  // Extract red, green, and blue components
  let r = parseInt(hex.slice(0, 2), 16) / 255;
  let g = parseInt(hex.slice(2, 4), 16) / 255;
  let b = parseInt(hex.slice(4, 6), 16) / 255;

  // Round each component to 3 decimal places
  r = parseFloat(r.toFixed(3));
  g = parseFloat(g.toFixed(3));
  b = parseFloat(b.toFixed(3));

  return [ r, g, b ];
}
for (const row of document.querySelector(".grid").children) {
  const hue = row.firstChild.innerText.toLowerCase();
  const shades = {};
  for (const col of row.querySelector(".grid").children) {
    const [_, shade, hex] = col.innerText
      .toLowerCase()
      .replace(/\s/g, "")
      .match(/([0-9]{2,3}).*(#[a-z0-9]{6})/);
    shades["_" + shade] = hexToRgbNormalized(hex);
  }
  colors[hue] = shades;
}
console.log(colors);
copy(JSON.stringify(colors, null, 2));
