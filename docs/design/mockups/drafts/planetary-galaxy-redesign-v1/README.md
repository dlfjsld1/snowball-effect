# Planetary Galaxy Redesign — 2026-08-24

Design exploration for Snowball Effect's second-stage Planetary `Galaxy`. On 2026-08-25, the approved A master became the source for the existing `1254×1254` FIRST CONTACT portrait; the in-game Planetary Galaxy asset remains unchanged.

## Confirmed runtime contract

- Planetary ordered chain: `[4, 5, 6, 8, 10]`.
- Galaxy: global Lv10, Planetary local Lv4.
- Runtime radius: `4 × 2^4 = 64`, so the Planetary gameplay diameter is exactly `128px`.
- The same global Lv10 is Galactic local Lv0. On 2026-08-25, candidate A was also approved as the source for its `8px` in-game representation via deterministic Lanczos downscale; the BALLS CRT keeps the Planetary final Galaxy image under the carryover rule.
- Pixel-art constraints in `12_PIXEL_DESIGN_GUIDELINES.md` were intentionally not applied per the user's explicit direction.

## Shared design contract

- One centered galaxy on genuine RGBA transparency.
- The near-circular gameplay silhouette is made by stars, gas, dust, and spiral arms themselves. There is no enclosing sphere, shell, rim, glass orb, or painted circular surface.
- No text, frame, checkerboard, shadow plate, halo backdrop, or secondary object.
- Must remain immediately readable as one galaxy at 128×128 and avoid Black Hole, Supernova, planet, galaxy-cluster, and generic magic-orb readings.
- Generated as non-pixel-art high-resolution masters, then downsampled to 128×128 with high-quality bicubic filtering.

## Candidates

### A — Grand Spiral

The canonical instant-read option. A platinum/pale-gold nucleus anchors two broad blue-violet arms with clear dust lanes and ragged stellar tips. It has the strongest `Galaxy` recognition and the best match for a final Planetary-scale ball that should feel overwhelming.

128px read: strongest core/arm hierarchy; remains a clear face-on spiral with no container silhouette.

### B — Barred Whirlpool

The kinetic option. A turquoise-white diagonal stellar bar launches four unequal teal, violet, and magenta arms. Open negative spaces and displaced arm tips keep it from feeling like the same design family as A.

128px read: bar, rotation, and magenta outer knots remain visible; reads more stylized and energetic than A, with a slightly higher portal/magic risk than the other two.

### C — Tidal Crown

The mass option. Dense navy/cyan/silver layered bands wrap a bright stellar core while two short opposing tidal tails complete a broad crown silhouette. It communicates compression and weight without using a void or accretion disk.

128px read: thick nested bands and the two crown tips survive; reads as one heavy spiral galaxy rather than a cluster.

## Files

| Candidate | Master | Runtime preview |
|---|---|---|
| A | `candidate-a-grand-spiral-master.png` | `candidate-a-grand-spiral-preview-128.png` |
| B | `candidate-b-barred-whirlpool-master.png` | `candidate-b-barred-whirlpool-preview-128.png` |
| C | `candidate-c-tidal-crown-master.png` | `candidate-c-tidal-crown-preview-128.png` |

Comparison board: `comparison.html`.

## Technical validation

All masters are `1536×1536`, `Format32bppArgb`, with smooth partial alpha and a fully transparent outer margin. The generated 1254px source canvases were placed without resampling into larger transparent canvases so master detail and morphology were not altered.

| Candidate | Master nonzero-alpha bounds | Master transparent margins L/T/R/B | Preview bounds | Preview transparent margins L/T/R/B | Preview edge max alpha |
|---|---:|---:|---:|---:|---:|
| A | `141,158–1380,1394` | `141/158/155/141` | `9,10–117,118` | `9/10/10/9` | `0` |
| B | `141,150–1372,1394` | `141/150/163/141` | `11,11–116,118` | `11/11/11/9` | `0` |
| C | `141,160–1380,1394` | `141/160/155/141` | `13,10–114,114` | `13/10/13/13` | `0` |

Every preview is `128×128 RGBA`; every canvas-edge pixel is fully transparent, and fully transparent pixels have RGB `0,0,0` to avoid matte fringe.

## Generation notes

- Built-in image generation was invoked independently for A, B, and C with no cross-candidate image references.
- A received one framing correction attempt because faint alpha touched the source edge. That AI correction baked a black background and was rejected. The accepted A master uses the original genuine-alpha generation with lossless transparent-canvas padding.
- B and C passed the semantic visual check without regeneration.
- Existing dirty-worktree Moon/Earth/Sun/Supernova/Galaxy assets were inspected read-only and were not copied over, modified, staged, or used as edit targets.

## Recommendation

Recommend **A — Grand Spiral** for the first runtime trial. At 128px it gives the fastest Galaxy recognition, the warm center establishes a clean value hierarchy against the cool arms, and the two-arm silhouette delivers the largest perceived scale without borrowing Black Hole or Supernova language. Keep B as the high-energy alternate and C as the heavier, more regal alternate.
