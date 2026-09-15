# Plastic Bag Readable

`PlasticBagReadable.otf` is an outline modification of Raymond Larabie's CC0
`Plastic Bag.otf`, not a replacement alphabet. The source remains unchanged.
The derivative is also CC0; see `license.txt`.

Changes:

- Inset the original outlines by up to 10/1000 em, opening counters and slightly
  lightening strokes while retaining the triangular/hexagonal letter shapes.
- Add 60/1000 em of advance, split between left and right side bearings.
- Use Plastic Bag's own slashed-O outline for zero to distinguish it from O.
- Give I and numeral 1 parallel diagonal ends: cut the top from the left and
  bottom from the right, not symmetric bevels. T keeps its bottom-right cut.
  Apply I/T edits to matching lowercase/accented contours too; preserve accents,
  T's crossbar, and each glyph's advance.
- Preserve character mappings, accents, glyph names, and original kerning.
- Protect small punctuation and accents from disappearing during thinning.

The shared theme and 3D menu use `PlasticBagReadable.tres`, which falls back to
Barlow for missing characters. Emoji mode is unchanged. This remains a stylized
all-caps face: spacing/thinning cannot make its deliberately unusual alphabet
as easy to read as a conventional body-text font, especially below 20px.

## Edit and visually verify

```sh
uv run scripts/build_hex_font.py
# Optional tuning, in font units:
uv run scripts/build_hex_font.py --inset 10 --spacing 60
```

The script edits the original CFF contours, preserves straight edges, and
flattens curved symbols to 0.5-unit accuracy before offsetting. It uses nonzero
winding fill and guards against lost components/counters. Build-only dependencies
are pinned in the script; no additional runtime dependency is required.

Open `build/font-preview.png` at native size to compare original and modified
text at 16, 18, 20, 24, 32, and 48px, plus the alphabet, accents, and punctuation.
`build/font-it-preview.png` focuses on I/T in “Tree Tower” and “Isac Ico Item”
at 18–80px, with accented variants alongside numeral 1.
Rerun the default command before committing unless new tuning is intentional.

```sh
go-task test
go-task visual-playtest -- --rendering-method gl_compatibility
uvx prek run --all-files
```

Inspect the generated menu and gameplay contact sheets, not just the script's
state report. The original font remains available for comparison and rebuilding.
