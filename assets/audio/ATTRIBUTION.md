# Audio Attribution

## Provenance

Audio provenance is split by asset family. The 22 event SFX files are sourced
from Pixabay. The six `bgm_*.ogg` files were generated with **Google Gemini**
for use in **Snowball Effect**.

## Pixabay SFX: third-party assets and licenses

- Source: Pixabay.
- License: [Pixabay Content License](https://pixabay.com/service/license-summary/)
  (royalty-free), subject to the terms in effect when each asset was
  downloaded.
- The license permits free commercial and non-commercial use, modification,
  and adaptation; attribution is not required.
- The audio must not be sold or distributed as standalone Pixabay content.
  This project distributes the audio only as part of the Snowball Effect game,
  a larger creative work.
- Any recognizable trademarks, logos, brands, or other third-party rights in
  a source asset require separate review before commercial use.
- The source URLs below are recorded as provenance evidence. Contributor names
  and download dates are not yet recorded; preserve them when available before
  public release.

## Gemini-generated BGM: provenance and applicable terms

| File | Intended state | Source | Applicable license / terms |
|---|---|---|---|
| `bgm_title.ogg` | Main Title | Google Gemini-generated content | Google/Gemini terms applicable to the generating account and service |
| `bgm_ground.ogg` | Ground Stage | Google Gemini-generated content | Google/Gemini terms applicable to the generating account and service |
| `bgm_planetary.ogg` | Planetary Stage | Google Gemini-generated content | Google/Gemini terms applicable to the generating account and service |
| `bgm_galactic.ogg` | Galactic Stage | Google Gemini-generated content | Google/Gemini terms applicable to the generating account and service |
| `bgm_pause.ogg` | Pause | Google Gemini-generated content | Google/Gemini terms applicable to the generating account and service |
| `bgm_result.ogg` | Final Result | Google Gemini-generated content | Google/Gemini terms applicable to the generating account and service |

- These six files are not Pixabay assets and are not offered under the Pixabay
  Content License or a separate Creative Commons license.
- Their use is governed by the Google Terms of Service and the Gemini service
  terms/policies that applied when they were generated, including the
  [Google Terms of Service](https://policies.google.com/terms) and applicable
  [Gemini service-specific terms](https://policies.google.com/terms/service-specific).
- The project credits the provenance explicitly as Google Gemini-generated
  content. Release owners must retain this attribution and confirm that the
  generating account's then-current terms permit the intended distribution.

## Selected audio assets

The following 22 files are the selected, final source assets. “Final” here
means the source-file selection is complete; it does not mark S6-G3/S6-G4 as
implemented or verified.

| File | Intended event / purpose | Pixabay source |
|---|---|---|
| `merge_t0.ogg` | Tier 0 basic Merge | [Putting ice cubes in a glass 1](https://pixabay.com/sound-effects/film-special-effects-putting-ice-cubes-in-a-glass-1-395494/) |
| `merge_t1.ogg` | Tier 1 mid Merge | Not recorded yet |
| `merge_t2.ogg` | Tier 2 high Merge | [Glass cracking](https://pixabay.com/sound-effects/household-glass-cracking-511310/) |
| `merge_t3.ogg` | Tier 3 major Merge / CUT-IN candidate | [Glass cracking](https://pixabay.com/sound-effects/household-glass-cracking-511310/) |
| `cashout_t0.ogg` | Standard Active Cashout | [Putting ice cubes in a glass 1](https://pixabay.com/sound-effects/film-special-effects-putting-ice-cubes-in-a-glass-1-395494/) |
| `cashout_high.ogg` | High-grade Active Cashout | [Ice freezing](https://pixabay.com/sound-effects/nature-ice-freezing-445024/) |
| `settlement_start.ogg` | Final Settlement start | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `settlement_finish.ogg` | Final Settlement finish | [You win sequence 1](https://pixabay.com/sound-effects/musical-you-win-sequence-1-183948/) |
| `stage_clear.ogg` | Stage Clear decision | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `stage_fail.ogg` | Time Up score-clear failure | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `scale_shift.ogg` | Ground-to-Planetary or Planetary-to-Galactic Scale Shift | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `ui_click.ogg` | General UI selection / confirmation | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `ui_pause.ogg` | Pause request | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `ui_resume.ogg` | Resume request | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `ui_retry.ogg` | Retry request | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `ui_start.ogg` | Start request | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `ui_menu.ogg` | Main-menu navigation / request | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `black_hole_phase.ogg` | First Lv14 Black Hole phase transition and L3 expansion | [Epic transition](https://pixabay.com/sound-effects/film-special-effects-epic-transition-418147/) |
| `black_hole_loop.ogg` | Black Hole phase ambience | [Space](https://pixabay.com/sound-effects/space-461600/) |
| `black_hole_absorb.ogg` | Black Hole absorption of an eligible low-level ball | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `black_hole_finale.ogg` | Two-Black-Hole contact: terminal finale entry | [Victory bell success fanfare](https://pixabay.com/sound-effects/musical-victory-bell-success-fanfare-576275/) |
| `run_end.ogg` | Immediate Run End, such as Black Hole absorption reducing run score to zero | [Game over arcade](https://pixabay.com/sound-effects/film-special-effects-game-over-arcade-6435/) |
| `item_collect.ogg` | Item Orb pickup before its CUT-IN request | [Arcade arped](https://pixabay.com/ko/sound-effects/%EC%98%81%ED%99%94-%EB%B0%8F-%ED%8A%B9%EC%88%98-%ED%9A%A8%EA%B3%BC-arcade-arped-145549/) (Pixabay); first sound segment only, leading/trailing silence removed, rendered at 60% source gain. Pixabay Content License applies. |
| `item_cutin.ogg` | Item CUT-IN request | [Power up type 1](https://pixabay.com/ko/sound-effects/%EC%98%81%ED%99%94-%EB%B0%8F-%ED%8A%B9%EC%88%98-%ED%9A%A8%EA%B3%BC-power-up-type-1-230548/) (Pixabay); leading/trailing silence removed, rendered at 80% source gain. Pixabay Content License applies. |

## Implementation status

- The table above records selected assets and intended event assignments only.
- The final runtime event-key mapping, audio catalog, priority/polyphony
  policy, first-user-input audio unlock, and Godot/Web playback verification
  remain separate S6-G1/S6-G3/S6-G4 work.
