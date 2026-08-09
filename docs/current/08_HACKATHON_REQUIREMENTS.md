# OpenAI GAME BUILDERS SEOUL — Track 1 Requirements

> Source verified: 2026-08-07
> Official page: https://openaigame2026.com/

This document captures the current official requirements that directly affect Snowball Effect development and submission. If the official site changes, the official site wins.

---

## 1. Schedule

- Online warm-up submission period: **2026-08-04 through 2026-08-26**
- Online judging: **2026-08-27**
- Finalist announcement / invitations: **2026-08-28 through 2026-08-30**
- Offline final event in Seoul: **2026-08-31**
- Track 1 Open-Mic starts at 13:00 on the final event day.
- Track 1 elevator pitch: **maximum 3 minutes**.

Treat August 25 as the internal freeze deadline so August 26 is only for final verification and submission.

---

## 2. Team Constraints

- Team size: **up to 3 people**.
- If applying as a team, only **one representative** is invited to the offline final.

This means the project must be understandable and demoable by one person even if three people built it.

---

## 3. Mandatory Track 1 Submission Requirements

The prototype must:

- be playable;
- expose the core fun through actual play;
- be publicly accessible during judging;
- run as a **web build directly in a browser**;
- provide a playable URL;
- require no separate approval to access;
- include controls and run instructions;
- remain reachable throughout judging.

If login is required, a test account must be provided. Snowball Effect should avoid login entirely.

Existing projects may be used, but if an existing project is used, the submission must identify what was newly developed during the challenge period.

---

## 4. Required Submission Fields Affecting Development

- Final game title
- Game introduction: **maximum 200 Korean characters / submission field limit 200 characters**
- Playable game URL
- Game thumbnail
  - recommended aspect ratio: **16:9**
  - recommended format: **JPG or PNG**
  - recommended maximum size: **10 MB**

These are not end-of-project paperwork. UI readability, title, first-screen comprehension, and screenshot composition should be considered during development.

---

## 5. Optional Bonus Materials

### Demo video

- Optional, but bonus points are stated.
- Maximum length: **3 minutes**.
- Should include actual gameplay.
- Should communicate game introduction, play method, and core features.

### Codex collaboration description

- Optional, but bonus points are stated.
- The submission asks:
  - Where was Codex used?
  - What features did Codex implement?
  - What problems did Codex solve?
  - What did the developer decide or implement directly?

Therefore actual Codex work must be logged during development, not reconstructed from memory at the end.

---

## 6. Official Judging Criteria

Track 1 uses five judging areas.

### Playability

> Does the game actually work well?

Snowball Effect evidence:

- browser opens without installation;
- controls work immediately;
- no fatal errors during a complete run;
- paddle control is predictable;
- merge / cash-out / Scale Shift loop works consistently;
- restart works;
- performance remains acceptable in late-stage density.

### Originality

> Is the idea and play method original?

Snowball Effect should emphasize these together, not separately:

1. move + tilt paddle aiming;
2. same-level action merge;
3. dropped balls become score instead of lives/failure;
4. the previous stage's ultimate ball becomes the next stage's default falling unit;
5. spawn density and world scale snowball together;
6. late stages alter physics through the black hole.

The signature idea is **the game itself snowballing in scale**, not merely a Breakout clone with merge balls.

### Codex Collaboration

> Was Codex used effectively?

Evidence should show iterative collaboration, for example:

- architecture or task decomposition;
- Godot implementation;
- debugging runtime issues;
- improving paddle reflection;
- implementing Spatial Grid optimization;
- measuring performance before and after changes;
- Web Export troubleshooting;
- explaining which gameplay decisions were human decisions.

Do not claim this document pack itself as Codex work unless it was actually created or maintained through Codex. Log real Codex sessions separately.

### Release Potential

> Can the service be expanded through Hive?

Hive integration is not a mandatory prototype requirement on the official Track 1 page. Do not sacrifice the prototype to build speculative integration.

The release-potential story should instead be credible:

- instant browser arcade game;
- short replayable sessions;
- score and highest-stage competition;
- future daily seeds / challenges;
- future leaderboard, achievements, account, and cross-device progression;
- future Hive integration if release proceeds.

### Presentation

> Can the game and its development process be clearly communicated through presentation and demo?

Evidence:

- strong 16:9 thumbnail;
- 200-character description;
- immediately readable title/start screen;
- optional 3-minute gameplay video;
- Codex collaboration log;
- one-person 3-minute final pitch script;
- stable deterministic demo path or debug fallback for the final event.

---

## 7. Development Consequences

The judging criteria change feature priority.

### P0 — cannot submit without this

- Web Export
- public link
- controls / start flow
- stable core loop
- merge
- score
- Scale Shift
- at least two visible scale changes in a normal 3-minute session
- results / retry

### P1 — high judging value

- strong feel for high-level merge and cash-out
- late-game density without frame collapse
- Codex collaboration log
- thumbnail-ready visual composition
- demo video

### P2 — only if P0/P1 are stable

- Blizzard
- Fire Core
- Black Hole gameplay modifier

### P3 — cut first

- Magnet
- advanced distortion shader
- extra post-Multiverse content
- online leaderboard
- Hive implementation before it is actually needed

---

## 8. Definition of Submission-Ready

Snowball Effect is submission-ready only when all are true:

- [ ] Game opens from a clean browser session.
- [ ] No login is required.
- [ ] Controls are visible before or immediately after Start.
- [ ] A/D moves the paddle.
- [ ] Left/right arrow keys tilt the paddle.
- [ ] Same-level merge works.
- [ ] Bottom cash-out works.
- [ ] Score escalation is visible.
- [ ] Scale Shift is reachable naturally.
- [ ] A full stage-based run completes without a fatal error.
- [ ] Result screen and Retry work.
- [ ] Late-game performance is acceptable.
- [ ] Public URL has been tested from a private/incognito browser.
- [ ] 200-character description is ready.
- [ ] 16:9 thumbnail is ready.
- [ ] Optional 3-minute demo video is ready or consciously skipped.
- [ ] Codex usage record contains real sessions and human/Codex role separation.
