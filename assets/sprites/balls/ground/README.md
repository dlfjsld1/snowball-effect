# Ground Ball Runtime Assets

Production sprites for Ground `Lv0–Lv4`, drawn directly at the Stage-local runtime diameters `8/16/32/64/128px`.

- Runtime metadata: [`manifest.json`](manifest.json)
- Deterministic source: `res://tools/presentation/ground_ball_assets/generate_ground_ball_assets.gd`
- Runtime binding: each Ground `BallDefinition.texture` is consumed by the existing global-level `MultiMeshInstance2D` batch.
- Anchor: centered (`0.5, 0.5`); the quad remains `2×2` world units and runtime radius still supplies the transform scale.
- Sampling: inherited nearest filtering on `BallRenderer`; mipmaps are disabled by the Godot PNG import.
- Alpha: only `0` or `255`; transparent pixels are clear black and contain no matte fringe.
- Palette: fixed family palette in the manifest; every sprite uses a subset and at most nine opaque colors.
- Source policy: no ImageGen output or concept-board crop is used. The reviewed concept board informed mass, frozen-rim, facet, and crater motifs only.

The Giant Snowball intentionally uses angular compressed slabs without circular craters. The Moon uses broad stepped crater rings as its unique celestial cue. Physics, collision diameter, mass, score, and Merge data are unchanged.

Planetary and Galactic families are separate native-grid handoffs. Their shared-boundary symbolic LODs do not replace or resize these Ground masters.
