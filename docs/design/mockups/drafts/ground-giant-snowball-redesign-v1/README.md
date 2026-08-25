# Ground Giant Snowball Redesign v1

Status: **APPROVED ACTIVE RUNTIME — exact user-authored 64×64 Giant Snowball v2**

Branch: design/ground-snowflake-redesign

Target: Stage 1 / Ground / global Lv3 Giant Snowball

## Authority and scope

The gameplay-ball redesign workflow remains **one ball at a time**:

1. Fix the role and visual goal for one gameplay ball.
2. Produce exactly three materially different concept candidates for that ball.
3. Wait for explicit user selection or directed regeneration.
4. Adapt only the selected direction to gameplay size in a separate task.
5. Validate and approve that runtime handoff before moving to the next ball.

This package originally performed steps 1–2 only. On 2026-08-24 the user supplied and approved a second exact 64×64 Giant Snowball image for the active runtime. The user-authored v2 asset now supersedes both the first user-authored runtime image and every generated candidate; the first runtime resource remains preserved as fallback, and A/B/C remain historical concept alternatives. Goal status and Integration-owned files remain unchanged.

## Approved active runtime

- Authoritative source: `C:\Users\gktjd\Downloads\ball_lv03_giant_snowball_user_authored_64_2.png`. The source remains untouched. The project copy at `assets/sprites/balls/ground/runtime/ball_lv03_giant_snowball_user_authored_64_v2.png` is byte-identical: `7,932` bytes, SHA-256 `EC00642CC45595E2484ABFA0C20C388B4F7434F138AEEE093BEDF320796A4CD7`.
- The source is an exactly terminated valid PNG with valid CRCs for every `IHDR`/`IDAT`/`IEND` chunk. It is exactly `64×64`, non-interlaced 8-bit RGBA, with binary alpha: `852` transparent and `3,244` opaque pixels; all four corners are transparent.
- `ball_lv03_giant_snowball_user_authored_64_v2.tres` is the dedicated active `CanvasTexture`. It uses nearest filtering and disabled repeat. Godot import is lossless, preserves alpha, enables alpha-border fixing, disables mipmaps, and applies no size limit or pixel resampling. The earlier `ball_lv03_giant_snowball_user_authored_64.{png,tres}` pair remains intact as fallback.
- Presentation maps only Ground global Lv3 at runtime diameter `64` to this resource. The existing Stage-local gameplay contract remains radius `32` / diameter `64`, so source pixels render at native 1:1 logical size. Content's primary texture, catalog data/order, score, mass, physics, Merge rules, Core renderer, Scene, `project.godot`, and Integration files were not changed.
- Ground Lv0 Frost Blossom, Lv1 user-authored 16px Snowball, Lv2 user-authored 32px Big Snowball, and all Planetary/Galactic mappings remain on their prior resources. Ground Lv4 is separately updated by the user-authored Moon runtime handoff recorded in [`../ground-moon-redesign-v1/README.md`](../ground-moon-redesign-v1/README.md).
- Current combined runtime evidence: [`../ground-moon-redesign-v1/ground-main-lv3-giant-v2-lv4-moon-runtime.png`](../ground-moon-redesign-v1/ground-main-lv3-giant-v2-lv4-moon-runtime.png), captured from the real Main scene in `Ground / PLAYING` with multiple Lv3 v2 balls, the Lv4 Moon, lower tiers, and the actual HUD/frame. The earlier Giant screenshots remain historical v1 runtime evidence.

## Gameplay-ball pixel-guideline exemption

These concept masters intentionally ignore the strict pixel-grid and native-LOD production rules in [12_PIXEL_DESIGN_GUIDELINES.md](../../../12_PIXEL_DESIGN_GUIDELINES.md). The goal is to find the most beautiful, striking, compelling Giant Snowball itself before deciding how a selected direction should be reduced for gameplay. The canonical guideline remains unchanged. These concepts are not pixel art and are not runtime-ready sprites.

## Lineage and progression

The active user-authored [Big Snowball 32×32 asset](../../../../../assets/sprites/balls/ground/runtime/ball_lv02_big_snowball_user_authored_32.png) and historically approved/generated [Big Snowball A master](../ground-big-snowball-redesign-v1/candidate-a-avalanche-pillow.png) were inspected as lineage references only.

Giant Snowball stays in the same pristine white-snow family, with restrained pale-cyan/cool-white shadow and compact circular gameplay readability. It advances beyond Big Snowball through dramatically larger macro-forms, deeper compression, broader settled weight, stronger self-occlusion, and much less dependence on small plush lobes. No candidate copies the active asset’s pixel style or merely scales the approved Big Snowball master.

## Shared concept contract

- exactly one isolated Giant Snowball gameplay-ball subject
- compact near-circular collision footprint and strong reduced-size silhouette
- generous padding around the subject
- pristine bright-white snow dominant, with restrained cool-white and pale-cyan shadows
- physically convincing compressed snow, powder crust, deep self-shadowing, and immense mass
- broad macro-forms, deep compressed seams, slightly low/settled weight, controlled powder fringe
- intentionally not pixel art
- no text, face, eyes, limbs, snowflake silhouette, UI, scenery, floor, cast shadow, icon plate, logo, watermark, rocks, dirt, metal, separate orbiting debris, or planet-like surface
- avoid cloud, brain, yarn, dough, meringue, ice planet, moon, and plain smooth-sphere reads

## The three candidates

| Candidate | Structural/material direction | Progression and tradeoff |
|---|---|---|
| A — Snowmass Leviathan | Four to six continent-scale compressed snow slabs fused into a low near-sphere, with broad soft valleys and compacted seam floors | Clearest literal giant-snowball read and strongest slab-scale language. The generated form succeeds visually, but both built-in outputs contain a baked checkerboard and no alpha channel. |
| B — Avalanche Juggernaut | Three powerful oblique accumulation bands with crushed-powder shelves, scraped pressure faces, and a subtly flattened lower hemisphere | Strongest momentum and rolling weight. At very small size its bands can hint at wrapped material, but the granular crushed-snow faces and broken shelf lips keep the master physically snowy. |
| C — Polar Behemoth | A huge exposed dense core under two or three short, thick wind-packed mantle plates, deep occlusion caverns, and a low attached powder crown | Most dramatic and imposing. The accepted retry removes the first pass’s yarn-like continuous folds; its broad core can faintly suggest a polar globe at master size, so any later runtime adaptation should preserve snow granularity and avoid celestial surface cues. |

Open [comparison.html](comparison.html) for the static three-way board. It references these same three files and is not a fourth candidate.

## Generation record

Mode: Codex gpt-5.6-sol session using the built-in image_gen tool only. No CLI, API, alternate model, background-removal service, circular mask, staging, commit, or push was used.

- A: one initial built-in generation using both inspected lineage images as reference-only inputs; one permitted targeted background-extraction retry. Both returned opaque RGB PNGs with a baked checkerboard. The retry is preserved as the candidate file and explicitly blocked on transparency.
- B: one initial built-in generation, accepted without retry.
- C: one initial built-in generation; one permitted targeted retry because the first pass critically approached the forbidden yarn/dough read. The retry is accepted.
- B/C received only technical, non-creative normalization: alpha values of 1 or less were cleared to transparent black, then each 1254×1254 render was placed unscaled and centered on a 2048×2048 transparent canvas. No visible edge was masked, resampled, rotated, relit, or regenerated.

## Exact prompts

### Candidate A — initial generation

~~~text
Use case: stylized-concept
Asset type: premium Stage 1 Giant Snowball gameplay-ball concept master for future runtime adaptation
Input images: Image 1 is the active user-authored Big Snowball 32×32 gameplay asset and Image 2 is the approved/generated Big Snowball A “Avalanche Pillow” concept master. Both are family-lineage references only for pristine white snow, restrained pale-cyan shadow, compact circular readability, and progression context. Do not edit, trace, enlarge, copy their pixel style, or preserve Image 2’s plush lobe organization.
Primary request: Candidate A — “Snowmass Leviathan.” Create exactly one isolated Giant Snowball that reads immediately as an enormous physical snowball, dramatically heavier and more monumental than both references. This is the clearest giant-snowball direction: a huge low-set near-sphere assembled from only a few continent-sized masses of deeply compressed snow, divided by broad soft valleys.
Scene/backdrop: genuinely transparent RGBA background, completely empty around the subject.
Subject: one compact near-circular Giant Snowball centered on canvas. Build the body from roughly four to six immense asymmetrical compressed-snow slabs fused into one coherent rolled ball. Each slab is a broad macro-form, not a separate puff: thick load-bearing snow plates press inward around a dense core, with deep wide soft-edged valleys, compacted seam floors, subtle shear lips, and large quiet snow fields between them. The overall sphere settles slightly downward with a broad heavy lower volume and subtly flattened lower hemisphere, yet remains freestanding with no floor or shadow. Keep a controlled powder crust and a restrained irregular fringe attached to the silhouette. Use tiny granular snow texture only as scale contrast against the enormous forms. Make the read unmistakably “giant snowball,” not geology, a planet, or a scaled-up plush ball.
Style/medium: beautiful, striking, compelling premium stylized 3D game-asset concept with polished painterly realism; physically convincing compressed snow and powder; intentionally NOT pixel art, NOT voxel art, and not constrained to a pixel grid.
Composition/framing: square transparent master; exactly one centered subject; front three-quarter sculptural read; compact near-circular collision footprint; subject occupies about 62–66% of canvas width and height including fringe; generous clear transparent padding on every side; no cropping; nothing approaches the canvas edges.
Lighting/mood: broad cool-white upper-left key that reveals the huge slab planes; deep but soft pale-cyan occlusion in major valleys; restrained lower-right cool fill; a subtle pearly rim only along the far edge. Monumental, calm, ancient-feeling mass without fantasy magic, haze, or environmental scale props.
Color palette: pristine bright white snow overwhelmingly dominant; restrained cool white and very pale cyan-blue shadows only; no saturated blue, gray rock tone, beige, dirt, colored accent, or dark outline.
Materials/textures: dense compressed snow beneath a fresh powder crust; broad pressure-polished planes, soft granular seam floors, small packed clods embedded in the surface, sparse frost glints, controlled attached powder fringe; deep self-shadowing that proves immense mass while retaining bright-white readability.
Constraints: exactly one isolated Giant Snowball subject; actual transparent alpha; clear transparent corners; centered; generous padding; compact near-circular footprint; powerful silhouette when reduced; dramatically heavier and more monumental than Big Snowball; broad macro-forms, deep compressed seams, low settled visual weight; physical snowball first.
Avoid: text, letters, numbers, face, eyes, mouth, character, limbs, snowflake silhouette, sixfold arms, UI, scenery, sky, floor, pedestal, cast shadow, icon plate, border, logo, watermark, opaque background, white background, checkerboard pixels, embedded picture, rocks, dirt, metal, separate orbiting debris, detached chunks, floating particles, planet-like surface, continents or maps, craters, mountains, stone boulder, ice planet, moon, cloud, storm cloud, brain, yarn, rope, dough, bread, meringue, dessert, whipped cream, frosting, flower, hard glass ice, gemstone, plain smooth sphere, many small lobes, scaled copy of either reference, excessive glow, bloom, fog, motion trails.
~~~

### Candidate A — targeted transparency retry

~~~text
Use case: background-extraction
Asset type: transparent premium Giant Snowball gameplay-ball concept master
Input images: Image 1 is the edit target, Candidate A “Snowmass Leviathan.”
Primary request: Remove only the entire baked light-gray-and-white checkerboard background from Image 1 and replace it with genuine RGBA transparency. Preserve the single Giant Snowball subject unchanged in structure, shape, scale, position, lighting, pristine-white snow color, macro slab forms, deep valleys, compressed seams, granular snow texture, lower settled weight, and silhouette.
Scene/backdrop: actual alpha transparency everywhere outside the snowball. Do not render a transparency checkerboard. Do not use white, gray, black, or any opaque replacement background.
Composition/framing: preserve the exact centered composition and padding from Image 1; no crop, resize, rotation, relighting, restyling, or added content.
Constraints: change only the background; return exactly one isolated Giant Snowball on genuine transparent alpha; preserve controlled fine powder edge detail and any natural partial-alpha fringe; clean edge with no white/gray matte halo; all four corner pixels must have alpha 0.
Avoid: checkerboard pattern in pixel data, opaque background, replacement color, floor, cast shadow, glow haze, detached particles, text, logo, watermark, subject redesign, circular hard masking, clipped fringe.
~~~

### Candidate B — initial generation

~~~text
Use case: stylized-concept
Asset type: premium Stage 1 Giant Snowball gameplay-ball concept master for future runtime adaptation
Lineage context: The active Big Snowball and historically approved Big Snowball A were inspected only as family references. Carry forward pristine white snow, restrained pale-cyan volume shadow, a compact circular gameplay footprint, and friendly physical snow. Do not copy their pixel style, plush lobe construction, proportions, or surface layout.
Primary request: Candidate B — “Avalanche Juggernaut.” Create exactly one isolated Giant Snowball that reads as a dense rolling colossus with crushing momentum, dramatically heavier and more monumental than a Big Snowball. Its unique structure is a set of powerful diagonal accumulation bands, crushed-powder shelves, and a subtly flattened lower hemisphere.
Scene/backdrop: genuinely transparent RGBA background, completely empty around the subject.
Subject: one coherent near-circular Giant Snowball centered on canvas. Organize the mass with three broad diagonal accumulation bands wrapping obliquely across the visible sphere, each band built from densely rolled and crushed snow rather than rope or a continuous spiral. The bands interlock into a solid core and terminate naturally inside the volume. Their blunt pressure lips create deep diagonal compression seams, compacted shelves, scraped powder facets, and occasional crushed-snow ridges. The lower hemisphere is subtly flattened and over-compressed, giving a broad low center of gravity without any floor. Keep the outer silhouette mostly circular but more forceful and slightly forward-thrusting than Candidate A, with controlled powder breakup only at selected leading edges. It must feel like an avalanche compressed into one devastating rolling snowball.
Style/medium: beautiful, striking, compelling premium stylized 3D game-asset concept with cinematic painterly realism; physically convincing dense rolled snow; intentionally NOT pixel art, NOT voxel art, and not constrained to a pixel grid.
Composition/framing: square transparent master; exactly one centered subject; slight low-eye front three-quarter read suggesting forward rolling momentum without motion blur; compact near-circular collision footprint; subject occupies about 62–66% of canvas width and height; generous clear transparent padding on all sides; no cropping; nothing near canvas edges.
Lighting/mood: strong raking upper-left key crossing the diagonal bands, deep restrained pale-cyan occlusion under pressure shelves, cooler lower-right fill, minimal clean rim. The strongest momentum and physical weight of the set: dense, relentless, grounded, but still pristine bright snow.
Color palette: pristine bright white snow overwhelmingly dominant; cool white and very pale cyan-blue shadows only; no saturated cyan, gray rock mass, beige, dirt, colored accent, black outline, or warm light.
Materials/textures: tightly rolled compressed snow, crushed powder shelves, compacted granular crust, rough shear faces, small embedded snow clods, sparse frost sparkle; controlled attached powder fringe with clean alpha and no matte halo.
Constraints: exactly one isolated Giant Snowball subject; actual transparent alpha; transparent corners; centered; generous padding; compact near-circular footprint; powerful reduced-size silhouette; dramatically beyond Big Snowball; diagonal macro-structure, subtly flattened bottom, immense heavy mass; physical snowball first.
Avoid: text, letters, numbers, face, eyes, mouth, character, limbs, snowflake silhouette, sixfold arms, UI, scenery, sky, floor, pedestal, cast shadow, icon plate, border, logo, watermark, opaque background, white background, checkerboard pixels, embedded picture, rocks, dirt, metal, detached chunks, separate orbiting debris, floating particles, planet-like surface, maps, craters, stone boulder, ice planet, moon, cloud, brain, yarn ball, rope coil, spiral shell, cinnamon roll, rolled dough, bread, pastry, meringue, dessert, whipped cream, frosting, fabric folds, stacked discs, plain smooth sphere, many plush lobes, scaled copy, magical energy, excessive bloom, fog, motion trails.
~~~

### Candidate C — initial generation

~~~text
Use case: stylized-concept
Asset type: premium Stage 1 Giant Snowball gameplay-ball concept master for future runtime adaptation
Lineage context: The active Big Snowball and historically approved Big Snowball A were inspected only as family references. Carry forward pristine bright-white snow, restrained pale-cyan shadow, compact gameplay readability, and the same white-snow family. Do not copy their pixel style, plush lobe organization, proportions, or surface layout.
Primary request: Candidate C — “Polar Behemoth.” Create exactly one isolated Giant Snowball that is the most dramatic and imposing of the set while remaining an unmistakably physical snowball. Its unique structure is a huge bright-white compressed core buried beneath thick wind-packed mantles, with a restrained attached crown of blown powder, deep cool occlusion, and a luminous snow rim.
Scene/backdrop: genuinely transparent RGBA background, completely empty around the subject.
Subject: one coherent near-circular Giant Snowball centered on canvas. Start with an immense dense rounded snow core visible through a few large openings. Wrap it in two or three thick asymmetrical wind-packed mantles that cross the sphere on different broad arcs, overlap heavily, and settle back into the body. Their undersides create deep cool occlusion caverns and powerful self-shadow, while their outer surfaces remain broad, bright, and snow-soft. At the upper rear, form one low attached crown of wind-blown powder: a compact crest and swept granular veil still fused to the ball, never a plume detached into the air. Compress the lower volume into a subtly settled base so the dramatic crown does not make the mass weightless. Keep the footprint compact and near-circular; macro mantles and deep occlusion must communicate enormous scale without scenery.
Style/medium: beautiful, striking, compelling premium heroic stylized 3D game-asset concept with cinematic painterly realism; tactile wind-packed snow and dense compressed powder; intentionally NOT pixel art, NOT voxel art, and not constrained to a pixel grid.
Composition/framing: square transparent master; exactly one centered subject; subtle low-angle front three-quarter sculptural read with no floor; compact near-circular collision footprint; subject occupies about 62–66% of canvas width and height including attached powder crown; generous clear transparent padding on every side; no cropping; no content near canvas edges.
Lighting/mood: most dramatic and imposing candidate: broad cool-white upper-front key across the bright core and mantle tops, deep controlled pale-cyan occlusion beneath overlapping mantles, and a clean luminous cool-white rim from the upper right tracing only the far silhouette and attached crown. Monumental polar brilliance, not magical energy, haze, or bloom.
Color palette: pristine bright white snow overwhelmingly dominant; restrained cool white and very pale cyan-blue depth; no saturated cyan, purple, gray mass, beige, dirt, colored accent, dark outline, or warm light.
Materials/textures: thick wind-packed snow mantles with dense compressed undersides, powder-soft upper crust, broad pressure faces, fine granular breakup along attached lips, compact blown-snow crown, sparse frost sparkle; controlled natural partial-alpha fringe with no matte halo.
Constraints: exactly one isolated Giant Snowball subject; actual transparent alpha; clear transparent corners; centered; generous padding; compact near-circular footprint; strong reduced-size silhouette; dramatically heavier and more monumental than Big Snowball; most imposing while still a physical snowball; attached mantle/crown structure, deep self-shadow, low settled weight.
Avoid: text, letters, numbers, face, eyes, mouth, character, limbs, snowflake silhouette, sixfold arms, UI, scenery, sky, floor, pedestal, cast shadow, icon plate, border, logo, watermark, opaque background, white background, checkerboard pixels, embedded picture, rocks, dirt, metal, detached chunks, separate orbiting debris, floating particles, planet-like surface, maps, craters, ice planet, moon, cloud, storm cloud, smoke, brain, yarn, dough, bread, pastry, meringue, dessert, whipped cream, frosting wave, flower, ocean wave, flame, wing, feather, hard ice shell, gemstone, energy orb, plain smooth sphere, Candidate A slab mosaic, Candidate B diagonal banding, scaled copy, excessive glow, bloom, fog, motion trails.
~~~

### Candidate C — accepted targeted correction

~~~text
Use case: stylized-concept
Asset type: premium Stage 1 Giant Snowball gameplay-ball concept master for future runtime adaptation
Primary request: Targeted correction for Candidate C — “Polar Behemoth.” Create exactly one isolated, enormous physical Giant Snowball. The previous concept’s long wrapping folds read too much like yarn or dough; eliminate all ribbon-like, braided, draped, spiraling, or continuous wrap forms. Preserve the intended identity: the most dramatic and imposing candidate, built from a huge bright-white compressed core under a few thick wind-packed snow mantles, with deep cool occlusion, a restrained attached crown of blown powder, and a luminous snow rim.
Scene/backdrop: genuinely transparent RGBA background, completely empty around the subject.
Subject: one coherent, low-set, compact near-spherical Giant Snowball centered on canvas. Make the massive dense core clearly visible across broad areas. Add only two or three enormous asymmetrical mantle plates of wind-packed snow, each a blunt thick snow shelf with an irregular torn powder lip. The plates should sit on different parts of the core and terminate quickly into it; they must NOT circle, braid, spiral, drape, or wrap continuously around the ball. Create deep shadowed compression caverns beneath the mantle plates and wide quiet core planes between them. At the upper rear, add one low attached powder crown made of compact wind-sculpted snow buildup and short granular cresting, never a flowing plume. Compress and subtly flatten the lower hemisphere into a broad settled mass. The result must look like a real colossal snowball subjected to polar wind and crushing pressure, not fabric, pastry, cloud, geology, or a fantasy orb.
Style/medium: beautiful, striking, compelling premium heroic stylized 3D game-asset concept with cinematic painterly realism; tactile dense compressed snow with a powder crust; intentionally NOT pixel art, NOT voxel art, and not constrained to a pixel grid.
Composition/framing: square transparent master; exactly one centered subject; subtle low-angle front three-quarter sculptural read with no floor; compact near-circular collision footprint; subject occupies about 62–66% of canvas width and height including the low attached crown; generous clear transparent padding on every side; no cropping; nothing near canvas edges.
Lighting/mood: most imposing of the set: broad cool-white upper-front key across the exposed core, deep controlled pale-cyan occlusion inside the mantle caverns, restrained lower fill, and a clean luminous cool-white rim only along the far upper-right silhouette and crown. Monumental polar brilliance without supernatural energy, glow haze, or bloom.
Color palette: pristine bright white snow overwhelmingly dominant; restrained cool white and very pale cyan-blue shadows only; no saturated color, gray rock mass, beige, dirt, dark outline, or warm light.
Materials/textures: thick wind-packed snow plates with dense compressed undersides, broad pressure-polished core, powder-soft crust, irregular granular shelf lips, compact attached crown, small embedded snow clods, sparse frost sparkle; controlled fine alpha fringe with no matte halo.
Constraints: exactly one isolated Giant Snowball; actual transparent alpha and clear transparent corners; centered; generous padding; compact near-circular footprint; dramatically heavier and more monumental than Big Snowball; strongest dramatic silhouette while remaining a physical snowball; low settled weight; no ribbon structure.
Avoid: text, letters, numbers, face, eyes, mouth, character, limbs, snowflake silhouette, UI, scenery, sky, floor, pedestal, cast shadow, icon plate, border, logo, watermark, opaque background, white background, checkerboard pixels, embedded picture, rocks, dirt, metal, detached chunks, orbiting debris, floating particles, planet-like surface, maps, craters, ice planet, moon, cloud, storm cloud, smoke, brain, yarn ball, wool, rope, braid, ribbon, drapery, fabric folds, rolled blanket, dough, bread, pastry, meringue, whipped cream, frosting, croissant, flower, ocean wave, flame, wing, feather, hard ice shell, gemstone, energy orb, smooth sphere, Candidate A slab mosaic, Candidate B diagonal accumulation bands, many plush lobes, scaled copy, excessive glow, bloom, fog, motion trails.
~~~

## Technical and visual validation

All three files have valid PNG signatures and open successfully. B and C have genuine RGBA transparency, clear-black corners, transparent/partial-alpha/opaque pixels, generous padding, centered subjects, and compact near-circular alpha footprints. A remains a valid PNG image but fails the transparent-master contract after its one allowed retry; it is RGB with a baked checkerboard and cannot provide meaningful alpha-bounds metrics.

Margins are left / top / right / bottom at alpha ≥128. Circular ratio is shorter alpha-box axis divided by the longer axis; 1.0000 is a perfect square/circular footprint proxy. Center offsets are relative to the master center.

| Candidate | Dimensions / mode | Alpha | Margins | Alpha-128 box | Circular ratio | Center offset X/Y | SHA-256 |
|---|---:|---:|---:|---:|---:|---:|---|
| A | 1254×1254 RGB | **MISSING — baked checkerboard** | unavailable | unavailable | visual near-circle only | visual center only | 3C89C4C2D7D5E0AD46DE642C74C55FA578D2BE1CA0525F98EDB4A4470F76C022 |
| B | 2048×2048 RGBA | 0..255; corners 0/0/0/0 | 507 / 508 / 509 / 517 | 1032×1023 | 0.9913 | -1.0 / -4.5 px | 97B2960576239FDF08E1063BF0E6E51ACF149C71DFDF0963908B27F5DE96168D |
| C | 2048×2048 RGBA | 0..255; corners 0/0/0/0 | 459 / 442 / 449 / 470 | 1140×1136 | 0.9965 | +5.0 / -14.0 px | 94E9169776CBD3A868A37418AE911FAECF8706639DB4F0E08FF593BC8EC3EAB6 |

Visual inspection at master and reduced sizes confirms:

- one centered subject per candidate
- three different structures rather than palette swaps: slab-valley mass, diagonal crushed shelves, exposed core with short mantle plates/crown
- pristine white dominance and restrained pale-cyan/cool-white depth
- much larger macro-form scale and stronger weight than both Big Snowball lineage references
- no text, face, limbs, snowflake silhouette, UI, scenery, floor, cast shadow, plate, logo, watermark, rocks/dirt/metal, separate orbiting debris, or detached particles in the subjects
- B/C strong silhouette and near-circular footprint after padding normalization

Known limitations:

- A is not a compliant transparent master. Its visually estimated padding is also tighter than the normalized B/C masters because the checkerboard cannot be separated safely for unscaled canvas normalization. Its interior form is usable for direction selection, but runtime adaptation must begin from a fresh transparent generation or carefully selected redraw after user approval. The baked checkerboard must never be treated as alpha.
- B’s banding is intentionally the strongest momentum cue; a later small-size adaptation should keep crushed shelf breaks so it does not collapse into a yarn/rolled-dough icon.
- C’s accepted retry is markedly less yarn-like than its rejected first pass. Its broad quiet core should retain granular snow cues in any reduction so it never becomes an ice planet.

## Historical concept alternatives

- Generated Candidates A/B/C remain intact as historical alternatives and are not active runtime assets.
- Candidate A remains transparency-blocked; B/C remain compliant concept masters but were not selected for runtime.
- Any future switch back to a generated concept requires a new explicit user decision and a separate runtime adaptation/verification task.
