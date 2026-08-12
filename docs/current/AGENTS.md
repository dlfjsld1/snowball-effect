# AGENTS.md — Snowball Effect

This repository is the OpenAI Game Hackathon 2026 project **Snowball Effect**.

Codex must read the project documentation before making meaningful changes.

## Read Order

1. `00_READ_FIRST.md`
2. `01_PRODUCT_BRIEF.md`
3. `02_GAME_RULES.md`
4. `DESIGN/00_VISUAL_IDENTITY.md`
5. `DESIGN/01_SCREEN_COMPOSITION.md`
6. Read the remaining relevant `DESIGN/*.md` files for art/presentation work
7. `03_TECHNICAL_DESIGN.md`
8. `04_PROJECT_STRUCTURE.md`
9. `05_IMPLEMENTATION_PLAN.md`
10. `06_CODEX_WORKING_RULES.md`
11. The relevant file under `tasks/`
12. Submission requirements under `SUBMISSION/` when release or judging work is involved

If documentation conflicts, follow this priority:

1. The user's latest explicit instruction
2. `02_GAME_RULES.md`
3. `03_TECHNICAL_DESIGN.md`
4. The active `tasks/*.md`
5. `05_IMPLEMENTATION_PLAN.md`
6. Existing code conventions

Do not invent or silently change game rules.

---

## Core Game Constraints

These are deliberate product decisions and must not be changed without an explicit user instruction.

- Engine: Godot 4.x
- Target: browser Web Export
- `A / D`: move paddle horizontally
- `Left / Right Arrow`: change paddle angle
- Movement and rotation can be used simultaneously
- Balls with the same `global_level` merge
- Falling below the paddle is an intentional cash-out, not a life loss; during active Stage play it grants Score + the current Stage local-level Time Bonus
- Score values intentionally explode by roughly 100x, 1000x, or other hand-tuned jumps; do not replace them with a conserved `2^level` formula
- Creating a Stage's top ball immediately decides that the Stage is cleared; `SCALE SHIFT` occurs only after Final Settlement
- The previous stage's top ball becomes the next stage's default falling ball
- Spawn density increases as scale rises
- In the final Galactic Stage, a moving Black Hole map gimmick bends trajectories as an in-stage final phase; Lv14 is a separate final snowball, not a Black Hole ball
- Gameplay balls and decorative particles are separate systems

---


## Visual / Presentation Constraints

These are product constraints, not optional polish.

- The full 16:9 viewport is **not** the gameplay field.
- Gameplay occurs inside a tall central Play Field.
- The left/right space is Stage World + Retro Pixel Arcade Machine presentation space.
- Do not redesign the game as a full-width 16:9 Breakout field.
- Visual identity: `Retro Pixel Arcade Machine × Cosmic Escalation`.
- Keep gameplay balls visually clearer than decorative particles.
- General merges use fast, saturation-style effects.
- High-grade events may use a short CUT-IN.
- A normal CUT-IN freezes/dims the current full scene; it does not open a separate screen.
- Normal CUT-IN target duration is about 0.45–0.70 seconds and should normally remain under 1 second.
- `SCALE SHIFT` is a different, higher-priority presentation event from a normal CUT-IN.
- Do not copy the specific UI/art assets of reference games.



## Stage / Cashout / Time Constraints

These are core game rules.

- Each Stage is a short timed round, not one continuous 180-second global timer.
- A gameplay ball that falls below the paddle is intentionally **cashed out**.
- Normal Cashout grants:
  - the Active Cashout score, including optional cashout-only modifiers
  - the current Stage local-level Time Bonus
- `time_bonus_by_local_level` belongs to StageDefinition; Local Lv0 starts at 0 and time grows much more slowly than score.
- A player may intentionally miss a high-grade ball to convert it into Score + Time.
- Creating the current Stage's top ball immediately clears that Stage.
- If the Stage timer reaches zero first, perform `FINAL SETTLEMENT`.
- Final Settlement converts all active gameplay balls into **Score only**.
- Final Settlement never grants Time Bonus.
- Final Settlement uses base `score_value` and never applies Active Cashout-only modifiers.
- Final Settlement uses one active-ball snapshot and must be idempotent.
- After Time Up, advance only if the final Stage score meets that Stage's `clear_score`.
- If the score target is not met, the run ends.
- On the final Galactic Stage, Time Up leads to the final result instead of another score-gated Stage.
- `SCALE SHIFT` happens after a successful Stage clear and settlement.
- The previous Stage's top ball becomes the next Stage's default falling ball.
- On Stage entry, reset `stage_score` to 0 and `stage_time` to that Stage's `base_time`; preserve `run_score`, statistics, and records.
- Every score event adds the same amount once to `stage_score` and `run_score`. Never add `stage_score` to `run_score` again at Stage end.
- Evaluate Time Up only after the current physics tick's merges and Active Cashouts have been committed.
- A same-tick Cashout may restore positive time and keep the Stage in PLAYING.
- If Top Ball creation and Time Up occur in the same tick, Top Ball Clear wins.

Do not restore the old design where the whole run uses one fixed 180-second timer.
Do not make surviving balls grant Time Bonus during Final Settlement.

Core flow and optional items are separate. The core is Merge, Cashout, Time Bonus, Stage Timer, Settlement, and Scale Shift. Blizzard, Fire Core, and Magnet are optional item-layer features; removing them must not change core rules.

## Technical Constraints

- Use Godot 4.x APIs only.
- Do not use deprecated APIs.
- Do not create thousands of gameplay balls as individual `RigidBody2D` nodes or scene instances.
- Low-level balls must be managed by a central data-oriented simulation.
- Do not use all-pairs O(N^2) collision checks for the production merge system.
- Use a Uniform Grid / Spatial Hash or equivalent neighbor structure for merge candidates.
- Reuse inactive slots rather than repeatedly instantiating and freeing large numbers of gameplay objects.
- Keep gameplay state separate from GPU particles and presentation-only effects.
- Prefer simple, measurable solutions before adding low-level rendering complexity.
- Keep the project runnable after each task.
- Do not perform unsolicited large-scale refactors.

---

## Scope Discipline

Work on one requested task or one clearly bounded subsystem at a time.

Do not add unrelated systems, architecture, plugins, databases, networking, multiplayer, accounts, or speculative abstractions.

Placeholder art and simple debug visuals are acceptable until the core loop is proven.

When a task document has explicit exclusions, honor them.

---

## Verification

After meaningful code changes, verify the relevant subset of:

- GDScript parsing
- Missing resource paths
- Missing `NodePath` references
- Runtime null access
- Array/index safety
- Duplicate merges
- Pause/restart behavior
- Stage transition behavior
- Score formatting (`NaN` / infinity included)
- Browser console errors for Web Export work
- Performance metrics when the task is performance-related

If the environment does not allow a verification step, say that explicitly. Never claim a test, FPS value, browser result, or runtime behavior that was not actually observed.

---

## Hackathon Collaboration Log — REQUIRED

After **every meaningful Codex development task**, append a new entry to:

`SUBMISSION/02_CODEX_COLLAB_LOG.md`

This is part of the Definition of Done.

A task is **not complete** until its collaboration-log entry has been written.

The log entry must include, when applicable:

- Date/time
- Task or problem
- Human decisions
- Codex contribution
- Important Codex suggestions
- Suggestions rejected, narrowed, or changed by the human
- Files changed
- Errors or issues encountered
- Verification actually performed
- Performance measurements when relevant
- Commit hash, only if a commit actually exists

### Logging rules

- Append entries chronologically.
- Do not rewrite or summarize older entries unless explicitly asked.
- Do not fabricate human decisions.
- Do not fabricate tests, measurements, errors, or results.
- If something was not verified, write `Not verified` and explain why.
- Keep entries concise but specific enough to support the hackathon's **Codex Collaboration** judging criterion.
- Record iterations and corrections, not only successful final results.
- Prefer concrete evidence such as file paths, observed errors, FPS values, browser behavior, or before/after implementation choices.

### Required entry template

```md
## YYYY-MM-DD HH:MM — <Task name>

### Goal
<What problem or feature was being worked on>

### Human decisions
- <Product / design / scope decisions made by the human>

### Codex contribution
- <Implementation, investigation, debugging, optimization, or tooling performed by Codex>

### Iteration / decisions
- <Important Codex suggestion and whether it was accepted, changed, or rejected>
- <Any meaningful correction or change in approach>

### Changed files
- `path/to/file`

### Verification
- <Tests or manual scenarios actually run>
- <Performance data if relevant>

### Issues / limitations
- <Known remaining issues, or `None observed`>

### Commit
- `<hash>` if one exists, otherwise `Not committed`
```

---

## Submission Awareness

This project is being built for the OpenAI Game Hackathon 2026.

When working on release/submission tasks, preserve evidence for:

- Playability
- Originality
- Codex Collaboration
- Release Potential
- Presentation

Do not sacrifice the core playable loop to add optional features.

For submission-related work, also read the files under `SUBMISSION/`.

---

## Completion Report

At the end of a meaningful task, report:

```text
## Changed
- ...

## Files
- ...

## Verification
- ...

## Known issues
- ...

## Collaboration log
- Appended to SUBMISSION/02_CODEX_COLLAB_LOG.md

## Next recommended task
- ...
```

If the collaboration log was not updated, the task is not complete.
