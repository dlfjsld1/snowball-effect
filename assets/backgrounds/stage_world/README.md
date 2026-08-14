# Stage World Backgrounds

S5-G4 production background set.

- `source/`: ImageGen source renders, excluded from Godot import.
- `runtime/`: palette-clean `1600x900` PNGs with an enforced `2x2` authoring grid.
- `manifest.json`: per-Stage palette and validation metadata.

Runtime order:

1. `ground`: snow banks, conifers, dynamic snowfall.
2. `planetary`: aligned Earth horizon, Mercury/Moon/Mars/Sun, dynamic star twinkle.
3. `galactic`: separated spiral galaxy and teal nebula, denser dynamic star twinkle.

Rebuild with `tools/presentation/stage_world/finalize_stage_world_backgrounds.ps1` and verify with `verify_stage_world_backgrounds.ps1`.
