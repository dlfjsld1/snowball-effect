# Stage World and Scale Shift Runtime Specification

Status: S5-G4 IMPLEMENTATION BASELINE
Owner: Presentation
Integration handoff: S5-G4I

## Stage World Set

The three backgrounds are full-canvas `1600x900` pixel scenes rendered behind the existing `StageWorld` mount. The opaque central Play Field remains above them, so the environments primarily appear outside the moving cabinet wings.

| Stage | Static identity | Dynamic layer |
|---|---|---|
| Ground | dark winter sky, snow banks, distributed conifers | 48 downward snow particles |
| Planetary | Earth horizon aligned to the Ground side banks, Mercury, Moon, Mars, Sun | 28 restrained star twinkles |
| Galactic | separated violet spiral galaxy and teal nebula, no gold cluster | 44 cyan/violet star twinkles |

Runtime PNGs use nearest filtering, approved Stage palettes, opaque pixels, and a `2x2` authoring grid. Background contrast stays below the Ball, Paddle, Frame, and functional CRT readouts.

## Scale Shift Rhythm

Duration seed: `0.9s`.

1. cyan/green cabinet charge flash and `SCALE SHIFT` label;
2. current and target Stage World crossfade;
3. central bezel and both 200px wings move outward together around center `x=800`;
4. HUD and Pause controls follow the visual wing positions;
5. overlay fades;
6. Presentation emits `stage_shift_presentation_finished(shift_id)` once;
7. Integration accepts the matching ID and only then activates the next Stage.

The animation never writes Stage score, timer, spawn rate, simulation arrays, or Stage state. Duplicate IDs do not replay, and a Stage reset cancels the active visual transition without emitting its stale completion.

## Deferred Visual Improvements

The following are documented in [`TODOS.md`](TODOS.md) and intentionally excluded from this baseline:

- making the open Cashout direction clearer through an open lower bezel, suction flow, or downward sliding arrows;
- adding phosphor emission, rare sync jitter, and restrained static to make the CRTs feel powered rather than illustrated.

## Evidence

- [`mockups/drafts/frame-paper8-stage-world-preview.png`](mockups/drafts/frame-paper8-stage-world-preview.png)
- [`mockups/drafts/frame-paper8-scale-shift-preview.png`](mockups/drafts/frame-paper8-scale-shift-preview.png)
- `tests/presentation/s5_g4_stage_world_shift_verification.tscn`
- `tests/integration/s5_g4_shift_presentation_wiring_verification.tscn`
- `tools/presentation/stage_world/verify_stage_world_backgrounds.ps1`
