# Stage World Backgrounds

S5-G4 production background set.

- `source/`: ImageGen source renders, excluded from Godot import.
- `runtime/`: palette-clean `1600x900` PNGs with an enforced `2x2` authoring grid.
- `manifest.json`: per-Stage palette and validation metadata.

Runtime order:

1. `ground`: snow banks, conifers, dynamic snowfall.
2. `planetary`: aligned Earth horizon, Mercury/Moon/Mars/Sun, dynamic star twinkle.
3. `galactic`: a fully transparent plate plus independent stars, spiral galaxy, and teal nebula alpha layers. The former opaque Galactic PNG remains only as the S5-G4 migration reference and is not loaded by `BackgroundManager`.

Galactic runtime composition order:

1. `background_galactic_plate_1600x900.png` — fully transparent plate; the project void remains visible.
2. `background_galactic_stars_1600x900.png` — sparse static stars.
3. `background_galactic_galaxy_1600x900.png` — upper-left spiral galaxy.
4. `background_galactic_nebula_1600x900.png` — right-side teal nebula.

The three visual layer sources were extracted with built-in ImageGen from the approved S5-G4 Galactic runtime art, then normalized to the existing Galactic palette, quantized alpha, `1600x900`, and the strict `2x2` authoring grid. Reduced Effects keeps the static identity layers at lower alpha and disables the dynamic ambient twinkle motion.

The S5-G4 opaque baseline can still be rebuilt with `tools/presentation/stage_world/finalize_stage_world_backgrounds.ps1` and verified with `verify_stage_world_backgrounds.ps1`. S5-G7 alpha composition is verified by `tests/presentation/s5_g7_galactic_stage_world_verification.tscn`.
