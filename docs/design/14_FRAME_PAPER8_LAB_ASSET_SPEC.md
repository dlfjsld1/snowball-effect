# Paper-8 Laboratory Frame Asset Specification

## Approved Runtime Direction

The approved full-frame concept at `mockups/drafts/frame-paper8-steampunk-lab-v1.png` is the visual reference for silhouette, material, palette, and detail density. It is not a crop sheet.

Runtime v2 is rebuilt from nine independently designed components. No visible component is cut from the full-frame image, and empty space is not filled with repeated ornament fragments.

1. one continuous central playfield bezel;
2. one continuous left machine chassis;
3. one continuous right machine chassis;
4. six purpose-built CRT modules for Stage, Time, Genealogy, Stage Score, Current Item, and Pause/Retry.

The previous `paper8_lab_v1` crop-derived kit remains only as rollback and process history. `paper8_lab_v2` is the active runtime source.

## Palette and Pixel Contract

The only runtime colors are:

`#1f244b`, `#654053`, `#a8605d`, `#d1a67e`, `#f6e79c`, `#b6cf8e`, `#60ae7b`, `#3c6b64`

Every v2 runtime PNG uses binary alpha and an enforced `2x2` authoring grid. Runtime filtering is nearest-neighbor. Components are positioned and sized on integer coordinates.

## Runtime Components

| Component | Size | Role |
|---|---:|---|
| Central bezel | `910x900` | Dynamic-width playfield enclosure |
| Left chassis | `200x900` | Continuous Stage/Time/Genealogy machine body |
| Right chassis | `200x900` | Continuous Score/Item/Pause machine body |
| Stage CRT | `176x108` | Current Stage readout |
| Time CRT | `176x80` | Timer with dedicated analog gauge |
| Genealogy CRT | `176x400` | Five-node, bottom-to-top ball progression |
| Stage Score CRT | `176x112` | Current Stage score only |
| Item CRT | `176x300` | Current item display |
| Pause CRT | `176x104` | Equal Pause and Retry zones |

Authoring chroma sources are archived under `mockups/drafts/paper8_redesign_sources/`. Cleaned high-resolution alpha sources live under `assets/sprites/ui/frame/paper8_lab_v2/source_alpha/`; both directories are excluded from Godot import. Only `paper8_lab_v2/runtime/` is loaded by the game.

## Godot Assembly

- The left and right chassis are single full-height textures. Do not split them into top, waist, bottom, or filler pieces.
- CRTs mount into the chassis recesses at native size. Do not reuse one CRT texture by stretching it into another role.
- The frame is centered at `x=800`. When the Stage profile expands, the bezel and both wings move outward together.
- The outside frame occupies `y=0..900`; there is no top or bottom presentation margin.
- The bezel's transparent opening is the authoritative Play Field: `y=50..850`, with widths `560/720/880/1040` for L0/L1/L2/L3.
- Simulation, Paddle, Backdrop, Spawn, and Cashout use that same Rect. A ball cashes out only after its top pixel has passed `y=850`.

## Runtime Preview

The accepted v2 L0 assembly is captured at [`mockups/drafts/frame-paper8-runtime-preview-v2.png`](mockups/drafts/frame-paper8-runtime-preview-v2.png).

## Validation

- `tools/presentation/frame_asset_kit/verify_paper8_frame_v2.ps1`
- `tests/presentation/s5_g4_paper8_frame_v2_asset_verification.tscn`
- `tests/presentation/s5_g4_frame_kit_verification.tscn`
- `tests/integration/s5_g4_frame_playable_verification.tscn`

S5-G4 remains `IN PROGRESS` until the Stage backgrounds and Scale Shift presentation are complete.
