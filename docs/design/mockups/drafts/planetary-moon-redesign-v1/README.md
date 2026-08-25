# Planetary Moon Redesign v1

Status: **ACTIVE RUNTIME — user-authored 8 px Moon**

Target: Stage 2 / Planetary / global Lv4 Moon / local Lv0

The active gameplay asset is the user's separately authored native `8×8` PNG. The earlier A/B/C concept masters remain below as historical exploration and are not active runtime choices.

## Active runtime asset

- Source supplied by the user: `C:\Users\gktjd\Downloads\ball_lv01_moon_user_authored_8.png` (left unchanged).
- Repository PNG: `assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.png`.
- Dedicated runtime resource: `assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.tres`.
- Exact source properties: `285` bytes, `8×8`, non-interlaced 8-bit RGBA PNG, binary alpha, all four corners transparent, valid chunk CRCs, no bytes after `IEND`.
- SHA-256: `7346459DFC4522CA2D5F617AD1468A9DA436C17B4926E56634A275517A500AE6`.
- Runtime/import policy: native 1:1 pixels, nearest filtering, repeat disabled, lossless import, alpha preserved, alpha-border fixing enabled, mipmaps disabled, no resize or resampling.
- Binding scope: Planetary local Lv0 / global Lv4 only, at gameplay radius `4` and diameter `8`.
- Ground local Lv4 / global Lv4 remains a separate radius `64`, diameter `128` binding to `ball_lv04_moon_user_authored_128.tres` and is unchanged.
- Moon FIRST CONTACT CUT-IN portrait/title assets remain separate from gameplay LOD textures and are unchanged.

## Actual gameplay target

- `resources/stages/stage_01_planetary.tres` defines Planetary as `[4, 5, 6, 8, 10]` with `visual_radius_scale = 1.0`, so global Lv4 Moon is local Lv0.
- The authoritative Stage-local radius formula is `4 * 2 ^ local_level`. Planetary Moon therefore renders and collides at radius `4`, diameter **8 logical pixels**.
- `scripts/presentation/ball_texture_lod_catalog.gd` resolves global Lv4 at diameter `8` to the active stage-specific `ball_planetary_local_lv00_moon_user_authored_8.tres`, while global Lv4 at diameter `128` continues to resolve to the separate Ground Moon resource.
- `resources/balls/ball_04_moon.tres` has a catalog/fallback radius and Ground primary texture, but those values are not the Planetary runtime-size source of truth.

## Runtime evidence

[`planetary-main-user-authored-8px-moons-runtime.png`](planetary-main-user-authored-8px-moons-runtime.png) is a real `1600×900` native capture of the actual Main scene in `Planetary / PLAYING`. The fixture entered Planetary through the real Ground Score Clear → matching Next Stage → Scale Shift flow, then froze gameplay and rendered 14 Moon instances plus Earth, Sun, Supernova, and Galaxy context through the production simulation/MultiMesh path with the live HUD, frame, and Planetary background.

- Capture SHA-256: `882487F3E1F0785A9BFFB2678FEEDA9D43D4CA92F5464835803B65CF4BF5B72E`.
- Production clip rect in the capture: position `(440, 50)`, size `(720, 768)`; two Moon samples straddle its side edges and do not leak into Stage World/frame space.
- Native 1:1 inspection: nearest-sampled pixels remain crisp; transparent corners produce no square matte or fringe; the pale upper highlight and blue-violet lower-right shadow remain upright; the Moon reads as a small cratered pearl against the dark Planetary Play Field.
- The runtime radius remains exactly `4`. No visual repair changed gameplay size, physics, catalog data, or Stage rules.

## Historical concept candidates

| Candidate | Master | Deterministic 8 px preview | Macro-readable intent |
|---|---|---|---|
| A — Crater Pearl | [`candidate-a-crater-pearl-master.png`](candidate-a-crater-pearl-master.png) | [`candidate-a-crater-pearl-preview-8px.png`](candidate-a-crater-pearl-preview-8px.png) | Bright literal full Moon; dominant lower-left basin, two companion craters, pearl-like falloff. |
| B — Terminator Moon | [`candidate-b-terminator-moon-master.png`](candidate-b-terminator-moon-master.png) | [`candidate-b-terminator-moon-preview-8px.png`](candidate-b-terminator-moon-preview-8px.png) | Diagonal light/shadow split, three broad crater masses, bright rim; strongest value silhouette. |
| C — Maria Emblem | [`candidate-c-maria-emblem-master.png`](candidate-c-maria-emblem-master.png) | [`candidate-c-maria-emblem-preview-8px.png`](candidate-c-maria-emblem-preview-8px.png) | Bold connected dark maria emblem plus a small lower-right ray crater; most graphic/iconic. |

Open [`comparison.html`](comparison.html) for the transparent masters and the same 8×8 derivatives at native 1:1, 4× nearest, and 16× nearest inspection sizes.

## Generation record

- Tool path: built-in `image_gen` only.
- Calls: exactly three initial generation calls, one per candidate.
- References supplied to generation: none. The active Ground Moon and Moon CUT-IN were inspected only for lineage/context.
- Retry count: **0 for A, 0 for B, 0 for C**. All three initial results passed the critical alpha and small-size identity gates after deterministic component cleanup and canvas normalization.
- CLI/API fallback: not used.
- Model/session instruction: `codex_work`, `gpt-5.6-sol`.

### Exact prompt — A / Crater Pearl

```text
Use case: stylized-concept
Asset type: premium game-asset concept master for a very small gameplay ball
Primary request: Candidate A — “Crater Pearl.” Create one isolated Moon sphere whose identity remains unmistakable when reduced to an 8-pixel gameplay diameter. This is a new standalone concept, not an edit.
Scene/backdrop: genuinely transparent alpha background only; no visible backdrop of any kind
Subject: one compact, perfectly centered circular Moon sphere, occupying about 70–74% of a square canvas with generous transparent padding. Bright near-full Moon. Give it exactly one dominant large lower-left impact basin plus two smaller companion craters as the primary macro-readable structures. Use crisp raised crater rims, a few broad lunar surface planes, soft pearl-like spherical shading, and a clean narrow rim/terminator that makes the globe read instantly. The lower-left basin must be the clearest landmark at thumbnail size.
Style/medium: beautiful premium stylized game-asset concept; refined painterly/3D illustration, not pixel art at master resolution; simplified deliberately for excellent reduction to 8 pixels; literal lunar geology rather than a generic ball
Lighting/mood: luminous but controlled, pale ivory highlight from upper-left, gentle cool moon-gray falloff, restrained blue-violet shadow at the far lower-right; high value contrast for a very dark Planetary play field
Color palette: pale ivory, cool moon gray, restrained blue-violet shadow; no pure featureless white
Materials/textures: dry lunar stone, subtly powdery, clearly cratered; not metallic, not glossy chrome, not cheese, not skull, not marble
Composition/framing: single sphere only, front-facing orthographic icon-like presentation, circular footprint, centered, no crop, generous even transparent padding, no cast shadow
Constraints: actual transparent RGBA background with clean alpha edges and transparent corners; one Moon only; compact circle; preserve three macro crater landmarks and spherical shading; no text, letters, numbers, face, eyes, limbs, UI, scenery, stars, space background, floor, cast shadow, icon plate, logo, watermark, checkerboard, opaque background, Earth-like continents, rings, orbit line, satellites, or extra objects
```

### Exact prompt — B / Terminator Moon

```text
Use case: stylized-concept
Asset type: premium game-asset concept master for a very small gameplay ball
Primary request: Candidate B — “Terminator Moon.” Create one isolated Moon sphere whose identity and value pattern remain unmistakable when reduced to an 8-pixel gameplay diameter. This is a new standalone concept, not an edit, and must be structurally distinct from a bright full-Moon design.
Scene/backdrop: genuinely transparent alpha background only; no visible backdrop of any kind
Subject: one compact, perfectly centered circular Moon sphere, occupying about 70–74% of a square canvas with generous transparent padding. Build the entire design around a bold diagonal terminator running from upper-left toward lower-right, dividing a luminous ivory face from a deep cool blue-violet shadow hemisphere. Show only three broad, simplified crater marks as the primary surface features, placed so their rims visibly cross or touch the light/shadow boundary. Add a clean brilliant crescent-like rim along the bright edge while preserving the full circular sphere silhouette. The diagonal light/shadow split must dominate at thumbnail size.
Style/medium: beautiful premium stylized game-asset concept; refined painterly/3D illustration, not pixel art at master resolution; purposefully simplified for excellent 8-pixel reduction; unmistakably lunar geology
Lighting/mood: dramatic diagonal lunar lighting, bright ivory lit plane, deep cool shadow, thin luminous rim; very high large-scale value contrast for a dark Planetary play field
Color palette: pale ivory and cool moon-gray on the lit side, restrained indigo/blue-violet shadow; no pure featureless white
Materials/textures: dry lunar stone with only a few broad forms; not metallic, not glossy chrome, not cheese, not skull, not marble
Composition/framing: single sphere only, front-facing orthographic icon-like presentation, circular footprint, centered, no crop, generous even transparent padding, no cast shadow
Constraints: actual transparent RGBA background with clean alpha edges and transparent corners; one Moon only; exactly three broad crater landmarks as the readable structure; strong diagonal terminator; no dense small crater noise; no text, letters, numbers, face, eyes, limbs, UI, scenery, stars, space background, floor, cast shadow, icon plate, logo, watermark, checkerboard, opaque background, Earth-like continents, rings, orbit line, satellites, or extra objects
```

### Exact prompt — C / Maria Emblem

```text
Use case: stylized-concept
Asset type: premium game-asset concept master for a very small gameplay ball
Primary request: Candidate C — “Maria Emblem.” Create one isolated Moon sphere whose identity remains unmistakable when reduced to an 8-pixel gameplay diameter. This is a new standalone concept, not an edit, and must be structurally distinct from crater-led and strong-terminator designs.
Scene/backdrop: genuinely transparent alpha background only; no visible backdrop of any kind
Subject: one compact, perfectly centered circular near-full Moon sphere, occupying about 70–74% of a square canvas with generous transparent padding. The defining macro structure is one bold connected dark lunar maria mass spanning the upper-left through center, shaped as a simplified irregular lunar pattern, plus one small bright ray crater in the lower-right with a few broad radial rays. Keep all other crater detail extremely restrained. Preserve soft spherical light falloff and a clean narrow cool rim/terminator. The dark maria emblem and bright ray point must survive thumbnail reduction.
Style/medium: beautiful premium stylized game-asset concept; graphic iconic lunar illustration with refined painterly/3D volume, not pixel art at master resolution; deliberately simplified for excellent 8-pixel reduction; clearly the Moon rather than Earth
Lighting/mood: near-full luminous Moon with controlled upper-left ivory light, gentle cool moon-gray roundness, clean blue-violet far rim; high large-scale value contrast for a very dark Planetary play field
Color palette: pale ivory, cool moon gray, charcoal blue-gray maria, restrained blue-violet shadow; no pure featureless white, no blue oceans or green/brown land colors
Materials/textures: dry lunar stone; graphic maria tonal mass and one ray crater; not metallic, not glossy chrome, not cheese, not skull, not marble, not a generic smooth ball
Composition/framing: single sphere only, front-facing orthographic emblem-like presentation, circular footprint, centered, no crop, generous even transparent padding, no cast shadow
Constraints: actual transparent RGBA background with clean alpha edges and transparent corners; one Moon only; one dominant connected dark maria mass and one small bright ray crater; simplified lunar pattern must not resemble Earth continents; no text, letters, numbers, face, eyes, limbs, UI, scenery, stars, space background, floor, cast shadow, icon plate, logo, watermark, checkerboard, opaque background, blue/green Earth-like continents, rings, orbit line, satellites, or extra objects
```

## Deterministic normalization and reduction

Environment: Pillow `12.3.0`.

Master normalization:

1. Decode the built-in result as RGBA.
2. Treat alpha `> 0` as foreground connectivity, retain only the largest 8-connected component, and clear every other pixel to `(0,0,0,0)`.
3. Crop that Moon component to its alpha bounds.
4. Resize aspect-preservingly in premultiplied `RGBa` with `Image.Resampling.LANCZOS` so its long edge fits `round(1254 × 0.74) = 928` pixels.
5. Center it on a `1254×1254` transparent RGBA canvas, clear zero-alpha RGB to black, and repeat the largest-component cleanup after resampling.

8 px preview:

1. Crop the normalized master to its alpha bounds.
2. Resize aspect-preservingly in premultiplied `RGBa` with Lanczos so the long edge is `8` pixels.
3. Alpha-composite at integer center on a transparent `8×8` RGBA canvas.
4. Clear pixels with alpha `< 8` to `(0,0,0,0)`. No sharpening, manual repainting, palette quantization, or pixel-art redrawing is applied.
5. The enlarged views in `comparison.html` use this same 8×8 file with nearest-neighbor browser display; they are not extra candidates or altered derivatives.

## Small-size assessment

| Candidate | Native 8 px result | Assessment |
|---|---|---|
| A | The lower-left basin resolves as the key dark landmark against a bright pearl face; upper-left highlight and cool lower rim keep the sphere lunar. | **PASS** — clearest literal full-Moon read. |
| B | The illuminated half and deep cool half remain strongly separated; the broad crater arrangement compresses into distinct value blocks along the boundary. | **PASS** — strongest silhouette/value read and highest preview luminance spread. |
| C | The connected maria survives as a central charcoal emblem and the ray crater collapses to a small lower-right bright point. | **PASS** — most graphic/iconic read; not a featureless dot. |

All three were inspected at native 1:1 and enlarged-nearest scale against a dark Planetary-style field. No candidate critically failed, so no retry was justified.

## Technical validation

All six PNGs pass the PNG signature, ordered `IHDR`/`IDAT`/`IEND`, every chunk CRC, exact end-of-file, 8-bit RGBA/color-type-6 decode, genuine alpha, transparent-corner, and one-connected-subject checks. Every zero-alpha pixel has clear black RGB; there is no baked checkerboard or opaque matte.

### Masters

| Candidate | Bytes | SHA-256 | Alpha bbox | Bbox W:H | Center offset px | L/R/T/B padding px | Alpha nonzero / median | Components | Corners |
|---|---:|---|---|---:|---|---|---|---:|---|
| A | 1,519,562 | `D8DE912D6E97CE7A32B999E5240E36F1C52DC644712687E4DF0DB01BF12DB375` | `(168,168)–(1087,1084)` = `919×916` | `1.0033` | `(+0.5,-1.0)` | `168/167/168/170` | `656,532 / 250` | 1 | `0/0/0/0` |
| B | 1,379,303 | `64CFE0C10E7B686C46C504DF81FD7FD1ECC2808B7AD5B4D61473AB1894E14AD7` | `(182,179)–(1088,1070)` = `906×891` | `1.0168` | `(+8.0,-2.5)` | `182/166/179/184` | `631,322 / 250` | 1 | `0/0/0/0` |
| C | 1,493,067 | `7DB525A74599D53E03F1808DEB9F3A609760962DE187317B45D630091DF91B9F` | `(177,180)–(1077,1081)` = `900×901` | `0.9989` | `(+0.0,+3.5)` | `177/177/180/173` | `631,237 / 249` | 1 | `0/0/0/0` |

The maximum center offset is `8 px` on a `1254 px` canvas (`0.64%`), minimum padding is `166 px`, and circular bbox ratios stay within `0.9989–1.0168`.

### 8 px previews

| Candidate | Bytes | SHA-256 | Size / bbox / ratio | Alpha nonzero / partial / opaque | Luminance σ | Components / corners |
|---|---:|---|---|---|---:|---|
| A | 332 | `B73A0688F120E50B2CE008F7D576F4AAC02D727A721B7ABA5B2612DA74DD2618` | `8×8 / 8×8 / 1.0000` | `60 / 52 / 8` | `55.38` | `1 / 0,0,0,0` |
| B | 332 | `3CF61D4F0EC5FA08B3C54E43CBE606D77B04EFE9752873DD3BCBBE55FAC74F5B` | `8×8 / 8×8 / 1.0000` | `60 / 52 / 8` | `73.51` | `1 / 0,0,0,0` |
| C | 332 | `416DA4A721CB3A3CC6DC52563AAD200CA22BD874AEA4DAC07ACE3D55BFF8BCBE` | `8×8 / 8×8 / 1.0000` | `60 / 52 / 8` | `49.67` | `1 / 0,0,0,0` |

Visual forbidden-element inspection also passes: one Moon only; no text, face, eyes, limbs, UI, scenery, stars, space/floor, cast shadow, plate, logo, watermark, checkerboard, Earth palette/continents, rings, orbit objects, cheese, skull, marble, chrome, or extra disconnected objects.

## Boundaries and next step

- These are high-resolution concept masters plus deterministic selection previews, not production-ready native-grid runtime sprites.
- At 8 px, fine geological texture necessarily collapses; the retained design signal is each candidate's intentionally different macro structure.
- Runtime adaptation may use a separately authored Planetary-specific 8 px LOD despite Moon sharing global Lv4 with Ground. Adaptation and `BallTextureLodCatalog` wiring await the user's selection.
- The approved Ground gameplay Moon at `assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.png`, the existing Planetary 8 px runtime Moon, and Moon FIRST CONTACT CUT-IN art are intentionally untouched.
- No runtime asset, LOD catalog, shader, test, scene, resource, `project.godot`, Goal status, or worklog is modified by this package.
