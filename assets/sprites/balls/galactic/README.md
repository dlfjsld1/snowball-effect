# Galactic Ball Runtime Assets

Production sprites for the Galactic ordered chain `[10, 11, 12, 13, 14]`, authored directly at Stage-local runtime diameters `8/16/32/64/128px`.

- Asset-family metadata: [`manifest.json`](manifest.json)
- Source metadata: [`manifest.json`](manifest.json) records the mixed hand-authored and approved user-selected sources.
- Runtime binding: the Presentation-owned `BallTextureLodCatalog` resolves the approved exact-size gameplay resource for each Stage-local entry. The selected Galaxy Cluster keeps the manifest's existing Lv11 `16×16` path; only the BALLS CRT uses its separate `24×24` icon. Existing global-level MultiMesh batches consume Lv0–Lv3; the Lv4 hero remains an exact-size Black Hole creation/CUT-IN handoff while the dedicated final-phase renderer and gameplay entity stay unchanged.
- Anchor: centered (`0.5, 0.5`); runtime radius remains the transform and collision source of truth.
- Sampling: nearest filtering on `BallRenderer`; mipmaps must remain disabled by Godot PNG import.
- Alpha: the selected Galaxy, Galaxy Cluster, Event Horizon and Black Hole use smooth RGBA edges; unchanged native-grid family assets retain binary alpha. Fully transparent pixels contain no matte RGB fringe.
- Source policy: Galactic local Lv0 intentionally downsamples the approved Grand Spiral `128×128` preview to its exact `8×8` gameplay diameter using Lanczos filtering. Event Horizon and Black Hole keep their previously approved native `64×64` Last Light and `128×128` Void Cathedral runtime assets unchanged. The selected Galaxy Cluster uses the approved TRI-SPIRAL CORE `16×16` gameplay adaptation and its separately authored `24×24` CRT genealogy icon; the remaining family assets retain their existing native-grid sources.

The `8×8px` Galactic Galaxy preserves the approved Grand Spiral's blue-violet arms and warm core. The BALLS CRT still uses the previous-stage Planetary final Galaxy resource under the approved carryover rule. Galaxy Cluster is the approved TRI-SPIRAL CORE with three separated dominant spiral cores; its gameplay sprite remains `16×16` at radius `8`, while only the BALLS CRT uses the dedicated `24×24` icon. Quasar uses a nucleus, accretion disk, and polar jets. Event Horizon now carries Last Light's asymmetric blue/gold rim, while Black Hole carries Void Cathedral's gold-violet equatorial disk and mirrored lens directly from their approved masters.

Black Hole is Galactic local Lv4 and part of the existing Galactic final-phase gimmick. It is not Stage 4 and its creation is not a Stage Clear condition. This Presentation handoff does not change score, mass, FX tier, Merge/Cashout rules, FIRST_CONTACT identity, collision radius, Stage progression, Black Hole footprint, force, conversion, or finale mechanics.
