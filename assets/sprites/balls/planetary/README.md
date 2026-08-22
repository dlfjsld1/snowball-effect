# Planetary Ball Runtime Assets

Production sprites for the Planetary ordered chain `[4, 5, 6, 8, 10]`, authored directly at Stage-local runtime diameters `8/16/32/64/128px`.

- Runtime metadata: [`manifest.json`](manifest.json)
- Deterministic source: `res://tools/presentation/planetary_ball_assets/generate_planetary_ball_assets.py`
- Runtime binding: `BallTextureLodCatalog` selects this family's exact `8/16/32/64/128px` masters for global `4/5/6/8/10` before falling back to the Content-owned `BallDefinition.texture`. This corrects visual selection without rewriting Content data.
- Anchor: centered (`0.5, 0.5`); the reusable MultiMesh quad stays `2×2` world units and runtime radius remains the only transform scale.
- Sampling: nearest filtering on `BallRenderer`; mipmaps must remain disabled by Godot PNG import.
- Alpha: only `0` or `255`; transparent pixels are clear black with no matte fringe.
- Source policy: no ImageGen output, resized Ground sprite, antialiasing, blur, or filtered intermediate is used.

The ordered visual chain is `Moon → Earth → Sun → Supernova → Galaxy`. The `8×8px` Moon is a separately authored symbol rather than a reduction of the Ground `128×128px` hero Moon; Earth has stepped continents and ice, Sun has a compact angular corona, Supernova condenses its approved CUT-IN's white-gold rupture and warm-violet orbit ribbons, and Galaxy condenses its approved CUT-IN's folded violet body and cyan-gold ribbon lanes. The CUT-IN portraits remain the canonical, byte-identical approved artwork and are never regenerated from gameplay sprites.

This Presentation handoff changes texture selection only. Existing score, mass, FX tier, Merge/Cashout rules, FIRST_CONTACT identity, collision radius, and Stage progression remain authoritative and unchanged. Galactic now supplies a separately authored `8×8px` Galaxy through the same exact-size catalog; this Planetary `128×128px` hero and its primary binding remain unchanged.
