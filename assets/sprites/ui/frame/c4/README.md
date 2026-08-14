# C4 Selective-Waist CRT Frame Kit

Source: approved `godot-crt-frame-kit-20260812` design artifact
Target Goal: S5-G4
Runtime scene: `res://scenes/backgrounds/gameplay_frame.tscn`

## Import contract

- PNG RGBA8, lossless.
- Mipmaps off.
- `GameplayFrame` uses nearest texture filtering.
- `rail_h_24x12.png` is tiled horizontally.
- Housing/CRT/field textures use the NinePatch margins encoded in the Scene.

## Geometry

| Profile | Field width | Rig X | Field X | Right wing X |
|---|---:|---:|---:|---:|
| L0 | 560 | 356 | 520 | 1092 |
| L1 | 720 | 276 | 440 | 1172 |
| L2 | 880 | 196 | 360 | 1252 |
| L3 | 1040 | 116 | 280 | 1332 |

The two wing envelopes remain `152px` wide and move symmetrically around `x=800`. These are approved Presentation geometry values, not authoritative Core collision bounds.

## Palette

- Deepest shadow `#1f244b`
- Old machine dark `#654053`
- Frame mid `#a8605d`
- Lit edge `#d1a67e`
- CRT brightest `#f6e79c`
- CRT bright `#b6cf8e`
- CRT mid `#60ae7b`
- CRT dark `#3c6b64`

Live HUD text and icons must be rendered above the glass layer. They are not baked into these textures.
