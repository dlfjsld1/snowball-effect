# Ground Snowflake Redesign v1

Status: **CANDIDATE B SELECTED — temporary runtime preview active**

Branch: `design/ground-snowflake-redesign`

Target: Stage 1 / Ground / global Lv0 `Snowflake`

## One-ball-at-a-time workflow

Gameplay Ball 디자인은 앞으로 한 번에 한 공만 진행한다.

1. 한 공의 역할과 미감 목표를 고정한다.
2. 그 공에 대해 서로 실질적으로 다른 후보를 정확히 3개 만든다.
3. 사용자가 한 후보를 선택하거나 재탐색 방향을 준다.
4. 선택된 후보만 별도 작업에서 실제 gameplay 크기에 맞게 축약·제작하고 runtime에 연결한다.
5. 검증과 승인이 끝난 뒤 다음 공으로 이동한다.

이 패키지에서 후보 생성 뒤 B `Frost Blossom`이 선택됐고, gameplay 확인용 `32×32` derivative가 global Lv0의 diameter `8` LOD에 임시 연결됐다. 최종 production 승인이나 physics/catalog 변경을 뜻하지 않는다.

## Gameplay-ball pixel-guideline exemption

이 패키지의 gameplay-ball concept art는 [`12_PIXEL_DESIGN_GUIDELINES.md`](../../../12_PIXEL_DESIGN_GUIDELINES.md)의 pixel grid, logical-pixel block, nearest-only authoring, fixed native LOD, pixel-palette cleanup 규칙을 **의도적으로 적용하지 않는다**. 아름답고 강렬하며 매력적인 Ball 자체를 먼저 찾는 것이 우선이다. 세 후보는 pixel art가 아니며 pixel grid에 맞추지 않았다.

이 예외는 renderer·physics·Content catalog를 수정하는 승인과 동일하지 않다. 현재는 선택안의 비픽셀 미감을 비교하기 위해 Presentation LOD catalog만 `ball_lv00_snowflake_frost_blossom_preview_32.tres`에 연결하며, 기존 `ball_lv00_snowflake_8.png`, BallDefinition, Scene, `project.godot`은 그대로 유지한다.

## Shared art contract

- isolated single Snowflake gameplay-ball subject
- genuinely transparent background
- compact near-circular collision footprint with generous transparent padding
- small-size-readable sixfold silhouette
- pristine bright white as the dominant material/color
- only soft cool-white and very pale icy-blue shading for volume
- fluffy, soft, powdery snow feel while unmistakably snowflake-like
- no text, face, eyes, limbs, UI frame, scenery, logo, watermark, floor shadow, icon plate, opaque background, or painted-on emblem
- premium, polished, striking game-asset concept; not pixel art

All three masters are `2048×2048` transparent PNGs. The generated subject pixels were placed unscaled on a larger transparent canvas to normalize production padding; no concept was resampled.

## Candidates

### A — Powder Puff Crystal

File: [`candidate-a-powder-puff-crystal.png`](candidate-a-powder-puff-crystal.png)

The softest and friendliest direction. Six short arms are built from plush powder-snow bulbs and clustered tufts around a dense snowy core. The rounded, tactile silhouette is intended to read as fresh snow before it reads as ice.

### B — Frost Blossom

File: [`candidate-b-frost-blossom.png`](candidate-b-frost-blossom.png)

The graceful and ornate direction. Six tapered arms use feathered hoarfrost petals, open notches, crystalline leaf-like ridges, and a luminous snowy core. It is more delicate and ceremonial than A while remaining a physical snowflake rather than a decorated sphere.

### C — Halo Flurry

File: [`candidate-c-halo-flurry.png`](candidate-c-halo-flurry.png)

The strongest magical direction. Broad wind-swept snow plumes curl through layered rime structures around a radiant core. The silhouette is denser and more kinetic than B, with halo energy expressed by interwoven sculptural layers rather than a closed badge or ring.

Open [`comparison.html`](comparison.html) for a side-by-side board with small-size previews. It is a comparison aid, not a fourth candidate.

## Exact generation prompts

Generation mode for all three: built-in `image_gen`, one independent call per candidate, no CLI/API fallback and no image reference input.

### Prompt A

```text
Use case: stylized-concept
Asset type: premium game-ball concept master for future sprite production
Primary request: Candidate A — "Powder Puff Crystal", an isolated single Stage 1 Snowflake gameplay ball made as a rounded six-arm snowflake built entirely from plush powder-snow tufts.
Scene/backdrop: genuinely transparent background, empty around the subject.
Subject: one compact snowflake-shaped game ball, centered. Six short, evenly spaced rounded arms grow directly from a dense snowy core. Each arm is constructed from soft clustered powder-snow puffs and subtle branching tufts, producing the friendliest, most tactile, softest silhouette of the set. It must be an actual sculptural snowflake form, not a round ball with a snowflake image painted inside.
Style/medium: beautiful polished high-end game asset concept, refined stylized 3D sculpt / painterly material render; intentionally NOT pixel art, NOT voxel art, NOT constrained to any pixel grid.
Composition/framing: square master; subject centered; compact near-circular collision footprint despite the six-arm outline; clearly readable silhouette at small size; generous transparent padding of roughly 20% on every side; no cropping.
Lighting/mood: soft broad upper-left studio light, gentle pearly rim light, low contrast and cozy; fluffy fresh-snow softness.
Color palette: pristine bright white is overwhelmingly dominant; only very subtle cool-white and extremely pale icy-blue shading for volume; no saturated blue, gray, beige, or colored accents.
Materials/textures: velvety powder snow, airy micro-fluff, tiny soft crystalline sparkle only within the material; clean alpha edges with no matte halo.
Constraints: exactly one subject; true transparent alpha background; no cast-shadow floor; pristine and premium; silhouette must remain six-arm snowflake-like and compact.
Avoid: text, face, eyes, mouth, character limbs, UI frame, scenery, logos, watermark, opaque or checkerboard background, square icon plate, circular container, sphere with an emblem, painted-on snowflake, hard glass crystal, sharp weapon-like spikes, metallic material, pixel art, excessive bloom, detached particles or floating debris.
```

### Prompt B

```text
Use case: stylized-concept
Asset type: premium game-ball concept master for future sprite production
Primary request: Candidate B — "Frost Blossom", an isolated single Stage 1 Snowflake gameplay ball designed as an elegant radial snow blossom with feathered crystalline petals and a luminous snowy core.
Scene/backdrop: genuinely transparent background, completely empty around the subject.
Subject: one compact sixfold snowflake sculpture, centered. Six graceful tapered petal-arms radiate from a small bright snow core. Every arm has delicate feather-like frost barbs and layered crystalline snow petals, creating an ornate botanical rhythm while remaining unmistakably a real snowflake. Open negative-space notches between arms create a crisp, memorable silhouette. This is an actual dimensional snowflake object, never a round ball with a snowflake image painted inside.
Style/medium: beautiful polished premium game asset concept, refined stylized 3D ice-and-snow sculpture with soft painterly finish; intentionally NOT pixel art, NOT voxel art, NOT constrained to a pixel grid.
Composition/framing: square master; perfectly centered; compact near-circular collision footprint; sixfold symmetry; legible at small size; generous transparent padding of roughly 20% on every side; no cropping.
Lighting/mood: luminous snowy core glowing softly outward through the petals, delicate cool backlight plus narrow pearly highlights; graceful, pristine, wondrous, more ornate than cuddly.
Color palette: pristine bright white dominant; restrained cool-white and very pale icy-blue internal shading only; no saturated color, gray mass, beige, rainbow refraction, or dark outline.
Materials/textures: feathered hoarfrost, fine snow crystal ridges, lightly translucent frosted edges, soft opaque snow at the core; clean alpha edges with no matte halo.
Constraints: exactly one subject; true transparent alpha background; no floor and no cast shadow; premium and striking; retain a snow-soft quality despite crystalline petal detail.
Avoid: text, face, eyes, mouth, character limbs, UI frame, scenery, logos, watermark, opaque or checkerboard background, square icon plate, circular container, sphere with emblem, painted-on snowflake, plush bulb tufts like Candidate A, chunky rounded club arms, metallic material, hard glass-only look, pixel art, excessive bloom, detached particles or floating debris.
```

### Prompt C

```text
Use case: stylized-concept
Asset type: premium game-ball concept master for future sprite production
Primary request: Candidate C — "Halo Flurry", an isolated single Stage 1 Snowflake gameplay ball with a compact sculptural sixfold snowflake, airy plume arms, layered halo-rime, and the strongest magical presence of the three.
Scene/backdrop: genuinely transparent background, empty around the subject.
Subject: one centered dimensional snowflake object. A compact faceted-snow core sends out six broad, wind-swept airy plume arms, each formed from curling fresh-snow ribbons and fine rime filaments. Behind and between the arms, two shallow interwoven wreaths of frosted rime form a layered halo that is physically part of the sculpture, not a circular icon container. The six plume tips break the halo and make the silhouette unmistakably snowflake-like. It must not look like a sphere, globe, badge, or ball with a picture painted inside.
Style/medium: beautiful polished premium fantasy game asset concept, sculptural stylized 3D snow and rime with an ethereal painterly finish; intentionally NOT pixel art, NOT voxel art, NOT constrained to a pixel grid.
Composition/framing: square master; centered; compact near-circular collision footprint with a distinct six-point outline; readable at small size; generous transparent padding of roughly 20% on every side; no cropping.
Lighting/mood: strongest magical presence; soft radiant inner light with a cool moonlit rim and subtle volumetric glow contained tightly within the sculpture; airy, wondrous, weightless but still tactile snow.
Color palette: pristine bright white dominant; soft cool-white and the palest icy-blue shading only for depth; no saturated cyan, purple, gray, beige, rainbow, or dark outline.
Materials/textures: curled powder-snow plumes, layered frosted rime, lace-like ice filaments, luminous opaque snow core; clean alpha edges with no matte halo.
Constraints: exactly one subject; true transparent alpha background; no floor and no cast shadow; premium and striking; structurally and visually different from plush tuft arms and feathered botanical petals.
Avoid: text, face, eyes, mouth, character limbs, UI frame, scenery, logos, watermark, opaque or checkerboard background, square icon plate, closed circular badge, plain ring icon, sphere with emblem, painted-on snowflake, flower petals like Candidate B, bulbous plush clubs like Candidate A, metallic material, hard glass-only crystal, pixel art, large bloom cloud, detached particles or floating debris.
```

## Validation record

All three files were opened successfully as PNG and visually inspected at master size after transparent-canvas normalization.

| Candidate | Dimensions | Actual alpha range | Visible-content margins at alpha ≥ 128 (L/T/R/B) | SHA-256 |
|---|---:|---:|---:|---|
| A | `2048×2048` | `0..255` | `543 / 461 / 536 / 459` | `8715CC7502629B1107C78F3110C28B71CCB4D420128E763C25628C2479370A72` |
| B | `2048×2048` | `0..255` | `498 / 401 / 497 / 422` | `DA4ADB358F78CB8E0D81202AD885A93085B731244E3303C1819C60C3C8EA7161` |
| C | `2048×2048` | `0..255` | `491 / 410 / 497 / 412` | `BF5724421E9EA8B51894A0BA4DB11C58E8885F85920A765FDABD466F26BA26B8` |

Validation confirms genuine transparent pixels, partial-alpha soft edges, opaque subject pixels, intact dimensions, generous padding, one isolated subject per file, no text/UI/scenery, and materially different silhouettes. These are concept masters, not runtime-ready sprites.

## Runtime preview status

- Candidate B selection and `32×32` gameplay derivative: complete
- Presentation LOD wiring and native Main capture: complete
- collision radius, score, mass, Content catalog and BallDefinition: unchanged
- final production approval and Web visual acceptance: deferred
