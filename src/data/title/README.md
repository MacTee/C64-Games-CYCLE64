# Supplied CYCLE 64 title assets

The seven `.bin` files in this folder were supplied in
`_docs/cycle64_split_title_assets.zip` and extracted unchanged. The supplied
320×200 preview is the visual reference; original asset provenance is to be
completed by the entrant in AI_USAGE.md.

Runtime layout and raster code are in `src/main.asm` and `src/title.asm`:

- Text matrix `$8000`, bitmap matrix `$8400`, charset `$8800`.
- Common color RAM source `$9000`, copied to `$d800` on title entry.
- Bitmap `$a000` (VIC bank 2; CPU BASIC ROM may remain visible).
- Outline sprite `$bf40` / pointer `$fd`; yellow sprite `$bf80` / pointer `$fe`.
- Sprite 0 yellow is in front of sprite 1 black. Both are hires, expanded 2× on
  each axis, at VIC coordinate (160,174), corresponding to preview (136,124).
- Character rows 0–7, bitmap rows 8–21, character rows 22–24.

The final PAL VICE screenshot matched all 64,000 reference pixels after RGB
palette normalization. No generator/interpreter is needed to build these assets.
