# Galactic Ball Runtime Assets

Production sprites for the Galactic ordered chain `[10, 11, 12, 13, 14]`, authored directly at Stage-local runtime diameters `8/16/32/64/128px`.

- Runtime metadata: [`manifest.json`](manifest.json)
- Deterministic source: `res://tools/presentation/galactic_ball_assets/generate_galactic_ball_assets.py`
- Runtime binding: the Presentation-owned `BallTextureLodCatalog` resolves all five exact-size masters. Existing global-level MultiMesh batches consume Lv0–Lv3; the Lv4 hero remains an exact-size Black Hole creation/CUT-IN handoff while the dedicated final-phase renderer and gameplay entity stay unchanged.
- Anchor: centered (`0.5, 0.5`); runtime radius remains the transform and collision source of truth.
- Sampling: nearest filtering on `BallRenderer`; mipmaps must remain disabled by Godot PNG import.
- Alpha: only `0` or `255`; transparent pixels are clear black with no matte fringe.
- Source policy: no ImageGen output, resized Planetary Galaxy, antialiasing, blur, filtered intermediate, or procedural upscaling is used.

The `8×8px` Galaxy is a separately authored symbol rather than a reduction of the Planetary `128×128px` Galaxy. Galaxy Cluster is a loose group of compact bodies; Quasar uses a nucleus, accretion disk, and polar jets; Event Horizon and Black Hole use open, broken lensing silhouettes rather than circular containers. All five share a bounded deep-space/cyan/magenta/gold palette and upper-left bright-band motif.

Black Hole is Galactic local Lv4 and part of the existing Galactic final-phase gimmick. It is not Stage 4 and its creation is not a Stage Clear condition. This Presentation handoff does not change score, mass, FX tier, Merge/Cashout rules, FIRST_CONTACT identity, collision radius, Stage progression, Black Hole footprint, force, conversion, or finale mechanics.
