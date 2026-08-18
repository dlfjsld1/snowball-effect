# S6-G2 First Contact CUT-IN Components

## Active roster

| Stage | Ball | Title layer | Portrait layer |
|---|---|---|---|
| Ground | Giant Snowball | `first-contact-giant-snowball-title-v1.png` | `giant-snowball-portrait-v1.png` |
| Ground | Moon | `first-contact-moon-title-v1.png` | `moon-portrait-v1.png` |
| Planetary | Supernova | `first-contact-supernova-title-v1.png` | `supernova-portrait-v1.png` |
| Planetary | Galaxy | `first-contact-galaxy-title-v1.png` | `galaxy-portrait-v1.png` |
| Galactic | Event Horizon | `first-contact-event-horizon-title-v1.png` | `event-horizon-portrait-v1.png` |
| Galactic | Black Hole | `first-contact-black-hole-title-v1.png` | `black-hole-portrait-v1.png` |

All six cards reuse `first-contact-background-v1.png`.

## Trigger policy

- A card is eligible only when its assigned ball is created for the first time in the current Run.
- The eligible balls are each Stage's local Lv3 and local Lv4.
- Moon belongs to the Ground pair and Galaxy belongs to the Planetary pair. Their reuse as the following Stage's local Lv0 must not trigger another card.
- Moon and Galaxy return to gameplay after the cut-in. The first Black Hole hands off to Black Hole Phase only after its cut-in finishes.

## Layer contract

- Background: opaque `1600x900` PNG.
- Title and portrait: transparent ARGB PNG with transparent corners.
- Compose the layers at runtime; do not bake six duplicate backgrounds.

`Galaxy Cluster` and `Quasar` assets in this directory are retained as unselected design drafts and are not part of the active roster.
