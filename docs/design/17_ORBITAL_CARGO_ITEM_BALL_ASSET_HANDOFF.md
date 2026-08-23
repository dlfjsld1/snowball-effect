# Orbital Cargo Item Ball — Raster Asset Handoff

Status: approved production raster and Presentation runtime wiring complete
Owner: Presentation/UI

## Files and geometry

| Asset | Godot path | Sheet | Frame order |
|---|---|---:|---|
| Orbital Cargo Satellite Item Ball | `res://assets/sprites/items/item_ball_orbital_cargo_h0_h4.png` | `320×64px`, RGBA | five contiguous `64×64px` frames: H0, H1, H2, H3, H4 |
| Neutral break fragments | `res://assets/sprites/items/item_ball_neutral_break_fragments_4f.png` | `256×64px`, RGBA | four contiguous `64×64px` frames: compact, separating, wide, sparse |

Both sheets use binary alpha, no frame gutters, no baked labels, and no CRT/UI framing. The recommended per-frame origin is the canvas center, `(32, 32)`, with `Sprite2D.centered = true` and zero offset.

## Collision relationship

- Keep the existing Item Ball collision circle at radius `24px` / diameter `48px`, centered on the frame origin.
- The physical spherical moon/asteroid core stays within the central `48×48px` collision-read zone of the `64×64px` visual canvas.
- The C-clamp, orbital band, H4 detached fragment, and break fragments are decorative only. They do not enlarge or replace the collision boundary.

## Draw and import guidance

- Select an exact `64×64px` source region at `x = frame_index × 64`; draw at integer coordinates and integer scale.
- Use nearest-neighbor filtering, no mipmaps, no linear filtering, no fractional transform, and no blur/glow pass on the base sprite.
- Do not tint the Item Ball or neutral fragments by item type. The base palette is Paper-8-aligned neutral hardware/stone: `#1f244b`, `#3d3145`, `#654053`, `#8a5560`, `#a8605d`, `#d1a67e`, `#f6e79c`, `#3c6b64`, `#668574`, `#b6cf8e`.

## Reveal contract

H0–H4 and all four break frames contain no Item Orb, Blizzard/snowflake, ability glyph, or reward-specific colour. **Reward contents remain unknown until a separate Item Orb spawns after the Item Ball breaks.** The H4 detached piece and every break-sheet fragment are generic non-reward debris.

## Runtime integration

- `scripts/presentation/item_blizzard_visual.gd` draws the shared H0–H4 sheet for every Item Ball type and selects the frame from the authoritative five-hit damage state.
- The same Presentation node plays the four neutral break frames after `item_planet_broken`; the later Item Orb remains the first item-specific visual.
- The authoritative producer emits `item_planet_broken` and then `item_orb_spawned` in the same committed break sequence. Neutral fragments may therefore overlap the separately rendered Orb; Presentation does not delay Orb movement, collection, or miss handling.
- The sprite is presentation-only. Collision radius, movement, hit counting, break timing, pickup behavior, and item effects remain owned by their existing Core/Content contracts.

## Production note

The approved reference is `docs/design/mockups/item-ball-orbital-cargo-satellite-v3.png`. OpenAI built-in ImageGen was used for silhouette/material reference exploration; the delivered PNGs were redrawn and palette-cleaned directly on the native `64px` grid with hard edges and binary alpha.
