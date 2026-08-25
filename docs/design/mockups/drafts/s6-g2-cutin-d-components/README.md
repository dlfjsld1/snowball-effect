# S6-G2 First Contact CUT-IN Components

## Active roster

| `first_contact_id` | Stage | Ball | Title layer | Portrait layer |
|---|---|---|---|---|
| `ground_giant_snowball` | Ground | Giant Snowball | `first-contact-giant-snowball-title-v1.png` | `giant-snowball-portrait-v1.png` |
| `ground_moon` | Ground | Moon | `first-contact-moon-title-v1.png` | `moon-portrait-v1.png` |
| `planetary_supernova` | Planetary | Supernova | `first-contact-supernova-title-v1.png` | `supernova-portrait-v1.png` |
| `planetary_galaxy` | Planetary | Galaxy | `first-contact-galaxy-title-v1.png` | `galaxy-portrait-v1.png` |
| `galactic_event_horizon` | Galactic | Event Horizon | `first-contact-event-horizon-title-v1.png` | `event-horizon-portrait-v1.png` |
| `galactic_black_hole` | Galactic | Black Hole | `first-contact-black-hole-title-v1.png` | `black-hole-portrait-v1.png` |

All six cards reuse `first-contact-background-v1.png`.

## 2026-08-25 portrait identity alignment

- `planetary_galaxy`: runtime portrait is the approved Grand Spiral A master reduced from `1536×1536` to the existing `1254×1254` CUT-IN canvas with Lanczos filtering.
- `galactic_event_horizon`: runtime portrait is byte-identical to the approved `event-horizon-C-last-light-master.png`.
- `galactic_black_hole`: runtime portrait is byte-identical to the approved `black-hole-C-void-cathedral-master.png`.
- The three in-game ball PNGs, Stage-local radii, collision, LOD bindings, trigger policy, titles, background, and `2.00s` timing remain unchanged. The older same-name portrait copies in this draft directory are retained only as historical design inputs.

## Trigger policy

- A card is eligible only when its assigned ball is created for the first time in the current Run.
- The eligible balls are each Stage's local Lv3 and local Lv4.
- Moon belongs to the Ground pair and Galaxy belongs to the Planetary pair. Their reuse as the following Stage's local Lv0 must not trigger another card.
- Moon and Galaxy return to gameplay after the cut-in. The first Black Hole hands off to Black Hole Phase only after its cut-in finishes.
- Runtime composition consumes only S3-G9 payload v1 after S6-G2I has accepted the gameplay pause. The Presentation controller must not infer discovery from `ball_merged`, `top_ball_created`, or Black Hole readiness signals.
- These files are design inputs, not implementation Evidence. S6-G2 remains `PENDING` until S3-G9 and S6-G2I are both verified.

## Layer contract

- Background: opaque `1600x900` PNG.
- Title and portrait: transparent ARGB PNG with transparent corners.
- Compose the layers at runtime; do not bake six duplicate backgrounds.

`Galaxy Cluster` and `Quasar` assets in this directory are retained as unselected design drafts and are not part of the active roster.
