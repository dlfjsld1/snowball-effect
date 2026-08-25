# Planetary Sun Redesign v1

Status: **CANDIDATE A SELECTED — Corona Crown runtime active**

Target: Stage 2 / Planetary / global Lv6 `Sun` / local Lv2

This package contains exactly three concept candidates. Candidate A `Corona Crown` was selected and its exact `32×32` derivative is wired into the Planetary runtime; B/C remain comparison-only.

## Authoritative target and current context

- `resources/stages/stage_01_planetary.tres` defines the ordered chain `[4, 5, 6, 8, 10]`, so global Lv6 Sun is Planetary local Lv2.
- The Stage-local size contract is `radius = 4 * 2 ^ local_level`, so Sun renders and collides at radius **16** and diameter **32 logical pixels**.
- `scripts/presentation/ball_texture_lod_catalog.gd` resolves global Lv6 at diameter `32` to `assets/sprites/balls/planetary/runtime/ball_planetary_local_lv02_sun_corona_crown_32.tres`.
- `resources/balls/ball_06_gas_giant.tres` is the authoritative global Lv6 data entry (`display_name = "Sun"`, `visual_key = &"sun"`). Its legacy primary texture still points at `ball_lv06_mars_32.png`, but the exact-size LOD above wins on the current Planetary runtime path.
- The legacy filename `resources/balls/ball_07_sun.tres` actually defines catalog-only global Lv7 `Red Giant`; it is not this target.
- The active Planetary chain uses separate approved `8/16/32/64/128px` runtime assets for Moon, Earth, Sun, Supernova and Galaxy.
- Sun is not in the six-entry FIRST CONTACT roster, so there is no dedicated Sun CUT-IN asset or controller binding to update. Planetary FIRST CONTACT remains Supernova and Galaxy only.
- The current Sun sprite reads as a smooth orange striped planet at native size. The three concepts therefore emphasize attached corona/prominence structure and true solar surface cues.

## Three candidates

| Candidate | Concept master | Deterministic 32px preview | Macro-readable distinction |
|---|---|---|---|
| A — Corona Crown | [`candidate-a-corona-crown-master.png`](candidate-a-corona-crown-master.png) | [`candidate-a-corona-crown-preview-32px.png`](candidate-a-corona-crown-preview-32px.png) | Full solar disk with a thick uneven crown of short attached flame tongues, one bold sunspot cluster, and broad convection swirls. Clearest literal Sun silhouette. |
| B — Prominence Arc | [`candidate-b-prominence-arc-master.png`](candidate-b-prominence-arc-master.png) | [`candidate-b-prominence-arc-preview-32px.png`](candidate-b-prominence-arc-preview-32px.png) | Smooth blazing sphere with two enormous reattached prominence loops and a continuous bright limb. Widest and most astrophysical silhouette. |
| C — Granule Heart | [`candidate-c-granule-heart-master.png`](candidate-c-granule-heart-master.png) | [`candidate-c-granule-heart-preview-32px.png`](candidate-c-granule-heart-preview-32px.png) | Near-perfect compact disk with honeycomb convection, a white-hot central belt, exactly three sunspots, and a thin turbulent corona. Strongest graphic surface read. |

Open [`comparison.html`](comparison.html) for each transparent master, the actual `32×32` file at native 1:1, and the same file enlarged 8× with nearest-neighbor rendering on a dark Planetary-style field.

## Master and preview targets

- Concept master canvas: `1254×1254` RGBA.
- Normalized subject long edge: `928px`, or `74.00%` of the master canvas.
- Rationale: the high-resolution non-pixel master preserves appealing plasma structure while the shared 74% footprint gives clean alpha edges, even centering, and at least `163px` master padding on the limiting axis.
- Actual gameplay validation target: `32×32` RGBA, matching runtime diameter `32` / radius `16`.
- Concept art deliberately ignores strict production pixel-grid limits. Candidate A received explicit runtime approval and is bound through a dedicated nearest-filtered `CanvasTexture` without changing gameplay radius or Content data.

## Generation record

- Tool path: built-in `image_gen` only.
- Calls: exactly **three initial generation calls**, one fresh call per candidate.
- References supplied to generation: none. Existing Planetary assets and runtime captures were inspected for lineage/readability only.
- Retry count: A `0`, B `0`, C `0`.
- CLI/API fallback: not used.
- Generation session instruction: `codex_work`, `gpt-5.6-sol`.
- Built-in source outputs:
  - A: `C:\Users\gktjd\.codex-work\generated_images\01a03252-712e-7b03-bbbf-7b277942abe2\exec-1cf9f0e8-658c-4668-828d-6152a451f7e7.png`
  - B: `C:\Users\gktjd\.codex-work\generated_images\01a03252-712e-7b03-bbbf-7b277942abe2\exec-2f0a241a-8893-4faf-ad03-bd007c0faf8c.png`
  - C: `C:\Users\gktjd\.codex-work\generated_images\01a03252-712e-7b03-bbbf-7b277942abe2\exec-3af302ee-7343-4858-821c-ab12aa6c83bd.png`

### Exact prompt — A / Corona Crown

```text
Use case: stylized-concept
Asset type: premium concept master for a very small Stage 2 Planetary gameplay ball
Primary request: Candidate A — “Corona Crown.” Create one isolated spherical Sun whose identity remains immediately unmistakable when deterministically reduced to a 32-pixel gameplay diameter. This is a new standalone concept, not an edit. It must be the clearest literal Sun silhouette of three directions.
Scene/backdrop: genuinely transparent RGBA alpha background only; no visible backdrop, matte, checkerboard, floor, shadow, scenery, stars, or space
Subject: one centered, near-front-facing full solar disk with a compact circular footprint. Surround the disk with a thick uneven crown of many short, bold, ATTACHED solar flame tongues; every tongue grows directly from the limb and remains connected to the sphere, with no detached sparks or orbiting flames. Keep the corona controlled rather than explosive. The surface has a luminous incandescent white-yellow inner disk, saturated gold midtones, broad orange and restrained red-orange edge shadows, 6–9 large readable convection cells, and exactly one bold clustered group of small dark red-brown sunspots. Preserve a distinct golden limb so the sphere does not become featureless white.
Style/medium: beautiful premium stylized game-asset concept; refined painterly 3D illustration with clean graphic macro forms; not pixel art at master resolution; appealing and striking, with literal astronomical solar identity
Composition/framing: single object only, centered on a square canvas, no crop, orthographic icon-like presentation, sphere plus attached crown occupying about 68–72% of the canvas, generous even transparent padding on every side, balanced circular silhouette
Lighting/mood: incandescent and powerful but controlled; maximum local contrast against a dark navy Planetary Play Field; white-hot highlights remain bounded inside visible yellow-gold structure
Color palette: white-hot yellow, saturated gold, orange, restrained red-orange limb shadows; tiny dark red-brown sunspots only; no purple, blue, green, gray, or black body
Materials/textures: stellar plasma and broad solar convection, not rock, lava, glass, cheese, or painted land; crisp macro texture that survives thumbnail reduction
Small-size requirement: at 32 pixels the attached crown must still form several visible radial flame notches, the sunspot cluster must survive as one dark cue, and the disk must retain at least three distinct warm value bands; it must never reduce to a generic yellow/orange dot
Constraints: actual transparent background with clean alpha edges and all four corners fully transparent; exactly one spherical Sun; corona and flames attached to the limb; no text, letters, numbers, face, eyes, mouth, limbs, character, UI, scenery, stars, space background, floor, cast shadow, icon plate, border, logo, watermark, opaque background, checkerboard, planetary land or ocean, rings, satellites, moons, orbiting objects, separate floating flames, disconnected sparks, generic orange ball
Avoid: fireball, explosion, lava planet, flower, sunflower, eye, cheese, fantasy magic orb, gas giant, candy, emoji, photoreal telescope photo, featureless white sphere, excessive bloom, smoke, detached particles
```

### Exact prompt — B / Prominence Arc

```text
Use case: stylized-concept
Asset type: premium concept master for a very small Stage 2 Planetary gameplay ball
Primary request: Candidate B — “Prominence Arc.” Create one isolated spherical Sun whose identity remains immediately unmistakable when deterministically reduced to a 32-pixel gameplay diameter. This is a new standalone concept, not an edit. Make it structurally unlike a short all-around flame crown: the defining silhouette is two enormous, clean solar prominence loops.
Scene/backdrop: genuinely transparent RGBA alpha background only; no visible backdrop, matte, checkerboard, floor, shadow, scenery, stars, or space
Subject: one smooth blazing solar sphere centered in frame. Frame it with exactly two enormous attached looping solar prominences: each loop emerges from the Sun’s limb at one footpoint, arches widely through transparent space, and reconnects to the SAME limb at a second footpoint. Place the two loops on different sides so together they create a broad, asymmetric horizontal/diagonal silhouette while staying attached at both ends; they are plasma arches, not rings and not separate orbiting flames. Keep the rest of the corona very restrained. Give the sphere a brilliant continuous white-gold limb rim, a smoother golden surface with 3–5 very broad orange convection currents, and only a few tiny restrained dark red-brown sunspot marks. Preserve yellow and gold structure inside the disk instead of blowing it to pure white.
Style/medium: beautiful premium stylized game-asset concept; refined painterly 3D illustration with clean astrophysical graphic forms; not pixel art at master resolution; iconic, striking, elegant, immediately solar
Composition/framing: exactly one sphere and its two attached loops, centered on a square canvas, no crop, orthographic icon-like view; main sphere about 54–60% of canvas width while the connected prominence silhouette spans about 72–78%; generous transparent padding around the widest arc; no cast shadow
Lighting/mood: blazing and majestic, strongest astrophysical identity of the three; crisp luminous limb against a dark navy Planetary Play Field; controlled highlight with readable orange/gold surface
Color palette: white-hot yellow, saturated gold, orange, restrained red-orange in prominence shadows; tiny dark red-brown sunspots only; no cool colors
Materials/textures: smooth stellar plasma with broad flowing currents; the two loops have clear hollow negative space and luminous connected footpoints; not rock, lava, glass, cheese, or planetary atmosphere
Small-size requirement: at 32 pixels both attached prominence loops must retain unmistakable open arch/negative-space shapes, the limb rim must remain a bright continuous circle, and the warm surface must remain visibly textured; it must never reduce to a generic orange dot or an explosion
Constraints: actual transparent background with clean alpha edges and all four corners fully transparent; exactly one spherical Sun with exactly two large loops attached to the sphere at both endpoints; no text, letters, numbers, face, eyes, mouth, limbs, character, UI, scenery, stars, space background, floor, cast shadow, icon plate, border, logo, watermark, opaque background, checkerboard, planetary land or ocean, planetary rings, satellites, moons, separate orbiting objects, detached flames, disconnected sparks, generic orange ball
Avoid: fireball, explosion, all-around flame crown, lava planet, flower, eye, cheese, fantasy magic orb, gas giant, candy, emoji, photoreal telescope photo, featureless white sphere, excessive bloom, smoke, particle cloud, closed ring around the Sun
```

### Exact prompt — C / Granule Heart

```text
Use case: stylized-concept
Asset type: premium concept master for a very small Stage 2 Planetary gameplay ball
Primary request: Candidate C — “Granule Heart.” Create one isolated spherical Sun whose identity remains immediately unmistakable when deterministically reduced to a 32-pixel gameplay diameter. This is a new standalone concept, not an edit. Make it structurally distinct from an all-around flame crown and from giant prominence loops: this is the most compact, graphic, surface-driven Sun.
Scene/backdrop: genuinely transparent RGBA alpha background only; no visible backdrop, matte, checkerboard, floor, shadow, scenery, stars, or space
Subject: one near-perfect circular Sun centered in frame with only a thin controlled turbulent attached corona hugging the limb. Make the dominant surface structure a bold honeycomb/granulation pattern of 10–14 large irregular convection cells, outlined by orange-red channels and filled with gold/yellow plasma. Across the center, add one broad white-hot horizontal central belt made of connected incandescent cells, visibly integrated into the stellar surface rather than a ring. Add exactly three simple, clearly separated dark red-brown sunspots, each small and circular/irregular, positioned away from the central belt so all three survive reduction. Use a thin uneven corona with short attached micro-spikes only; no giant tongues or looping arcs.
Style/medium: beautiful premium stylized game-asset concept; refined graphic painterly 3D illustration, almost emblematic in its bold surface mapping; not pixel art at master resolution; clean, striking, highly readable
Composition/framing: exactly one compact near-perfect sphere, centered on a square canvas, no crop, orthographic icon-like view; sphere plus thin corona occupies about 66–70% of canvas; generous even transparent padding; circular ratio and centered mass are especially important
Lighting/mood: incandescent but controlled, graphic and premium; bright central belt, darker orange-red cell channels and restrained limb shadow create high contrast against a dark navy Planetary Play Field without turning the whole disk white
Color palette: white-hot yellow central belt, saturated gold convection cells, orange and restrained red-orange channels/edge shadows, exactly three tiny dark red-brown sunspots; no cool colors
Materials/textures: cellular solar granulation and convection, not rock cracks, lava crust, scales, glass, cheese, flowers, or planetary geography; broad clean cells, no noisy micro-detail
Small-size requirement: at 32 pixels the honeycomb cells must remain visible as a structured warm mosaic, the white-hot central belt must remain a distinct band, exactly three dark sunspot cues should survive, and the thin corona must preserve a solar edge; it must never reduce to a generic orange/yellow dot, a gas giant, or a lava planet
Constraints: actual transparent background with clean alpha edges and all four corners fully transparent; exactly one spherical Sun; thin corona attached to the limb; no text, letters, numbers, face, eyes, mouth, limbs, character, UI, scenery, stars, space background, floor, cast shadow, icon plate, border, logo, watermark, opaque background, checkerboard, planetary land or ocean, planetary rings, satellites, moons, orbiting objects, looping prominences, detached flames, disconnected sparks, generic orange ball
Avoid: fireball, explosion, lava planet, cracked magma rock, flower, sunflower, eye, cheese, fantasy magic orb, gas giant bands, candy, emoji, photoreal telescope photo, featureless white sphere, excessive bloom, smoke, particle cloud, all-around large flame crown, large loops
```

## Deterministic normalization and reduction

Environment: Pillow `12.3.0`, NumPy `2.5.1`.

Master normalization:

1. Decode each built-in result as RGBA.
2. Treat alpha `>= 8` as foreground. Retain the 4-connected foreground component containing the canvas center and clear all other pixels to `(0,0,0,0)`. This removed tiny detached antialias noise without repainting the candidate.
3. Crop to the retained alpha bounds.
4. Resize aspect-preservingly in premultiplied `RGBa` with `Image.Resampling.LANCZOS` so the long edge is exactly `928px`.
5. Center at integer coordinates on a `1254×1254` transparent RGBA canvas.
6. Clear resampled pixels with alpha `< 8`, retain the center component again, and force zero-alpha RGB to black.

32px preview:

1. Crop the normalized master to its alpha bounds.
2. Resize aspect-preservingly in premultiplied `RGBa` with Lanczos so the long edge is exactly `32px`.
3. Alpha-composite at integer center on a transparent `32×32` RGBA canvas.
4. Clear alpha `< 8`, retain the center component, and clear zero-alpha RGB.
5. No sharpening, palette quantization, manual repainting, pixel-art redrawing, outline injection, or runtime asset import is applied.

The enlarged views in `comparison.html` render the same `32×32` files at 8× with browser `image-rendering: pixelated`; they are not additional candidates.

## Small-size assessment

All candidates were inspected at native `32×32` and enlarged-nearest against a dark navy Planetary-style field.

| Candidate | Native 32px result | Assessment |
|---|---|---|
| A — Corona Crown | The disk remains bright gold rather than white; the crown leaves repeated radial notches and the sunspot cluster survives as one dark cue. | **PASS** — fastest literal Sun read; neither a generic dot nor a detached explosion. |
| B — Prominence Arc | Both hollow prominence loops remain open and attached, while the central disk keeps a continuous white-gold limb and warm current structure. | **PASS** — most distinctive silhouette. The central disk is intentionally smaller than A/C because the 32px footprint includes the two loops. |
| C — Granule Heart | The honeycomb mosaic, white central belt, exactly three dark sunspot pixels, and thin irregular corona remain separate cues. | **PASS** — strongest surface identity. The enlarged master approaches a molten-cell texture, but the belt, three spots, and attached corona keep the actual 32px read solar rather than planetary. |

Fixed preview classifiers count alpha `>= 8` pixels. A/B/C retain respectively `217/484/323/1`, `186/442/172/0`, and `208/562/320/3` white-hot/gold/orange-red/dark-spot pixels. Dark-field luminance standard deviation is `62.39`, `60.31`, and `50.11`, confirming that no preview is a flat featureless warm dot.

No candidate failed the small-size gate, so the allowed targeted retry was not used.

## Technical validation

All six PNG files pass:

- Correct PNG signature; ordered `IHDR → IDAT... → IEND`; every chunk CRC valid; no bytes after `IEND`.
- `8-bit RGBA` (`IHDR color type 6`), genuine alpha, all four corner alpha values `0`, and zero-alpha RGB cleared to `(0,0,0)`.
- Exactly one connected foreground component at alpha `>= 8`; no detached sparks or extra objects survived normalization.
- Master centers are within `0.5px` of the canvas center and limiting-axis padding is at least `163px`.
- Visual forbidden-element inspection: no text, face, eyes, limbs, UI, scenery, star/space or floor background, cast shadow, icon plate, border, logo, watermark, baked checkerboard, land/ocean, planetary ring, moon/satellite, separate orbiting flame, flower, cheese, eye, fantasy orb, or generic plain orange ball.

### Concept masters

| Candidate | Bytes | SHA-256 | Alpha bbox | Ratio | Center offset | L/R/T/B padding | Alpha nonzero / partial / opaque / median | PNG chunks |
|---|---:|---|---|---:|---|---|---|---|
| A | 1,141,389 | `32670B92965433718B15C5A69BCB9A72EC235AD69B721B45695B21F9FB8A3FCA` | `(187,163)–(1066,1091)` = `879×928` | `0.9472` | `(-0.5,0.0)` | `187/188/163/163` | `516,893 / 516,761 / 132 / 252` | `IHDR + 17 IDAT + IEND` |
| B | 865,590 | `782392CBC9A610643272297C2EE7F18BC558D1E8201FDE87EA5CBB3E5CCBD89A` | `(163,195)–(1091,1058)` = `928×863` | `1.0753` | `(0.0,-0.5)` | `163/163/195/196` | `375,878 / 375,870 / 8 / 252` | `IHDR + 14 IDAT + IEND` |
| C | 1,397,262 | `ADF9168BD6778289F0D3E1EF807525C59B3DC9F2EF39073D53D708D1A2A3F6AE` | `(163,167)–(1091,1086)` = `928×919` | `1.0098` | `(0.0,-0.5)` | `163/163/167/168` | `610,870 / 610,870 / 0 / 252` | `IHDR + 22 IDAT + IEND` |

The master ratio records the full attached solar silhouette, not only the disk: A is taller because of its crown, B is wider because of its prominence loops, and C is intentionally near-circular.

### 32px previews

| Candidate | Bytes | SHA-256 | Size / alpha bbox / ratio | Alpha nonzero / partial / opaque | White-hot / gold / orange-red / dark spot | Luminance σ | Components / corners |
|---|---:|---|---|---|---|---:|---|
| A | 2,590 | `918B553AF7EB72CC3A413EB7DD8A15DA253A2D4DD9E23AE146FC27793D3F5A38` | `32×32 / 30×32 / 0.9375` | `692 / 645 / 47` | `217 / 484 / 323 / 1` | `62.39` | `1 / 0,0,0,0` |
| B | 2,046 | `628D0A8B1B223EF4A353B239938CEAFA77D07BA82049E320A1A7444E84623992` | `32×32 / 32×30 / 1.0667` | `507 / 429 / 78` | `186 / 442 / 172 / 0` | `60.31` | `1 / 0,0,0,0` |
| C | 2,634 | `E443388EB601DACCD1BF9FAD259E8B0F23F86E3598D26FEBA7E8AB67CE1D84D7` | `32×32 / 32×32 / 1.0000` | `765 / 707 / 58` | `208 / 562 / 320 / 3` | `50.11` | `1 / 0,0,0,0` |

## Runtime handoff

- Candidate A is active through `ball_planetary_local_lv02_sun_corona_crown_32.tres`; B/C remain archived alternatives.
- Ball/Stage data, collision radius, score, physics, CUT-IN roster, scenes and `project.godot` are unchanged.
- Native Stage-specific asset verification covers the active Sun binding and adjacent Planetary/Galactic LODs.

Limitations: the high-resolution masters remain concept sources. The active `32×32` Candidate A derivative prioritizes immediate solar recognition over the previous strict pixel-grid style.
