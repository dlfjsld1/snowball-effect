# Planetary Earth Redesign v1

Status: **USER-AUTHORED 16PX EARTH ACTIVE IN RUNTIME**

Target: Stage 2 / Planetary / global Lv5 Earth / local Lv1

The user-authored `16×16` Earth is the active runtime body asset. The three generated A/B/C masters and their deterministic previews remain historical concepts only; none of them is wired to gameplay. Open [`comparison.html`](comparison.html) to inspect that earlier exploration.

## Authoritative gameplay target

- `resources/stages/stage_01_planetary.tres` defines the ordered chain `[4, 5, 6, 8, 10]`, so Earth (`global_level = 5`) is Planetary local Lv1.
- `scripts/simulation/ball_simulation_manager.gd` computes Stage-local runtime radius as `4 * 2 ^ local_level`. Earth therefore renders and collides at radius **8 logical pixels**, diameter **16 logical pixels**.
- `scripts/presentation/ball_texture_lod_catalog.gd` resolves only global Lv5 at diameter `16` to the dedicated user-authored `assets/sprites/balls/planetary/runtime/ball_planetary_local_lv01_earth_user_authored_16.tres`.
- `resources/balls/ball_05_earth.tres` keeps catalog/fallback `radius = 64` and currently points its primary texture at `ball_lv05_mercury_16.png`; neither value is the active Planetary runtime-size or exact-size texture source. This pre-existing fallback mismatch is recorded only and was not changed.
- The current Earth sprite, Planetary chain artwork, Stage World, actual runtime family capture, active Planetary Moon, and Ground assets were inspected only for contrast and lineage. No image was supplied to generation as a reference or edit target.
- No Earth-specific FIRST CONTACT CUT-IN was found. Planetary FIRST CONTACT remains Supernova/Galaxy only; all CUT-IN assets are untouched.

## Active runtime asset

- PNG: `assets/sprites/balls/planetary/runtime/ball_planetary_local_lv01_earth_user_authored_16.png`.
- Dedicated CanvasTexture: `assets/sprites/balls/planetary/runtime/ball_planetary_local_lv01_earth_user_authored_16.tres`.
- Exact source bytes: `841` bytes, SHA-256 `126A09594B0BE32703E52D566EC1519AD2133930A30DAFE7B1601DFC9A69CD5A`.
- Source format: exactly `16×16`, non-interlaced 8-bit RGBA PNG; valid chunk CRCs and exact `IEND`; binary alpha with `48` transparent and `208` opaque pixels; all four corners transparent.
- Runtime/import policy: native 1:1 output at radius/diameter `8/16`, nearest filtering, repeat disabled, lossless import, alpha preserved, alpha-border fixing enabled, mipmaps disabled, and no resize or source-pixel edit.
- Binding isolation: Planetary local Lv0/global Lv4 Moon, local Lv2/global Lv6 Sun, every Ground mapping, and all other Planetary/Galactic mappings remain on their existing resources.
- Earth is not in the established FIRST CONTACT set. The current Planetary CUT-IN identities are Supernova and Galaxy, so no CUT-IN controller, portrait, title layer, or cut-in asset changed.

## Runtime evidence

[`planetary-main-user-authored-16px-earths-and-8px-moons-runtime.png`](planetary-main-user-authored-16px-earths-and-8px-moons-runtime.png) is a real `1600×900` native capture of the actual Main scene in `Planetary / PLAYING`. The deterministic capture entered Planetary through the real Ground Score Clear → matching `NEXT STAGE` → Scale Shift flow, then froze gameplay and rendered 15 Moons, 25 Earths, 6 Suns, 3 Supernovas, and 1 Galaxy through the production simulation/MultiMesh path with the live HUD, frame, Paddle, and Planetary Stage World.

- Capture: `120,346` bytes, SHA-256 `63EBCA1B8949C5AAA5CF9EB0861C587EA749274283838633895A2B9ADCAE7CD0`.
- Production clip rect: `(440, 50, 720, 768)` with `50` standard balls.
- A native Earth instance reproduces all `208` authored opaque pixels with exact RGB equality; its `48` transparent pixels all reveal the same Play Field backdrop color. This proves crisp nearest-filtered 1:1 output with no matte or alpha fringe.
- A partial Earth at the left logical boundary has `42` authored opaque pixels outside the clip; none appears outside the active Play Field.
- Native OpenGL Compatibility capture-only 60-frame sample: average `93.7 FPS`, minimum `44.4 FPS`, maximum frame `22.52ms` on Intel Arc 130V.
- Visual inspection confirms upright pale upper atmosphere and dark lower ocean, immediate blue/green Earth recognition at `16px`, strong contrast against the dark field, and a clear Moon `8px` → Earth `16px` → Sun `32px` progression. No import/resource repair or gameplay-size change was needed.

## Historical concepts

Candidates A/B/C below are preserved as design history. They are not the selected or active runtime Earth.

## Three final candidates

| Candidate | Master | Deterministic 16 px preview | Distinct macro read |
|---|---|---|---|
| A — Pocket Blue Marble | [`candidate-a-pocket-blue-marble-master.png`](candidate-a-pocket-blue-marble-master.png) | [`candidate-a-pocket-blue-marble-preview-16px.png`](candidate-a-pocket-blue-marble-preview-16px.png) | Bright literal Earth: broad Atlantic-facing land masses, crisp polar white, curved cloud belt. |
| B — Living Terminator | [`candidate-b-living-terminator-master.png`](candidate-b-living-terminator-master.png) | [`candidate-b-living-terminator-preview-16px.png`](candidate-b-living-terminator-preview-16px.png) | Diagonal day/night split: lit cobalt ocean and green Americas against a deep navy hemisphere and cyan rim. |
| C — Cloud-Crown Terra | [`candidate-c-cloud-crown-terra-master.png`](candidate-c-cloud-crown-terra-master.png) | [`candidate-c-cloud-crown-terra-preview-16px.png`](candidate-c-cloud-crown-terra-preview-16px.png) | Near-full ocean-led globe: two separated green land islands, polar crown, sweeping white cloud hook. |

## Generation record

- Tool path: built-in `image_gen` only.
- Initial calls: exactly **three**, one fresh call per candidate.
- Initial source outputs:
  - A: `C:\Users\gktjd\.codex-work\generated_images\01a03224-5fe4-77d3-b134-c57397e94f61\exec-7259bc86-366c-462c-9061-2e6f300d02af.png`
  - B: `C:\Users\gktjd\.codex-work\generated_images\01a03224-5fe4-77d3-b134-c57397e94f61\exec-4d7df332-bec3-4723-8167-a890601e8d39.png`
  - C: `C:\Users\gktjd\.codex-work\generated_images\01a03224-5fe4-77d3-b134-c57397e94f61\exec-12c02261-0714-4571-a122-43b3cea964a3.png`
- Retry count: A `0`, B `0`, C `1` targeted edit retry.
- C retry outcome: **rejected**. It removed the mountain-heavy fantasy treatment but returned an opaque `1254×1254` RGB file with a baked checkerboard (`corner RGBA = 253,253,253,255`) and no alpha channel. The rejected file is not in this package. The technically valid initial C remains the final candidate.
- CLI/API fallback: not used.
- Generation session: `codex_work`, `gpt-5.6-sol`.

### Exact initial prompt — A / Pocket Blue Marble

```text
Use case: stylized-concept
Asset type: premium game-asset concept master for a very small Stage 2 Planetary gameplay ball
Primary request: Candidate A — “Pocket Blue Marble.” Create one isolated Earth sphere whose identity remains instantly unmistakable when reduced to a 16-pixel gameplay diameter. This is a new standalone concept, not an edit. Make it the clearest, brightest, most literal small-size Earth of the three directions.
Scene/backdrop: genuinely transparent alpha background only; no visible backdrop, matte, checkerboard, floor, or scenery of any kind
Subject: one compact, perfectly centered circular Earth sphere, occupying about 70–74% of a square canvas with generous even transparent padding. Show a bright near-full Earth face dominated by deep cobalt and cerulean ocean. Use exactly two broad, chunky, recognizable green continent shapes as the main macro landmarks: a simplified Africa–Europe-like land mass and a simplified Americas-like companion, separated by visible blue ocean. Add one crisp white polar cap/highlight at the top and only one simple curved white cloud band sweeping across open ocean without hiding the continents. Preserve a clean readable atmospheric rim and strong spherical light falloff. The blue/green/white separation must remain obvious at thumbnail size.
Style/medium: beautiful premium stylized game-asset concept; refined painterly/3D illustration, not pixel art at master resolution; deliberately simplified for clean 16-pixel reduction; literal Earth identity, not a generic blue marble and not a flat map pasted inside a ball
Lighting/mood: bright, welcoming full-globe lighting from upper-left; luminous ocean highlight, controlled navy falloff at lower-right, slim pale-cyan atmosphere rim; striking against a very dark Planetary play field
Color palette: vivid but controlled deep cobalt and cerulean ocean, emerald and leaf-green land, tiny restrained warm ochre coastal accents allowed, bright white clouds and polar ice, restrained navy shadow; no neon
Materials/textures: smooth atmospheric globe with subtle ocean depth and gently raised land treatment; graphic broad forms, no excessive tiny geography, no photoreal satellite noise
Composition/framing: single sphere only, front-facing orthographic icon-like presentation, centered, no crop, compact circular footprint, generous transparent padding, no cast shadow
Constraints: actual transparent RGBA background with clean alpha edges and all corners transparent; one Earth sphere only; two broad green continent shapes, one top polar highlight, one curved cloud band, blue ocean, white ice/clouds, spherical lighting and readable rim must all remain visibly distinct; no text, letters, numbers, political borders, face, eyes, limbs, UI, scenery, stars, space background, floor, cast shadow, icon plate, logo, watermark, opaque or checkerboard background, rings, Moon, satellites, orbiting objects, extra disconnected objects, fantasy continents covering everything, generic blue marble without continents, exact photoreal NASA copy, excessive tiny geography, clouds hiding the continents, flat map pasted inside a generic ball, neon toy-plastic finish
```

### Exact initial prompt — B / Living Terminator

```text
Use case: stylized-concept
Asset type: premium game-asset concept master for a very small Stage 2 Planetary gameplay ball
Primary request: Candidate B — “Living Terminator.” Create one isolated Earth sphere whose identity and dramatic spherical value pattern remain instantly unmistakable when reduced to a 16-pixel gameplay diameter. This is a new standalone concept, not an edit, and must be structurally distinct from a bright full-Earth design.
Scene/backdrop: genuinely transparent alpha background only; no visible backdrop, matte, checkerboard, floor, or scenery of any kind
Subject: one compact, perfectly centered circular Earth sphere, occupying about 70–74% of a square canvas with generous even transparent padding. Build the design around a strong diagonal day/night boundary running from upper-left toward lower-right across the globe. On the illuminated side, show rich cobalt/cerulean ocean and one single bold emerald continent mass crossing into or touching the terminator so it remains unmistakably Earth. Keep the night side restrained deep navy, preserving faint ocean roundness rather than turning black. Add a luminous pale-cyan atmosphere rim strongest along the dark edge, a crisp white polar highlight near the lit upper edge, and only two sparse broad cloud strokes that do not hide the continent. The diagonal light/dark division, green land, blue ocean, white atmosphere and ice must all remain separate at thumbnail size.
Style/medium: beautiful premium stylized game-asset concept; refined graphic painterly/3D illustration, not pixel art at master resolution; deliberately simplified for clean 16-pixel reduction; strong cinematic globe volume, not a generic blue marble and not a flat map pasted inside a ball
Lighting/mood: dramatic but inviting diagonal planetary lighting; bright cobalt day side, restrained navy night side, luminous atmosphere rim; strongest spherical/value read of the three candidates against a very dark Planetary play field
Color palette: vivid but controlled cobalt and cerulean ocean on the day side, one bold emerald/leaf-green land mass, a tiny warm ochre land accent allowed, bright white polar ice and sparse clouds, restrained navy shadow, pale-cyan rim; no neon
Materials/textures: smooth atmospheric planet with broad graphic surface planes; no excessive tiny geography, no photoreal satellite noise, no city lights, no plastic toy gloss
Composition/framing: single sphere only, front-facing orthographic icon-like presentation, centered, no crop, compact circular footprint, generous transparent padding, no cast shadow
Constraints: actual transparent RGBA background with clean alpha edges and all corners transparent; one Earth sphere only; strong diagonal terminator, one bold green continent on the light side, blue ocean, white polar highlight, luminous rim and sparse clouds must remain visibly distinct; no text, letters, numbers, political borders, face, eyes, limbs, UI, scenery, stars, space background, floor, cast shadow, icon plate, logo, watermark, opaque or checkerboard background, rings, Moon, satellites, orbiting objects, extra disconnected objects, fantasy continents covering everything, generic blue marble without continents, exact photoreal NASA copy, excessive tiny geography, clouds hiding the continent, flat map pasted inside a generic ball, city lights, neon toy-plastic finish
```

### Exact initial prompt — C / Cloud-Crown Terra

```text
Use case: stylized-concept
Asset type: premium game-asset concept master for a very small Stage 2 Planetary gameplay ball
Primary request: Candidate C — “Cloud-Crown Terra.” Create one isolated Earth sphere whose identity feels iconic, lively, and instantly unmistakable when reduced to a 16-pixel gameplay diameter. This is a new standalone concept, not an edit, and must be structurally distinct from a literal two-continent full globe and from a strong day/night terminator globe.
Scene/backdrop: genuinely transparent alpha background only; no visible backdrop, matte, checkerboard, floor, or scenery of any kind
Subject: one compact, perfectly centered circular near-full Earth sphere, occupying about 70–74% of a square canvas with generous even transparent padding. Let a large clean blue ocean be the dominant central field. Place exactly two chunky simplified emerald/leaf-green land islands as separate macro shapes, one upper-left of center and one lower-right of center, clearly recognizable as Earth-like land rather than fantasy symbols. Frame them with a crisp bright white polar crown across the top rim and one sweeping white cloud hook that curves from the upper-right toward the center-left, energetic but sparse enough that the green land and blue ocean remain unobscured. Add a clear atmospheric rim and soft spherical shadow concentrated low on the globe. The polar crown, cloud hook, blue ocean, and two green islands must form four bold readable shapes at thumbnail size.
Style/medium: beautiful premium stylized game-asset concept; refined graphic painterly/3D illustration with clean broad forms, not pixel art at master resolution; deliberately simplified for clean 16-pixel reduction; iconic Earth emblem with real globe volume, not a generic blue marble and not a flat map pasted inside a ball
Lighting/mood: luminous near-full Earth, fresh and energetic; bright upper hemisphere, controlled lower navy falloff, pearly white cloud and ice accents, narrow pale-cyan atmosphere rim; appealing against a very dark Planetary play field
Color palette: vivid but controlled deep cobalt/cerulean ocean, emerald and leaf-green land islands, tiny restrained warm ochre accents allowed, bright white cloud hook and polar ice crown, restrained navy shadow, pale-cyan rim; no neon
Materials/textures: smooth atmospheric globe with subtle ocean depth and broad land treatment; cloud hook reads soft yet graphic; no excessive tiny geography, no photoreal satellite noise, no toy-plastic gloss
Composition/framing: single sphere only, front-facing orthographic icon-like presentation, centered, no crop, compact circular footprint, generous transparent padding, no cast shadow
Constraints: actual transparent RGBA background with clean alpha edges and all corners transparent; one Earth sphere only; dominant blue ocean, exactly two separate chunky green land shapes, one sweeping white cloud hook, one top polar crown, spherical lighting and readable rim must remain visibly distinct; no text, letters, numbers, political borders, face, eyes, limbs, UI, scenery, stars, space background, floor, cast shadow, icon plate, logo, watermark, opaque or checkerboard background, rings, Moon, satellites, orbiting objects, extra disconnected objects, fantasy continents covering everything, generic blue marble without continents, exact photoreal NASA copy, excessive tiny geography, clouds hiding the land, flat map pasted inside a generic ball, neon toy-plastic finish
```

### Exact targeted retry prompt — C / rejected result

```text
Targeted retry for Candidate C — “Cloud-Crown Terra.” Edit the most recent Earth concept only.

Primary change: replace the two mountain-dominant fantasy archipelagos with exactly two broad, chunky, simplified Earth-like green continental island shapes. Remove all prominent mountains, volcanoes, fantasy terrain, tiny surrounding islets, and intricate coastlines. Keep the land graphic and map-readable, with smooth emerald/leaf-green surface planes and only tiny restrained ochre accents. The result must read as Earth, not a fictional fantasy planet.

Preserve unchanged: one isolated centered circular Earth sphere; genuinely transparent RGBA background and transparent corners; compact footprint with generous even padding; dominant cobalt/cerulean central ocean; one sweeping white cloud hook; bright white polar crown at the top; near-full spherical lighting; restrained navy lower shadow; pale-cyan atmospheric rim; no text, face, UI, scenery, stars, space background, cast shadow, icon plate, rings, Moon, satellite, orbiting object, logo, watermark, opaque/checkerboard background, political borders, excessive geography, or extra disconnected objects.

Small-size requirement: the blue ocean, two green land shapes, white cloud hook, and white polar crown must remain four separate bold value/color structures after deterministic reduction to a 16-pixel gameplay diameter. Keep it premium, beautiful, stylized, and striking, but not pixel art at master resolution, not photoreal NASA imagery, not toy-plastic, and not a flat map pasted inside a generic ball.
```

## Deterministic normalization and reduction

Environment: Pillow `12.3.0`.

Master normalization:

1. Decode each built-in result as RGBA.
2. Treat alpha `> 0` as foreground connectivity, retain only the largest 8-connected component, and clear every other pixel to `(0,0,0,0)`.
3. Crop that sphere component to its alpha bounds.
4. Resize aspect-preservingly in premultiplied `RGBa` with `Image.Resampling.LANCZOS` so its long edge fits `round(1254 × 0.74) = 928` pixels.
5. Center it on a `1254×1254` transparent RGBA canvas, clear zero-alpha RGB to black, and repeat largest-component cleanup after resampling.

16 px preview:

1. Crop the normalized master to its alpha bounds.
2. Resize aspect-preservingly in premultiplied `RGBa` with Lanczos so the long edge is `16` pixels.
3. Alpha-composite at integer center on a transparent `16×16` RGBA canvas.
4. Clear pixels with alpha `< 8` to `(0,0,0,0)` and retain the largest connected component.
5. No sharpening, manual repainting, palette quantization, pixel-art redrawing, or runtime asset import is applied. Enlarged views in `comparison.html` display the same 16×16 file with nearest-neighbor browser scaling.

## Small-size assessment

All candidates were inspected at native 1:1 and enlarged-nearest against a dark Planetary-style field.

| Candidate | Native 16 px result | Assessment |
|---|---|---|
| A | Cobalt ocean remains dominant; two broad green/ochre land groups and white polar/cloud pixels stay visibly separate. | **PASS** — clearest literal Earth and strongest immediate identity. |
| B | The lit cyan-blue half and deep navy half remain sharply split; green land survives on the lit side and white ice/rim remains distinct. | **PASS** — strongest spherical/value read; not a generic blue dot. |
| C | Two green land patches remain separated across a blue ocean; the polar crown and cloud hook compress into distinct pale upper/central accents. | **PASS with limitation** — reads as Earth at 1:1; the retained initial master has more terrain detail than ideal because the only retry failed transparency. |

The final preview color-presence metric counts alpha `>= 8` pixels using fixed broad blue/green/white classifiers. A/B/C respectively retain `144/60/12`, `136/25/21`, and `169/28/20` blue/green/white pixels. Every candidate therefore preserves all three Earth identity channels at the actual target size.

## Technical validation

All six package PNGs pass:

- PNG signature; ordered `IHDR` → one or more `IDAT` → `IEND`; every chunk CRC; exact EOF after `IEND`.
- 8-bit RGBA (`color type 6`), genuine alpha, all four corners alpha `0`, one connected foreground sphere, and clear-black RGB for zero-alpha pixels.
- Centering within `0.5 px` on the `1254 px` master canvas, minimum master padding `163 px`, and near-circular alpha bounds (`0.9795–1.0131` width:height).
- Visual forbidden-element inspection: one sphere only; no text, face, eyes, limbs, UI, scenery, stars, space/floor, cast shadow, plate, logo, watermark, baked checkerboard, rings, Moon, satellite/orbit objects, political borders, or extra disconnected objects.

### Masters

| Candidate | Bytes | SHA-256 | Alpha bbox | Ratio | Center offset | L/R/T/B padding | Alpha nonzero / partial / opaque / median | Components / corners |
|---|---:|---|---|---:|---|---|---|---|
| A | 1,473,044 | `CC72933816F1BBE149B5656072E8E176BF28D4C386466762B4C4CE823F79C1F9` | `(163,164)–(1090,1088)` = `928×925` | `1.0032` | `(+0.0,-0.5)` | `163/163/164/165` | `661,860 / 661,089 / 771 / 252` | `1 / 0,0,0,0` |
| B | 1,381,940 | `78DC2B9751752A3E89C822134BFFB36630F82ECDA6AAC0174EB3E8088B0032AE` | `(163,169)–(1090,1084)` = `928×916` | `1.0131` | `(+0.0,+0.0)` | `163/163/169/169` | `645,819 / 645,306 / 513 / 252` | `1 / 0,0,0,0` |
| C | 1,420,627 | `4944AC932B4D93CA6644B3B3C76BF26D570CE7155E7C0C74E736CA5A633F03F7` | `(172,163)–(1080,1090)` = `909×928` | `0.9795` | `(-0.5,+0.0)` | `172/173/163/163` | `649,576 / 649,390 / 186 / 252` | `1 / 0,0,0,0` |

Master chunk counts are A `IHDR + 23 IDAT + IEND`, B `IHDR + 22 IDAT + IEND`, and C `IHDR + 22 IDAT + IEND`.

### 16 px previews

| Candidate | Bytes | SHA-256 | Size / bbox / ratio | Alpha nonzero / partial / opaque | Blue / green / white / ochre pixels | Luminance σ | Components / corners |
|---|---:|---|---|---|---|---:|---|
| A | 971 | `27283B8D4E24C39EFB6E87CB1D9235114E7C8FE73BEE8BA8D26A91C59937EABB` | `16×16 / 16×16 / 1.0000` | `216 / 186 / 30` | `144 / 60 / 12 / 21` | `53.59` | `1 / 0,0,0,0` |
| B | 938 | `426705065607BEA9BC356CA55BC543D7C027D7AC59FD6316C3B63BAD4B7BE9AC` | `16×16 / 16×16 / 1.0000` | `216 / 184 / 32` | `136 / 25 / 21 / 8` | `73.60` | `1 / 0,0,0,0` |
| C | 927 | `9EC97B5585E7957D92BB664E7C39096893DA7CFDAD6E0ACF53395D13419AA71F` | `16×16 / 16×16 / 1.0000` | `208 / 177 / 31` | `169 / 28 / 20 / 13` | `58.54` | `1 / 0,0,0,0` |

Each preview uses `IHDR + IDAT + IEND`, with valid CRCs and no trailing bytes.

## Boundaries

- A/B/C remain concept masters plus deterministic historical previews; none is a production runtime sprite.
- The separate user-authored PNG and CanvasTexture above are the active Planetary local Lv1 Earth runtime body.
- Earth CUT-IN is not part of the current established set, and no CUT-IN art or controller changed.
- Planetary Moon, all Ground mappings, every other Planetary/Galactic mapping, catalog/gameplay data, shader orientation fix, scenes, `project.godot`, Integration-owned files, Goal status, score, mass, physics, and gameplay rules remain unchanged.
- No staging, commit, or push was performed.
