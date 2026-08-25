# Ground Big Snowball Redesign v1

Status: **CANDIDATE A APPROVED HISTORICALLY — USER-AUTHORED NATIVE 32×32 RUNTIME ACTIVE**

Branch: `design/ground-snowflake-redesign`

Target: Stage 1 / Ground / global Lv2 `Big Snowball`

## Authority and scope

The gameplay-ball redesign workflow is **one ball at a time**: define one ball, produce exactly three materially different concepts, wait for explicit user selection, then adapt only the selected concept for runtime in a separate task. The user approved only Candidate A, Avalanche Pillow, for Big Snowball runtime adaptation. Candidates B and C remain unapproved.

The gameplay-ball concept-art exception is active. These masters intentionally ignore the strict pixel-art production rules in [`12_PIXEL_DESIGN_GUIDELINES.md`](../../../12_PIXEL_DESIGN_GUIDELINES.md): they are premium non-pixel concept art, not production sprites. The canonical guideline is unchanged. Candidate A remains the approved historical concept direction, while the active gameplay texture is now the user's exact native-size `32×32` pixel asset. It supersedes the generated `128×128` Avalanche Pillow runtime adaptation without changing Ground local Lv2 radius `16` / diameter `32`. This correction changes only Presentation assets, wrappers, the existing LOD catalog binding, and approval/runtime records; Content data, scenes, Goal status, and `project.godot` remain unchanged.

The approved Snowball A master, [`candidate-a-powder-nest.png`](../ground-snowball-redesign-v1/candidate-a-powder-nest.png), is a family-lineage reference only. Big Snowball retains its pristine fluffy powder language and cool-white light, but advances through fewer and much larger forms, deeper self-shadowing, broader mass, and stronger lower-volume compression. None of the candidates is an edit or scaled copy of Powder Nest.

## Approval and runtime adaptation record

- Approved: Candidate A, [`candidate-a-avalanche-pillow.png`](candidate-a-avalanche-pillow.png), on 2026-08-23. Its source remains byte-identical at SHA-256 `490E675FD8EAFEC3E48F5F43636EE0DBAF79B51EB67C7482A185E1D80CE86587`.
- Not approved: Candidate B, Packed Colossus, and Candidate C, Whiteout Titan.
- Readability reference: [`Snowball_JE3_BE3.webp`](Snowball_JE3_BE3.webp), SHA-256 `DCB69EDBBA40BBF1DC4E02912F23B89CAB05C1ADB977BA178F5B051D54973D2F`, was inspected but not edited. Its compact circular read, pristine bright center/highlight, and pale-cyan lower/right volume informed what had to survive at gameplay size. Its pixel grid did not inform the rendering style: Avalanche Pillow remains non-pixel art, and no reference pixels or shapes were copied.
- Active runtime asset: `assets/sprites/balls/ground/runtime/ball_lv02_big_snowball_user_authored_32.png`, an exact `32×32`, `2,223`-byte copy of the user's authored RGBA PNG with SHA-256 `0A657099F3FB2EDE49416B175F5FF16121A1A9157B710402FDE229D80AB82130`.
- Active wrapper: `assets/sprites/balls/ground/runtime/ball_lv02_big_snowball_user_authored_32.tres`, with nearest-neighbor filtering and repeat disabled. Import is lossless, preserves alpha with alpha-border fix enabled, and keeps mipmaps disabled.
- Superseded generated fallback: `ball_lv02_big_snowball_avalanche_pillow_128.{png,tres}` remains preserved and loadable but is no longer selected by the active LOD catalog.
- Historical `15×15` experiment: the exact `675`-byte user-authored PNG with SHA-256 `71EBDD5BC16BBD0C1BD2B1B01AC9280CC9050C8D0BC408A6265C5A2489FC677B` was previously reassigned to Ground Lv1, then its active copy was superseded and removed when the exact native `16×16` Lv1 asset arrived.
- Runtime mapping: the dedicated user-authored `CanvasTexture` is selected only for Ground global Lv2 at runtime diameter `32`. The existing Ground local Lv2 collision radius `16`, MultiMesh transform, Content catalog, Lv0 mapping, corrected Lv1 mapping, and every other level mapping remain unchanged.

## Shared art contract

- exactly one isolated Big Snowball gameplay-ball subject
- genuinely transparent background, centered subject, and generous padding
- compact near-circular collision footprint with a strong 96px silhouette
- visibly denser, broader, heavier, and more imposing than approved Snowball A
- dominant pristine white with cool-white and pale icy-blue volume shadows
- tactile powder, controlled loose-snow edges, compressed mass, and physical weight
- premium stylized 3D/painterly concept; intentionally not pixel art
- no text, face, eyes, limbs, snowflake silhouette, UI, scenery, floor, cast shadow, icon plate, logo, watermark, opaque background, embedded picture, rocks/dirt, or separate orbiting pieces
- avoid cloud, brain, yarn ball, meringue dessert, ice crystal, plain smooth sphere, and scaled-copy reads

## Candidate progression rationale

| Candidate | Structural organization | Progression from Powder Nest | Primary tradeoff |
|---|---|---|---|
| A — Avalanche Pillow | Five to seven enormous compressed powder lobes, deep curved seams, fuller base | Closest family continuity, but replaces many small clumps with a few huge load-bearing masses | Friendliest and fluffiest; least radical silhouette change |
| B — Packed Colossus | Three to four staggered compression shelves around a dense rolled core | Reorganizes the family material into pressure ledges, scraped packed snow, and a subtly flattened lower hemisphere | Strongest weight and momentum; shelves can approach a folded-dough read at a glance |
| C — Whiteout Titan | Dense rounded core under sweeping wind-packed mantles and an attached raised crest | Keeps the snow material while shifting from clumps to directional mantle flow and heroic rim light | Most dramatic; smoother core feels slightly icier than A |

Open [`comparison.html`](comparison.html) for the static three-way board. The board reuses the same three masters and is not a fourth candidate.

## Generation record

Mode: Codex `gpt-5.6-sol` session using built-in `image_gen` only. Image 1 in every initial call was the approved Powder Nest master, explicitly labeled as a lineage reference rather than an edit target. Each candidate received exactly one initial generation call.

All three initial files were returned as opaque 24-bit RGB images with a baked white/gray transparency checkerboard. Each candidate then received its single permitted targeted retry through built-in `image_gen`, strictly requesting background extraction while preserving the subject. Those retries also returned opaque 24-bit RGB checkerboards. No CLI, API, alternate model, or silent fallback was used.

To meet the required transparent-master contract without another generation retry, the accepted subject renders received a deterministic technical alpha repair only: center-weighted cool-shadow/luminance evidence defined the subject, a heavily smoothed radial envelope preserved the required compact near-circular footprint, the envelope edge was antialiased, transparent RGB was cleared to black, and only checker-like neutral pixels inside the envelope were normalized to cool snow white. The operation did not resample, rotate, relight, or regenerate the subject. This repair makes the perimeter more controlled and less wispy than the originally requested loose fringe; selection should judge the interior form/material direction, with final edge cleanup deferred to a selected runtime adaptation.

### Prompt A — initial generation

```text
Use case: stylized-concept
Asset type: premium Stage 1 gameplay-ball concept master for future sprite production
Input images: Image 1 is the approved Stage 1 Snowball A “Powder Nest” master, used only as a family-lineage reference for pristine fluffy snow material, soft rounded volume, restrained pale-blue shadows, and premium finish. Do not edit it, trace it, enlarge it, or make a scaled copy.
Primary request: Candidate A — “Avalanche Pillow,” exactly one isolated Big Snowball gameplay ball. This is the friendly massive direction: a broad, low-centered near-sphere built from only a few enormous compressed powder lobes, visibly denser, broader, heavier, and more imposing than Image 1 while staying plush and inviting.
Scene/backdrop: genuinely transparent alpha background, completely empty around the subject.
Subject: exactly one compact physical Big Snowball, centered. Build the volume from roughly five to seven huge asymmetrical pillow-like masses of packed powder, not many small clumps. Let the lobes press hard into one another, creating deep curved seams, substantial self-occlusion, and a subtly compressed lower hemisphere that feels planted and weight-bearing even with no floor or shadow. The upper and side silhouette has a restrained soft loose-snow fringe; the bottom is fuller and denser. Keep the overall collision footprint near-circular and unmistakably spherical, not a horizontal pile. Preserve fresh tactile snow and family resemblance to Image 1, but make the construction larger-scale and structurally more massive.
Style/medium: beautiful, compelling, premium stylized 3D game-asset concept with polished painterly realism; tactile physical snow; intentionally NOT pixel art, NOT voxel art, and NOT constrained to a pixel grid.
Composition/framing: square master; exactly one centered subject; front three-quarter dimensional read; compact near-circular footprint; subject occupies about 56–60% of canvas width and height; generous genuine transparent padding on every side; no cropping and no visible content near the canvas edge.
Lighting/mood: soft broad upper-left key like the approved family master, but with deeper cool self-shadow inside the major seams and a gentle pearly edge lift; friendly, luxurious, calm, and clearly weighty; preserve bright-white readability at small size.
Color palette: dominant pristine bright white snow; subtle cool white and very pale icy-blue volume shadows only; no saturated blue, gray mass, beige, dirt, colored accent, or dark outline.
Materials/textures: velvety fresh powder over convincing compressed mass, soft granular micro-fluff, tiny embedded snow sparkle, plush fringe controlled tightly to the sphere; clean semi-transparent snow fibers at the edge with no matte halo.
Constraints: exactly one isolated Big Snowball subject; true transparent alpha; strong small-size silhouette; centered; generous padding; compact circular collision footprint; visibly a next tier above Image 1; physical weight plus fluffy snow.
Avoid: text, face, eyes, mouth, character, limbs, snowflake silhouette, sixfold arms, UI, scenery, floor, pedestal, cast shadow, icon plate, border, logo, watermark, checkerboard or opaque background, embedded picture, rocks, dirt, separate orbiting pieces, detached chunks, floating debris, many small Powder Nest clumps, scaled-copy structure, cloud, cumulonimbus, brain, yarn ball, pom-pom, meringue, dessert, whipped cream, flower, ice crystal, gemstone, hard ice shell, plain smooth sphere, flattened snow pile, pillow stack, excessive bloom.
```

### Prompt B — initial generation

```text
Use case: stylized-concept
Asset type: premium Stage 1 gameplay-ball concept master for future sprite production
Input images: Image 1 is the approved Stage 1 Snowball A “Powder Nest” master, used only as a family-lineage reference for pristine fluffy snow material, soft cool-white volume, restrained pale-blue shadows, and premium finish. Do not edit it, trace it, enlarge it, or repeat its clump organization.
Primary request: Candidate B — “Packed Colossus,” exactly one isolated Big Snowball gameplay ball. This is the densest physical direction: a massive rolled snow boulder organized by thick overlapping compression shelves, clearly broader, heavier, more imposing, and more momentum-charged than Image 1.
Scene/backdrop: genuinely transparent alpha background, completely empty around the subject.
Subject: exactly one compact physical Big Snowball, centered. Construct a dense near-spherical rolled boulder from three or four very broad compressed snow shelves that overlap around the volume on staggered oblique paths. These are thick geological-scale pressure ledges made of snow, with blunt accumulation lips, deep compressed seams, scraped granular patches, and a subtly flattened lower hemisphere that carries obvious mass. The shelves must interlock around a solid core rather than form a continuous spiral or rope. Keep the outer footprint compact and near-circular with only restrained ruggedness. It should feel capable of rolling with crushing momentum, yet remain pristine fluffy snow rather than rock, ice, or a smooth sphere.
Style/medium: beautiful, compelling, premium stylized 3D game-asset concept with sophisticated painterly material rendering; physically convincing rolled snow; intentionally NOT pixel art, NOT voxel art, and NOT constrained to a pixel grid.
Composition/framing: square master; exactly one centered subject; slight low-eye three-quarter read without any ground; compact near-circular collision footprint; subject occupies about 56–60% of canvas width and height; generous genuine transparent padding on every side; no cropping and no visible content near the canvas edge.
Lighting/mood: stronger raking upper-left key than the family reference, crossing the pressure shelves; deep but clean pale icy-blue seam shadows; restrained lower-right cool fill; strongest sense of solidity, weight, and forward momentum while remaining mostly bright white.
Color palette: dominant pristine white snow; cool white and pale icy-blue depth only; no saturated blue, dark gray mass, beige, dirt, colored accents, or black outline.
Materials/textures: tightly packed rolled snow, dense compression crust that still breaks into powder at shelf lips, granular frost, subtle rough scraped patches, sparse crystalline glints; clean soft alpha fringe with no matte halo.
Constraints: exactly one isolated Big Snowball subject; true transparent alpha; strong small-size silhouette; centered; generous padding; compact circular collision footprint; visibly the next heavier tier above Image 1; densest of the three candidates.
Avoid: text, face, eyes, mouth, character, limbs, snowflake silhouette, sixfold arms, UI, scenery, floor, pedestal, cast shadow, icon plate, border, logo, watermark, checkerboard or opaque background, embedded picture, rocks, dirt, gravel, separate orbiting pieces, detached chunks, floating debris, Powder Nest-style many rounded lobes, scaled copy, cloud, brain, yarn ball, rope coil, spiral shell, cinnamon roll, meringue, dessert, whipped frosting, fabric folds, ice crystal, gemstone, hard blue ice, stone boulder, plain smooth sphere, stacked flat discs, excessive bloom.
```

### Prompt C — initial generation

```text
Use case: stylized-concept
Asset type: premium Stage 1 gameplay-ball concept master for future sprite production
Input images: Image 1 is the approved Stage 1 Snowball A “Powder Nest” master, used only as a family-lineage reference for pristine powder material, soft cool-white dimensional shading, delicate loose-snow edges, and premium finish. Do not edit it, trace it, enlarge it, or repeat its clump structure.
Primary request: Candidate C — “Whiteout Titan,” exactly one isolated Big Snowball gameplay ball. This is the most dramatic heroic direction: a grand dense rounded snow core wrapped by sweeping wind-packed snow mantles, with one restrained raised powder crest and a luminous rim, visibly broader, heavier, more imposing, and more monumental than Image 1 while remaining a physical snowball.
Scene/backdrop: genuinely transparent alpha background, completely empty around the subject.
Subject: exactly one compact physical Big Snowball, centered. Begin with a massive rounded packed-snow core. Wrap it with two or three broad asymmetrical mantles of wind-driven snow that sweep across different arcs and settle tightly back into the spherical volume. Give the upper silhouette one low raised powder crest pushed by wind, plus a trailing mantle edge that remains attached to the body; no detached pieces. Use deep under-mantle self-shadowing and compressed lower volume to preserve unmistakable weight. The silhouette may be slightly crowned and dynamic but must retain a compact near-circular collision footprint. Make it look like a powerful whiteout sculpted a real heavy snowball, not a magical cloud, wave, pastry, or smooth orb.
Style/medium: beautiful, compelling, premium heroic stylized 3D game-asset concept with polished painterly realism; cinematic but physically tactile snow; intentionally NOT pixel art, NOT voxel art, and NOT constrained to a pixel grid.
Composition/framing: square master; exactly one centered subject; subtle low-angle front three-quarter dimensional read without any floor; compact near-circular collision footprint; subject occupies about 56–60% of canvas width and height including the attached crest; generous genuine transparent padding on every side; no cropping and no visible content near canvas edges.
Lighting/mood: most dramatic of the set: broad upper-front key, deep controlled pale icy-blue shadow beneath the mantles, and a clean luminous cool-white rim from upper right that traces the crest and far edge; heroic, monumental, bright, and premium without supernatural glow or bloom haze.
Color palette: pristine white overwhelmingly dominant; cool white and pale icy-blue volume shadows and rim nuance only; no saturated cyan, purple, gray mass, beige, dirt, colored accent, or dark outline.
Materials/textures: wind-packed powder, broad soft snow mantles with compacted undersides, crisp but snowy crest, soft granular breakup along attached edges, sparse embedded frost sparkle; clean semi-transparent snow fringe with no matte halo.
Constraints: exactly one isolated Big Snowball subject; true transparent alpha; strong small-size silhouette; centered; generous padding; compact circular footprint; visibly the heroic next tier above Image 1; dramatic but physically heavy; no separate effects.
Avoid: text, face, eyes, mouth, character, limbs, snowflake silhouette, sixfold arms, UI, scenery, floor, pedestal, cast shadow, icon plate, border, logo, watermark, checkerboard or opaque background, embedded picture, rocks, dirt, separate orbiting pieces, detached chunks, floating debris, Powder Nest-style many plush lobes, scaled copy, Candidate B-style stacked compression shelves, cloud, storm cloud, smoke, brain, yarn ball, meringue, dessert, whipped cream, frosting wave, croissant, flower, ocean wave, flame, wing, feather, ice crystal, gemstone, energy orb, hard ice shell, plain smooth sphere, spiral, radial rosette, excessive bloom.
```

### Targeted retry prompt A — background extraction

```text
Use case: background-extraction
Asset type: transparent premium gameplay-ball concept master
Input images: Image 1 is the edit target, Candidate A “Avalanche Pillow.”
Primary request: Remove only the entire baked white-and-light-gray checkerboard background and replace it with genuine transparent alpha. Preserve the single Big Snowball subject itself unchanged in design, shape, scale, position, lighting, pristine-white color, deep seams, powder texture, and edge detail.
Scene/backdrop: actual RGBA transparency everywhere outside the snowball, not a rendered checkerboard, not white, not gray, not an opaque transparency preview.
Composition/framing: keep exactly the same centered composition and generous padding; no crop, resize, rotation, or added content.
Constraints: change only the background; return one isolated subject on genuine transparent alpha; preserve fine semi-transparent loose-snow fibers at the silhouette; clean edge with no white or gray matte halo; transparent corner pixels must have alpha 0.
Avoid: any checkerboard pattern in pixel data, opaque background, replacement color, floor, cast shadow, glow cloud, detached particles, text, logo, watermark, subject redesign, retouching, smoothing, sharpening, or material changes.
```

### Targeted retry prompt B — background extraction

```text
Use case: background-extraction
Asset type: transparent premium gameplay-ball concept master
Input images: Image 1 is the edit target, Candidate B “Packed Colossus.”
Primary request: Remove only the entire baked white-and-light-gray checkerboard background and replace it with genuine transparent alpha. Preserve the single Big Snowball subject itself unchanged in design, shape, scale, position, lighting, pristine-white color, compression shelves, powder texture, and edge detail.
Scene/backdrop: actual RGBA transparency everywhere outside the snowball, not a rendered checkerboard, not white, not gray, not an opaque transparency preview.
Composition/framing: keep exactly the same centered composition and generous padding; no crop, resize, rotation, or added content.
Constraints: change only the background; return one isolated subject on genuine transparent alpha; preserve fine semi-transparent loose-snow fibers at the silhouette; clean edge with no white or gray matte halo; transparent corner pixels must have alpha 0.
Avoid: any checkerboard pattern in pixel data, opaque background, replacement color, floor, cast shadow, glow cloud, detached particles, text, logo, watermark, subject redesign, retouching, smoothing, sharpening, or material changes.
```

### Targeted retry prompt C — background extraction

```text
Use case: background-extraction
Asset type: transparent premium gameplay-ball concept master
Input images: Image 1 is the edit target, Candidate C “Whiteout Titan.”
Primary request: Remove only the entire baked white-and-light-gray checkerboard background and replace it with genuine transparent alpha. Preserve the single Big Snowball subject itself unchanged in design, shape, scale, position, lighting, pristine-white color, sweeping wind mantles, raised powder crest, luminous rim, texture, and edge detail.
Scene/backdrop: actual RGBA transparency everywhere outside the snowball, not a rendered checkerboard, not white, not gray, not an opaque transparency preview.
Composition/framing: keep exactly the same centered composition and generous padding; no crop, resize, rotation, or added content.
Constraints: change only the background; return one isolated subject on genuine transparent alpha; preserve fine semi-transparent loose-snow fibers at the silhouette and luminous rim without a glow cloud; clean edge with no white or gray matte halo; transparent corner pixels must have alpha 0.
Avoid: any checkerboard pattern in pixel data, opaque background, replacement color, floor, cast shadow, glow cloud, detached particles, text, logo, watermark, subject redesign, retouching, smoothing, sharpening, or material changes.
```

## Validation record

All three final files were visually inspected at full size on transparent/dark presentation and together at 96px. The 96px review preserves three distinct reads: giant lobes, pressure shelves, and sweeping mantles. Each file has a valid PNG signature (`89 50 4E 47 0D 0A 1A 0A`), RGBA data, alpha `0..255`, partially transparent edge pixels, alpha-zero corners, and clear-black RGB in every fully transparent pixel.

Margins are left / top / right / bottom at alpha `>= 128`. Circular ratio is the shorter divided by the longer alpha-128 bounding-box axis; `1.000` is a perfect circle. Center offset is relative to the canvas center.

| Candidate | Dimensions | Alpha | Margins | Alpha-128 box | Circular ratio | Center offset X/Y | Mean subject RGB | SHA-256 |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| A | `1254×1254` | `0..255` | `141 / 164 / 144 / 151` | `969×939` | `0.969` | `-1.5 / +6.5` | `210.8 / 218.8 / 233.8` | `490E675FD8EAFEC3E48F5F43636EE0DBAF79B51EB67C7482A185E1D80CE86587` |
| B | `1254×1254` | `0..255` | `178 / 187 / 168 / 159` | `908×908` | `1.000` | `+5.0 / +14.0` | `205.5 / 215.1 / 230.2` | `E6C41B89DB4CFEAC64DDC3E794EB9F62FD8817A9C4D1F28EF873D1F44145C979` |
| C | `1254×1254` | `0..255` | `156 / 152 / 123 / 117` | `975×985` | `0.990` | `+16.5 / +17.5` | `196.7 / 207.7 / 223.5` | `F7DEC4FE1A8EDA628E1516F8772512D82B4C825AC2198A2BA22F3FAE939EB34B` |

Visual inspection confirms one centered subject per master, dominant pristine-white snow, meaningful cool depth, clear tier growth from Powder Nest, and no forbidden text, face, limbs, snowflake silhouette, UI, scenery, floor, cast shadow, plate, logo, watermark, embedded image, rocks/dirt, or separate pieces. The candidates are materially distinct through lobed, shelf-compressed, and mantle-wrapped construction rather than color swaps.

## Selection handoff

- Candidate A, Avalanche Pillow, remains the approved historical concept direction; its generated `128×128` derivative is a preserved fallback.
- The user's exact native-size `32×32` pixel asset is the active Ground global Lv2 runtime visual at the unchanged diameter `32`.
- The user's exact native-size `16×16` pixel asset is the active Ground global Lv1 runtime visual at the unchanged diameter `16`.
- Candidates B and C remain concept-only and unapproved.
- Earlier Snowflake remains separate and unchanged; the Snowball package records the Lv1 runtime supersession.
