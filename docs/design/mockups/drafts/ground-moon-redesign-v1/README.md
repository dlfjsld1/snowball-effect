# Ground Moon Runtime Approval v1

Status: **APPROVED ACTIVE RUNTIME — exact user-authored 128×128 Moon**

Branch: `design/ground-snowflake-redesign`

Target: Stage 1 / Ground / global Lv4 Moon at local Lv4

## Approved active runtime

- Authoritative source: `C:\Users\gktjd\Downloads\ball_lv04_moon_user_authored_128.png`. The Downloads source remains untouched. The repository copy at `assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.png` is byte-identical: `38,070` bytes, SHA-256 `A60F9506DD041FAEA78D2698F3B8553DE45D1CFA633BB1C70C3BCA47EE7B7452`.
- The PNG signature, `IHDR`/`IDAT`/`IEND` ordering, and every chunk CRC validate. Godot and Pillow decode it as exactly `128×128`, non-interlaced 8-bit RGBA with binary alpha: `3,492` transparent and `12,892` opaque pixels; all four corners are transparent. The exact source carries one trailing zero byte after `IEND`; the repository copy preserves it as part of the required byte-identical handoff.
- `ball_lv04_moon_user_authored_128.tres` is the dedicated active `CanvasTexture`. It uses nearest filtering with repeat disabled. Godot import is lossless, preserves the alpha channel, enables alpha-border fixing, disables mipmaps, and applies no size limit or pixel resampling.
- Presentation maps global Lv4 to this resource only at runtime diameter `128`, which is Ground local Lv4. Planetary local Lv0 continues to resolve the existing dedicated `ball_lv04_moon_8.png` resource. The Content-owned Moon `BallDefinition` primary texture and catalog data/order remain unchanged.
- Ground gameplay size remains radius `64` / diameter `128`; collision and renderer transforms use the same authoritative Stage-local value. No score, mass, physics, Merge, Cashout, Stage, Scene, `project.godot`, Core, or Integration-owned file is changed.
- Ground Lv0 Frost Blossom, Lv1 user-authored 16px Snowball, Lv2 user-authored 32px Big Snowball, and Lv3 user-authored Giant Snowball v2 remain on their approved mappings. Every Planetary/Galactic LOD remains unchanged.

## CUT-IN exclusion

This request changes the gameplay-ball asset only. Moon FIRST CONTACT CUT-IN art is **not changed**: `scripts/presentation/cutin_controller.gd` independently maps `ground_moon` to `assets/sprites/cutins/first_contact/moon-portrait-v1.png` and its existing title layer. The gameplay Presentation LOD mapping does not drive that portrait.

## Runtime evidence

- [`ground-main-lv3-giant-v2-lv4-moon-runtime.png`](ground-main-lv3-giant-v2-lv4-moon-runtime.png) is a deterministic native capture of the actual `scenes/main/main.tscn` in `Ground / PLAYING`, with live HUD/frame, multiple Lv3 Giant Snowball v2 instances, at least one Lv4 Moon, and lower tiers through the production MultiMesh renderer.
- The capture is runtime evidence, not a fabricated concept mockup. Visual inspection covers native-size readability, nearest-sampled crispness, transparent edges, Play Field clipping, upright orientation, Lv3→Lv4 progression, and contrast against the Ground background.
