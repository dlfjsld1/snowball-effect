# Ground Snowball Redesign v1

Status: **CANDIDATE A SELECTED HISTORICALLY — USER-AUTHORED NATIVE 16×16 RUNTIME ACTIVE**

Branch: `design/ground-snowflake-redesign`

Target: Stage 1 / Ground / global Lv1 `Snowball`

## Authority and scope

The gameplay-ball workflow remains **one ball at a time**: define one ball, produce exactly three materially different concepts, wait for user selection, then adapt only the selected concept for runtime in a separate task. This package designs Snowball only. It does not redesign Big Snowball or any other ball.

The gameplay-ball concept-art exception also remains authoritative. These masters intentionally ignore [`12_PIXEL_DESIGN_GUIDELINES.md`](../../../12_PIXEL_DESIGN_GUIDELINES.md): they are not pixel art, are not authored on a pixel grid, and are judged first as beautiful, cool, appealing ball concepts. The canonical pixel guideline itself is unchanged. Runtime now uses the user's exact separately authored native-size `16×16` pixel image at Ground local Lv1's current radius `8` / diameter `16`, without resampling the source or changing the circular gameplay footprint.

Candidate A, **Powder Nest**, was explicitly approved by the user on 2026-08-23 and remains the selected historical concept direction. Its generated `64×64` runtime adaptation and the later `15×15` user-authored runtime copy have been superseded by the user's exact native-size `16×16` Snowball asset. Candidates B and C remain unapproved.

The active runtime application adds only the exact user-authored PNG, a truthful Presentation-owned texture wrapper, and the existing LOD mapping. The Powder Nest concept master and generated `64×64` derivative remain preserved as historical/fallback material. The existing native-grid Snowball sprite, Ball/Stage data, Core renderer and simulation, scenes, Goal status, and `project.godot` remain unchanged. The staged Snowflake package and temporary Candidate-B Snowflake runtime preview remain separate and untouched.

## Shared art contract

- exactly one isolated Snowball gameplay-ball subject
- genuinely transparent background
- compact circular collision footprint and strong readable silhouette
- generous transparent padding; centered subject; no cropping
- pristine white dominant with only subtle cool-white / pale icy-blue nuance
- fluffy, soft, powdery, tactile physical snow
- premium polished game-asset concept; intentionally not pixel art
- no text, face, eyes, character limbs, snowflake-shaped silhouette, UI, scenery, floor, cast shadow, icon plate, logo, watermark, opaque background, or illustration painted inside the ball

The built-in outputs were `1254×1254`. Each accepted subject was placed unscaled at the center of a `2048×2048` clear-black transparent canvas to normalize padding. No subject was resampled.

## Candidates

### A — Powder Nest

File: [`candidate-a-powder-nest.png`](candidate-a-powder-nest.png)

The softest and friendliest option. Overlapping plush powder clumps, pillowy dimples, and a lightly scalloped loose-powder fringe create a cozy near-perfect sphere.

### B — Rolled Drift

File: [`candidate-b-rolled-drift.png`](candidate-b-rolled-drift.png)

The most kinetic and tactile option. Broad compressed wrap bands cross the sphere on an oblique axis, with raised accumulation ridges and a slight hand-rolled asymmetry.

### C — Frosted Meringue

File: [`candidate-c-frosted-meringue.png`](candidate-c-frosted-meringue.png)

The most magical and elegant option. Offset wind-swept snow folds, fine rime sparkle, and diffuse pearly luminosity create an airy luxury finish without exposing a jewel or floral hub.

Open [`comparison.html`](comparison.html) for a static side-by-side board. The board is a comparison aid, not a fourth candidate.

## Generation record and exact prompts

Generation mode: Codex `gpt-5.6-sol` work session using built-in `image_gen`. No input images and no CLI/API fallback. A, B, and C each received exactly one initial call. C alone received one targeted corrective regeneration because the initial result formed a forbidden radial rosette; the initial C result is discarded and is not part of this package.

### Prompt A — accepted initial call

```text
Use case: stylized-concept
Asset type: premium Stage 1 gameplay-ball concept master for future sprite production
Primary request: Candidate A — "Powder Nest", an isolated single Snowball gameplay ball: the softest, friendliest direction, a softly compressed near-perfect round snowball made from overlapping plush powder clumps, pillowy dimples, and a restrained loose-powder fringe.
Scene/backdrop: genuinely transparent alpha background, completely empty around the subject.
Subject: exactly one compact physical snowball, centered. Build the whole sphere from many softly overlapping rounded clumps of fresh powder snow, with shallow pillowy dimples between them and a delicate irregular powder fringe around the outer edge. The silhouette stays unmistakably circular and collision-friendly, only lightly scalloped by the plush clumps. It must read as tactile packed snow, not a cloud, pom-pom, flower, snowflake, or sphere carrying an image.
Style/medium: beautiful, cool, highly appealing premium game asset concept; refined stylized 3D sculpt with a polished painterly material finish; intentionally NOT pixel art, NOT voxel art, and NOT constrained to a pixel grid.
Composition/framing: square concept master; one centered subject; front-facing three-quarter dimensional read without visible floor; strong clean silhouette; compact circular collision footprint; generous true-transparent padding of roughly 22% on every side; no cropping.
Lighting/mood: soft broad upper-left studio light, gentle pearly edge lift, low contrast, cozy and welcoming; enough form lighting to reveal dimples without turning gray.
Color palette: pristine bright white overwhelmingly dominant; only subtle cool-white and extremely pale icy-blue shadow and specular nuance; no saturated blue, gray mass, beige, colored accent, or dark outline.
Materials/textures: velvety powder snow, plush soft clumps, airy micro-fluff, sparse snow-grain sparkle embedded in the material; soft but controlled alpha fringe with no matte halo.
Constraints: exactly one isolated Snowball subject; true transparent alpha; centered; circular footprint; adequate padding; premium polished game-asset concept; physically believable fluffy snow.
Avoid: text, face, eyes, mouth, character limbs, snowflake-shaped silhouette, sixfold arms, UI, scenery, floor, pedestal, cast shadow, icon plate, border, logo, watermark, opaque or checkerboard background, illustration painted inside a ball, emblem, broad layered wrap bands or spiral ridges like Candidate B, whipped meringue folds or magical luminous core like Candidate C, detached particles, floating debris, cloud form, flower form, metallic material, glass sphere, hard ice shell, pixel art, excessive bloom.
```

### Prompt B — accepted initial call

```text
Use case: stylized-concept
Asset type: premium Stage 1 gameplay-ball concept master for future sprite production
Primary request: Candidate B — "Rolled Drift", an isolated single Snowball gameplay ball: a dynamic hand-rolled sphere with broad layered wrap bands and subtle accumulation ridges, slightly asymmetrical but clearly circular, more kinetic and tactile than the other directions.
Scene/backdrop: genuinely transparent alpha background, completely empty around the subject.
Subject: exactly one compact physical snowball, centered. Its surface is built from three to five broad overlapping bands of hand-rolled snow that wrap obliquely around the sphere, with softly raised accumulation ridges, compressed seams, and a few feathered drift lips. The bands must follow the spherical volume like snow gathered by rolling, not look like rope, frosting, fabric, petals, or a spiral shell. Give the outline a subtle dynamic lean and mild asymmetry while retaining a strong circular collision footprint and unmistakable snowball identity.
Style/medium: beautiful, cool, highly appealing premium game asset concept; polished stylized 3D snow sculpture with refined painterly realism; intentionally NOT pixel art, NOT voxel art, and NOT constrained to a pixel grid.
Composition/framing: square concept master; one centered subject; dimensional three-quarter read without visible floor; strong readable silhouette; compact circular collision footprint despite slight asymmetry; generous true-transparent padding of roughly 22% on every side; no cropping.
Lighting/mood: crisp raking light from upper left that travels across the wrap ridges, restrained cool fill from lower right, energetic and tactile while still soft and inviting.
Color palette: pristine bright white overwhelmingly dominant; only subtle cool-white and very pale icy-blue shadow and specular nuance; no saturated blue, gray mass, beige, colored accent, or dark outline.
Materials/textures: freshly rolled snow, compressed powder seams, soft accumulation ledges, granular frost, tiny embedded ice glints; soft clean alpha fringe with no matte halo.
Constraints: exactly one isolated Snowball subject; true transparent alpha; centered; circular footprint; adequate padding; premium polished game-asset concept; physically believable fluffy snow.
Avoid: text, face, eyes, mouth, character limbs, snowflake-shaped silhouette, sixfold arms, UI, scenery, floor, pedestal, cast shadow, icon plate, border, logo, watermark, opaque or checkerboard background, illustration painted inside a ball, emblem, separate plush powder clumps and pillowy pom-pom structure like Candidate A, whipped meringue peaks or pearly magical core like Candidate C, detached particles, floating debris, visible hands, rope coil, spiral shell, flower, pastry, fabric folds, metallic material, glass sphere, hard ice shell, pixel art, excessive bloom.
```

### Prompt C1 — initial call, discarded after visual inspection

```text
Use case: stylized-concept
Asset type: premium Stage 1 gameplay-ball concept master for future sprite production
Primary request: Candidate C — "Frosted Meringue", an isolated single Snowball gameplay ball: a luxurious compact snowball with airy whipped-snow folds, fine crystalline sparkle, and a bright pearly core, the most magical and elegant direction while still unmistakably a physical snowball.
Scene/backdrop: genuinely transparent alpha background, completely empty around the subject.
Subject: exactly one compact physical snowball, centered. Shape the sphere from airy swept folds of fresh whipped snow that rise and settle back into the round volume, with elegant soft crests, shallow valleys, and fine crystalline rime along selected fold edges. A bright pearly snow core should glow subtly through the central volume, never becoming a visible orb, jewel, emblem, hole, or picture. Keep all folds compact inside a strong near-circular silhouette so it remains clearly a snowball rather than a pastry, flower, cloud, or magical energy sphere.
Style/medium: beautiful, cool, highly appealing premium fantasy game asset concept; luxurious stylized 3D snow sculpture with polished painterly rendering; intentionally NOT pixel art, NOT voxel art, and NOT constrained to a pixel grid.
Composition/framing: square concept master; one centered subject; dimensional front three-quarter read without visible floor; strong readable silhouette; compact circular collision footprint; generous true-transparent padding of roughly 22% on every side; no cropping.
Lighting/mood: most magical and elegant of the three; contained pearly inner luminosity, soft upper-front key, delicate cool rim, fine pinpoint crystalline speculars; radiant but not blown out.
Color palette: pristine bright white overwhelmingly dominant; only subtle cool-white and extremely pale icy-blue shadow and specular nuance; no saturated cyan, purple, gray mass, beige, rainbow, colored accent, or dark outline.
Materials/textures: airy whipped powder snow, soft sculpted folds, delicate rime crystals, fine embedded sparkle, luminous dense snow at the core; clean controlled alpha edge with no matte halo.
Constraints: exactly one isolated Snowball subject; true transparent alpha; centered; circular footprint; adequate padding; premium polished game-asset concept; physically tactile snow despite the magical elegance.
Avoid: text, face, eyes, mouth, character limbs, snowflake-shaped silhouette, sixfold arms, UI, scenery, floor, pedestal, cast shadow, icon plate, border, logo, watermark, opaque or checkerboard background, illustration painted inside a ball, emblem, plush separate clump construction and dimples like Candidate A, hand-rolled layered wrap bands or accumulation ridges like Candidate B, detached particles, floating debris, frosting rosette, pastry, meringue cookie, flower, cloud, energy orb, visible pearl or jewel, metallic material, glass sphere, hard ice shell, pixel art, large bloom cloud.
```

### Prompt C2 — accepted targeted correction

```text
Use case: stylized-concept
Asset type: premium Stage 1 gameplay-ball concept master for future sprite production
Primary request: Targeted correction for Candidate C — "Frosted Meringue". Generate one isolated luxurious physical snowball with airy whipped-snow folds, fine crystalline sparkle, and a diffuse bright pearly core. The previous radial rosette/flower read is forbidden: this version must read as an irregular compact snow sphere first.
Scene/backdrop: genuinely transparent alpha background, completely empty around the subject.
Subject: exactly one compact physical snowball, centered. Form a near-perfect sphere of fresh packed powder whose surface has several broad, airy wind-swept snow folds crossing at different offsets and directions. The folds should be asymmetrical natural snow drifts laid over a round ball, with soft crests that settle back into the volume, never radial petals, never a central spiral, never a flower hub, never frosting. Show a subtle diffuse pearly luminosity embedded throughout the dense snowy interior; do not expose a separate orb, jewel, emblem, hole, or central picture. Preserve fine rime crystals and restrained sparkle on selected fold edges. It must remain unmistakably tactile physical snow.
Style/medium: beautiful, cool, highly appealing premium fantasy game asset concept; luxurious stylized 3D snow sculpture with polished painterly rendering; intentionally NOT pixel art, NOT voxel art, and NOT constrained to a pixel grid.
Composition/framing: square concept master; one centered subject; dimensional three-quarter read without visible floor; compact circular collision footprint; subject occupies no more than about 58% of canvas width or height; very generous transparent padding on every side; no cropping; no visible content near canvas edges.
Lighting/mood: most magical and elegant of the set; contained diffuse pearly inner luminosity, soft upper-front key, delicate cool rim, fine pinpoint crystalline speculars; radiant but not blown out.
Color palette: pristine bright white overwhelmingly dominant; only subtle cool-white and extremely pale icy-blue shadow and specular nuance; no saturated cyan, purple, gray mass, beige, rainbow, colored accent, or dark outline.
Materials/textures: airy whipped powder snow understood as natural wind-sculpted snowdrifts, soft packed snow, delicate rime crystals, fine embedded sparkle; clean controlled alpha edge with no matte halo.
Constraints: exactly one isolated Snowball subject; true transparent alpha; centered; circular footprint; generous padding; premium polished game-asset concept; physically tactile snow; visibly distinct from plush clump construction and rolled wrap bands.
Avoid: text, face, eyes, mouth, character limbs, snowflake-shaped silhouette, sixfold arms, UI, scenery, floor, pedestal, cast shadow, icon plate, border, logo, watermark, opaque or checkerboard background, illustration painted inside a ball, emblem, radial symmetry, rosette, rose, flower, petals, central blossom, spiral frosting, frosting mound, pastry, meringue cookie, whipped cream, cloud, energy orb, visible pearl or jewel, plush separate clumps like Candidate A, regular hand-rolled layered wrap bands like Candidate B, detached particles, floating debris, metallic material, glass sphere, hard ice shell, pixel art, large bloom cloud.
```

## Validation record

All three final files were visually inspected at master size after transparent-canvas normalization. PNG signature is `89 50 4E 47 0D 0A 1A 0A` for every file; corner ARGB is clear black `0/0/0/0`; every file contains fully transparent, partially transparent, and alpha-255 subject pixels.

Margins are measured as left / top / right / bottom at alpha `>= 128`. Circular ratio is the shorter divided by longer alpha-128 bounding-box axis; `1.000` is a perfect circle.

| Candidate | Dimensions | Alpha | Margins | Alpha-128 box | Circular ratio | Center offset X/Y | SHA-256 |
|---|---:|---:|---:|---:|---:|---:|---|
| A | `2048×2048` | `0..255` | `532 / 520 / 530 / 527` | `986×1001` | `0.985` | `+1.0 / -3.5` | `49961C6044AC43D989B5D073D569FD4190F2A8AF6FA1DD2206CCC1B831D9AE4F` |
| B | `2048×2048` | `0..255` | `560 / 525 / 541 / 541` | `947×982` | `0.964` | `+9.5 / -8.0` | `F845ABDF210AB75A6EC45DC919568CF43A767114AAD4DF41D423DE68446CED3E` |
| C | `2048×2048` | `0..255` | `615 / 591 / 603 / 598` | `830×859` | `0.966` | `+6.0 / -3.5` | `16B0E923E238CF8ADECF809219BDA6DDBB84831E1492DA309896DA4D9D66A79F` |

Visual inspection confirms one centered subject per file, pristine white dominance, soft snow material, circular footprints, and no forbidden text, face, limbs, snowflake silhouette, UI, scenery, floor, cast shadow, plate, logo, watermark, or opaque background. The candidates differ by clumped/dimpled, rolled/banded, and airy/rimed surface construction rather than color swaps.

## Runtime application and supersession record

- Historical concept selection: Candidate A, Powder Nest, only.
- Active runtime asset: `assets/sprites/balls/ground/runtime/ball_lv01_snowball_user_authored_16.png`, an exact `16×16`, `693`-byte copy of the user's authored PNG with SHA-256 `1F8831BAC0A24AC796195D1B03F1825BC49ED6EA99479D784D5E9AD4D0C7858E`.
- Active wrapper: `assets/sprites/balls/ground/runtime/ball_lv01_snowball_user_authored_16.tres`, with nearest-neighbor filtering and repeat disabled. Import is lossless, preserves alpha with alpha-border fix enabled, and keeps mipmaps disabled.
- Runtime target: Ground local Lv1 / global level 1 at the unchanged radius `8` / diameter `16`.
- Superseded fallback: `ball_lv01_snowball_powder_nest_64.{png,tres}` remains preserved and loadable but is no longer selected by the active LOD catalog. The immediately superseded `ball_lv01_snowball_user_authored_15.{png,tres}` copy was removed after becoming orphaned.
- B/C remain concept alternatives only and are not approved or runtime-bound.
- Additional LODs and any redesign of Big Snowball or later balls remain deferred.
