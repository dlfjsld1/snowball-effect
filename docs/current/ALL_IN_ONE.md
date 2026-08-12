# Snowball Effect — Current Context (Generated)

> Generated from the split documents in this directory on 2026-08-11. The split documents and repository `docs/goals/` remain authoritative.

---

## FILE: README.md

# Snowball Effect — Codex Context Pack v1.4

> **2026-08-12 전달본 주의 — 구현 판단에 사용 금지:** 이 합본은 최신 split 문서 재생성 전의 snapshot이며 내부에 구계약 표현이 남아 있다. 특히 첫 Lv14→이동 Black Hole 전환과 두 Black Hole 충돌 finale가 반영되지 않았다. 재생성 전까지 모든 구현·리뷰 판단은 `02_GAME_RULES.md`, `03_TECHNICAL_DESIGN.md`, `tasks/07_black_hole.md`, `../goals/`, `../team/INTEGRATION_CONTRACTS.md`를 우선한다.

Godot 4 웹 게임 **Snowball Effect**를 Codex와 단계적으로 구현하고 OpenAI GAME BUILDERS SEOUL Track 1에 제출하기 위한 기획·기술·작업·제출 문서 세트다.

## 사용 순서

1. 프로젝트 루트에 `AGENTS.md`를 둔다.
2. `00_READ_FIRST.md`부터 읽는다.
3. 공식 제출 조건은 `08_HACKATHON_REQUIREMENTS.md`를 기준으로 확인한다.
4. 새 Codex 세션에서는 `07_INITIAL_PROMPT.md`를 사용한다.
5. 저장소에서는 `../goals/`의 현재 Goal을 따르고, 해당 Goal이 참조하는 `tasks/`를 요구사항 원문으로 읽는다.
6. 실제 Codex 작업은 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 사실 기반으로 남긴다.
7. 제출 직전 `SUBMISSION/06_RELEASE_CHECKLIST.md`를 통과한다.

## 핵심 문서

- 제품 방향: `01_PRODUCT_BRIEF.md`
- 확정 게임 규칙: `02_GAME_RULES.md`
- 대량 공 기술 구조: `03_TECHNICAL_DESIGN.md`
- 프로젝트 구조: `04_PROJECT_STRUCTURE.md`
- 구현 단계: `05_IMPLEMENTATION_PLAN.md`
- Codex 규칙: `06_CODEX_WORKING_RULES.md`
- 공식 Track 1 요구사항: `08_HACKATHON_REQUIREMENTS.md`
- 제출 전략: `SUBMISSION/`
- 한 파일 전달용: `ALL_IN_ONE.md`

`ALL_IN_ONE.md`는 분리 문서에서 다시 생성하는 전달용 복사본이다. 구현 상태와 Goal Evidence는 포함하지 않으며 저장소에서는 `../goals/`가 실행 기준이다.

## 공식 출처

- https://openaigame2026.com/
- 요구사항 스냅샷 확인일: 2026-08-07

공식 페이지가 변경되면 공식 페이지가 이 문서보다 우선한다.

---

## FILE: AGENTS.md

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
- In the final Galactic Stage, a moving Black Hole map gimmick bends trajectories; it is separate from the Lv14 Black Hole Snowball
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

---

## FILE: 00_READ_FIRST.md

# Snowball Effect — Codex Context 시작 안내

이 문서 묶음은 **Snowball Effect**를 Godot 4 기반 웹 게임으로 구현하기 위한 기준 컨텍스트다.  
기획, 게임 규칙, 기술 설계, 구현 단계가 서로 분리되어 있으므로 임의로 한 문서만 읽고 구현하지 않는다.

---

## 1. 권장 읽기 순서

| 순서 | 문서 | 목적 |
|---:|---|---|
| 1 | `01_PRODUCT_BRIEF.md` | 게임이 왜 재미있어야 하는지 이해 |
| 2 | `02_GAME_RULES.md` | 확정된 조작과 규칙 확인 |
| 3 | `09_GAMEPLAY_LOOP_V2.md` | Cashout·시간·Stage Clear 최신 루프 확인 |
| 4 | `DESIGN/00_VISUAL_IDENTITY.md` | 픽셀 아케이드 기계 정체성 확인 |
| 5 | `DESIGN/01_SCREEN_COMPOSITION.md` | 중앙 Play Field + 좌우 Stage World 화면 계약 확인 |
| 6 | `DESIGN/02_STAGE_ART_DIRECTION.md` | Stage별 배경/기계 변화 확인 |
| 7 | `DESIGN/03_GAMEPLAY_EFFECTS.md` | 뱀서식 포화와 가독성 위계 확인 |
| 8 | `DESIGN/04_CUTIN_SYSTEM.md` | 고등급 CUT-IN 규칙 확인 |
| 9 | `03_TECHNICAL_DESIGN.md` | 대량 공 시뮬레이션과 프레젠테이션 구조 확인 |
| 10 | `04_PROJECT_STRUCTURE.md` | 씬·스크립트·데이터 책임 확인 |
| 11 | `05_IMPLEMENTATION_PLAN.md` | 구현 순서와 컷라인 확인 |
| 12 | `06_CODEX_WORKING_RULES.md` | 에이전트 작업 규칙 확인 |
| 13 | `08_HACKATHON_REQUIREMENTS.md` | 공식 Track 1 제출·심사 제약 확인 |
| 14 | `07_INITIAL_PROMPT.md` | 새 프로젝트의 최초 작업 지시 확인 |
| 15 | `tasks/*.md` | 현재 구현할 한 단계의 상세 명세 확인 |
| 16 | `SUBMISSION/*.md` | 제출 자료와 Codex 협업 증거 관리 |

---

## 2. 문서 권한

서로 다른 문서에 표현 차이가 있으면 다음 우선순위를 따른다.

1. 사용자의 최신 지시
2. `02_GAME_RULES.md`
3. `03_TECHNICAL_DESIGN.md`
4. `08_HACKATHON_REQUIREMENTS.md`의 공식 제출 제약
5. 현재 작업 문서
6. `05_IMPLEMENTATION_PLAN.md`
7. 기존 코드

저장소에서 작업할 때는 루트 `docs/goals/`의 현재 Goal과 검증 상태를 함께 따른다. 추측으로 규칙을 바꾸지 않는다. 사소한 구현 세부는 합리적으로 정하되 작업 보고에서 가정을 밝힌다.

---

## 3. 현재 확정된 핵심

- 프로젝트명: **Snowball Effect**
- 엔진: **Godot 4.x**
- 플랫폼: 브라우저 Web Export
- 장르: 2D 액션 머지
- `A / D`: 패들 좌우 이동
- `← / →`: 패들 각도 변경
- 같은 `global_level`의 공끼리 합체
- 바닥 도달은 실패가 아니라 점수 획득
- 점수는 단계마다 100배, 1,000배 등 의도적으로 폭증
- 이전 스테이지 최고 공은 다음 스테이지 기본 공
- 스테이지가 오를수록 기본 공 생성량 증가
- 마지막 Galactic 스테이지에서는 Lv14 Black Hole Snowball과 별개인 이동 블랙홀 맵 기믹이 공의 궤도를 휨
- 이펙트는 뱀파이어 서바이버처럼 포화되되, 중요한 이벤트가 묻히지 않게 계층화
- 게임 규칙 공은 CPU 데이터, 장식 파티클은 GPU 파티클
- 화면은 중앙의 세로 Play Field + 좌우 Stage World/기계 프레임 구조
- 전체 아트 방향은 Retro Pixel Arcade Machine × Cosmic Escalation
- 일반 머지는 뱀서식 포화 연출, 고등급 이벤트는 짧은 Pixel CUT-IN
- CUT-IN은 현재 장면 전체를 freeze/dim하고 약 0.45~0.7초 안에 지나감
- SCALE SHIFT는 일반 CUT-IN과 별도이며 더 높은 우선순위
- Track 1 제출물은 브라우저에서 별도 설치 없이 실행되는 공개 Web Build여야 함
- 제출 소개는 200자 제한, 썸네일은 16:9 JPG/PNG 권장
- 3분 이하 실제 플레이 영상과 Codex 활용 설명은 선택 제출이지만 가산점
- 본선 Track 1 엘리베이터 피치는 최대 3분

---

## 4. 구현 철학

이 게임은 정밀한 물리 시뮬레이터가 아니다. 다음을 우선한다.

1. 조작이 예측 가능할 것
2. 합체가 자주 보일 것
3. 높은 단계가 명확히 특별할 것
4. 스테이지가 오를수록 화면 밀도와 규모가 폭증할 것
5. 웹 브라우저에서 안정적으로 실행될 것

현실적인 질량·마찰·천체 물리보다 게임 감각이 우선이다.

---

## 5. 작업 보고 형식

Codex는 작업을 마치고 아래 형식으로 보고한다.

```text
## 변경 요약
- ...

## 변경 파일
- path/to/file.gd
- path/to/file.tscn

## 검증
- 실행 명령 또는 에디터 실행 방법
- 확인한 시나리오
- FPS / 활성 공 수 등 측정값

## 남은 문제
- ...

## 다음 권장 작업
- ...
```

완료하지 못한 항목을 완료한 것처럼 쓰지 않는다.

---

## 6. 해커톤 기준으로 생긴 추가 원칙

- `Playability`가 무너지면 선택 기능을 즉시 자른다.
- `Originality`는 Scale Shift와 기본 단위 승격으로 증명한다.
- `Codex Collaboration`은 실제 작업 로그와 검증 결과로 증명한다.
- `Release Potential` 때문에 지금 Hive를 억지로 붙이지 않는다. 웹 아케이드의 반복 구조와 향후 확장 경로를 설계한다.
- `Presentation`을 위해 첫 화면, 결과 화면, 16:9 썸네일 구도를 개발 중부터 고려한다.

---

## 7. Codex 협업 로그는 완료 조건이다

의미 있는 개발 작업은 구현·검증 후 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 append-only 로그를 남겨야 끝난다. 상세 규칙과 템플릿은 루트 `AGENTS.md`를 따른다.



---

## 최신 게임 루프 계약

- Stage마다 제한 시간이 있다.
- 플레이 중 공을 바닥으로 보내는 것은 `Cashout`.
- 일반 Cashout = `Score + Time Bonus`.
- 고등급 공을 더 머지할지 Cashout해 시간을 확보할지 선택한다.
- Stage 최고 공 제작 = 즉시 Stage Clear.
- Time Up = 화면 공 `Final Settlement`.
- Final Settlement = `Score only`; Time Bonus 없음.
- Time Up 후 Final Stage Score가 `clear_score` 이상이면 Stage Clear.
- 부족하면 Run End.
- 성공한 Stage는 Settlement 후 `SCALE SHIFT`.
- Time Up 판정은 해당 physics tick의 Merge와 Active Cashout을 모두 반영한 뒤 수행한다.
- 같은 tick에서는 Top Ball Clear가 Time Up보다 우선한다.
- `stage_score`와 `run_score`는 점수 이벤트 때 함께 증가하며 Stage 종료 시 다시 합산하지 않는다.

---

## FILE: 01_PRODUCT_BRIEF.md

# Snowball Effect — Product Brief

## 1. 한 줄 피치

중앙의 픽셀 아케이드 실험 챔버에서 눈송이를 패들로 튕겨 합체시키고,
**고등급 공을 더 키울지 지금 떨어뜨려 점수와 시간을 확보할지 선택하면서**
눈덩이 → 행성 → 은하 → 블랙홀 → 우주 규모까지 폭주시키는 액션 머지 아케이드 게임.

---

## 2. 핵심 게임성

Snowball Effect의 실제 판단은 다음 한 문장이다.

> **더 머지해서 압도적인 점수를 노릴 것인가, 지금 Cashout해서 점수와 시간을 확보할 것인가?**

플레이어는 패들로 공을 살리기만 하지 않는다.

- `A / D`: 어디에서 공을 받을지 결정
- `← / →`: 어느 방향으로 다시 보낼지 결정
- 일부러 패들에서 비켜남: 지금 공을 Cashout할지 결정

따라서 패들은 `Save / Aim / Cashout`을 모두 수행한다.

---

## 3. 핵심 루프

```text
Stage Start
→ 기본 공 낙하
→ 패들 반사
→ 같은 단계 머지
→ 고등급 공 생성
→ KEEP or CASHOUT
   ├─ KEEP → 더 높은 머지 / 폭발적인 점수 가치
   └─ CASHOUT → Score + Time Bonus
→ Stage 최고 공 제작?
   ├─ YES → 즉시 Stage Clear
   └─ NO → 시간 계속 진행
→ Time Up?
   ├─ 화면 공 Final Settlement (Score Only)
   ├─ clear_score 이상 → Stage Clear
   └─ 미달 → Run End
→ 성공 시 SCALE SHIFT
→ 이전 최고 공이 다음 Stage의 기본 공
```

---

## 4. 점수와 시간

점수는 의도적으로 폭증한다.

```text
1
→ 100
→ 10,000
→ 1,000,000
→ 100M
→ 50B
→ 10T
→ ...
```

합체는 가치 보존이 아니라 **가치 폭발**이다.

각 Stage에는 local level별 `time_bonus`가 있다.

`time_bonus`는 같은 global ball이라도 현재 Stage의 local level에 따라 달라지며 점수처럼 폭증하지 않는다.
높은 공을 Cashout했을 때 몇 초의 추가 기회를 주는 완만한 자원이다.

중요:

```text
Active Cashout = Score + Time Bonus
Final Settlement = Score Only
```

이 차이 때문에 공을 계속 화면에 들고 있는 것이 항상 정답이 아니다.

---

## 5. Stage Clear

한 Stage를 통과하는 방법은 두 가지다.

### Top Ball Clear

현재 Stage 최고 공을 만들면 즉시 성공.

### Score Clear

시간이 먼저 끝났다면:

```text
Cashout Score
+
화면에 살아 있던 공의 현재 Score Value
=
Final Stage Score
```

`Final Stage Score >= clear_score`면 성공.

마지막 Galactic Stage는 다음 Stage가 없으므로 Time Up 후 최종 결과로 이동한다.

---

## 6. SCALE SHIFT

성공한 Stage가 끝나면 남은 공을 정산하고 Scale Shift가 발생한다.

핵심:

> 이전 Stage의 최고 공이 다음 Stage의 기본 공이 된다.

방금 어렵게 만든 공이 다음 순간 기본 공처럼 쏟아지는 것이
Snowball Effect라는 제목을 직접 체감시키는 핵심 장치다.

동시에:

- Stage World
- 기본 공
- Spawn Rate
- visual scale
- 파티클 밀도
- 사운드
- 기계 과부하 상태
- 일부 물리 규칙

이 재기준화된다.

---

## 7. Stage 구성

### Ground
Snowflake → Snowball → Big Snowball → Giant Snowball → Moon

### Planetary
Moon → Earth → Gas Giant → Sun → Supernova → Galaxy

### Galactic
Galaxy → Galaxy Cluster → supercluster → Quasar → Event Horizon → Black Hole

초기 Spawn 테스트 방향:

```text
6/s → 15/s → 35/s
```

정확한 Stage 시간, `clear_score`, `time_bonus`는 플레이테스트 데이터로 조정한다.

---

## 8. 화면 정체성

전체 비주얼:

> **Retro Pixel Arcade Machine × Cosmic Escalation**

16:9 전체가 플레이필드가 아니다.

```text
[ STAGE WORLD ] | [ CENTRAL PLAY FIELD ] | [ STAGE WORLD ]
```

중앙:

- 공
- 머지
- 패들
- Cashout

좌우:

- Stage 세계
- 기계 프레임
- 계기판
- 규모 상승 연출

---

## 9. 보상 연출

일반 머지:

- Vampire Survivors처럼 빠르고 빈번한 포화형 FX

고등급 이벤트:

- 현재 플레이 화면 freeze
- 전체 dim
- Pixel Machine CUT-IN
- 약 0.45~0.70초
- 이름 / 공 이미지 / 가치 또는 효과

Stage 최고 공:

- 일반 CUT-IN과 중복하지 않고 Stage Clear / Scale Shift를 우선

Cashout:

- Score popup
- Time Bonus popup
- 고등급일수록 강한 연출

Final Settlement:

- 화면의 공들이 점수판/중앙으로 빨려 들어가는 빠른 정산 연출
- Time Bonus는 발생하지 않음

---

## 10. 플레이어 판타지

초반:

> 몇 픽셀짜리 눈송이를 조심스럽게 튕김

중반:

> 높은 공을 한 단계 더 욕심낼지 지금 팔아 시간을 벌지 고민

후반:

> 기본 공 자체가 행성/블랙홀급으로 쏟아지고 기계가 우주 현상을 감당하지 못함

최종 인상:

> 처음에는 눈송이 실험이었는데 왜 우주가 망하고 있지?

---

## 11. 디자인 기둥

1. **Active Merge** — 플레이어가 궤도를 만든다
2. **Greed vs Cashout** — 보유와 현금화 사이의 선택
3. **Explosive Value** — 머지 점수는 비정상적으로 상승
4. **Time Economy** — 좋은 Cashout은 새 기회를 산다
5. **Scale Rebaselining** — 이전 최고가 다음 기본이 된다
6. **Readable Chaos** — 후반이 미쳐도 실제 공과 패들은 읽힌다
7. **Fast Premium Moments** — 중요 연출은 강하지만 짧다

---

## 12. MVP 핵심

반드시 남긴다.

- A/D 이동
- 방향키 각도
- 같은 단계 머지
- 폭증 점수
- Cashout
- 공별 Time Bonus
- Stage별 타이머
- 최고 공 즉시 Clear
- Time Up Final Settlement
- clear_score 기반 Score Clear
- Scale Shift
- 이전 최고 → 다음 기본
- Stage별 Spawn 증가
- 중앙 Play Field + 좌우 Stage World
- Retro Pixel Arcade Machine
- Web Export
- Result

---

## FILE: 02_GAME_RULES.md

# Snowball Effect — 확정 게임 규칙

이 문서는 게임 규칙의 최우선 기준이다.

---

## 1. 화면

16:9 전체가 실제 플레이 영역이 아니다.

```text
[ STAGE WORLD ] | [ CENTRAL PLAY FIELD ] | [ STAGE WORLD ]
```

중앙 Play Field에서만:

- 공 생성
- 공 이동
- 머지
- 패들
- 아이템
- Cashout

이 발생한다.

좌우/후방은 Stage World + Retro Pixel Arcade Machine 프레임/계기판 공간이다.

기준 해상도:

```text
1600 × 900
```

중앙 Play Field 폭은 플레이테스트로 결정한다.

---

## 1.1 HUD와 일시정지

플레이 중 HUD의 기본 정보는 다음과 같다.

- 점수
- 남은 시간
- 현재 활성 아이템
- 일시정지 진입 버튼
- 현재 Stage 공 족보

점수 영역 안에서 Stage Score와 Run Score를 어떻게 병기할지는 UI 튜닝 대상으로 두되, HUD의 최상위 정보 종류를 불필요하게 늘리지 않는다. 활성 아이템이 없을 때는 빈 슬롯 또는 비활성 상태로 표시한다.

공 족보는 수박게임의 진화표처럼 현재 Stage의 local 공 5~6종을 낮은 단계부터 최고 단계까지 순서대로 보여준다. 플레이어가 같은 공 두 개를 합치면 다음에 어떤 공이 되는지 화면을 떠나지 않고 확인할 수 있어야 한다.

- `local Lv0 → Lv1 → Lv2 → ... → Stage Top` 순서를 아이콘으로 표시한다.
- 현재 Stage에 포함된 공만 표시하고 Scale Shift 시 다음 Stage 족보로 교체한다.
- 족보는 Ball/Stage 데이터의 read-only 표현이며 Merge 결과를 직접 계산하거나 변경하지 않는다.

일시정지는 게임 화면 위에 modal로 열리며 다음 행동을 제공한다.

- 재개
- 다시 시작
- 설정
- 메인 화면

메인 화면은 기존 Title 화면 계획과 같은 진입 화면으로 취급한다. 정확한 Settings 항목과 Main 이동 시 Run 폐기 확인 방식은 해당 UI 구현 전에 확정한다. 현재 S1의 최소 Pause/Retry 구현이 이 확장 메뉴까지 완료된 것으로 간주하지 않는다.

---

## 2. 조작

| 키 | 기능 |
|---|---|
| `A` | 패들 왼쪽 이동 |
| `D` | 패들 오른쪽 이동 |
| `←` | 패들 반시계 방향 회전 |
| `→` | 패들 시계 방향 회전 |
| `Esc` | 일시정지 |

마우스 A/B 플레이테스트에서는 가장 최근 Mouse X를 Viewport/Canvas transform을 통해 Play Field의 logical X로 변환하고, physics tick의 현재 Paddle X에 즉시 반영한 뒤 field clamp한다. Mouse 조작에는 target 추적 speed cap을 두지 않는다. Keyboard fallback은 기존 속도 기반 이동을 유지할 수 있으며, 입력 source와 Paddle simulation transform 계약을 분리한다.

Mouse 직접 위치 반영은 무제한 타격 강도를 뜻하지 않는다. 반사에는 Mouse delta가 아니라 이전 physics tick의 Paddle transform과 이번 tick에 확정한 transform의 실제 변화로 계산한 simulation velocity를 사용하고, contact impact에는 별도 cap/tuning을 적용한다. 따라서 control responsiveness와 impact strength는 독립적이다.

Mouse Wheel Up/Down은 각각 shared Paddle angle을 증가/감소시킨다. Wheel과 `←/→`는 같은 angle state를 변경하며, 회전 각도에는 최소/최대 clamp가 없다. 표현상 동등한 각도로 정규화할 수 있으나 플레이어는 양방향으로 계속 회전할 수 있다.

`A/D`와 `←/→`는 비교용 fallback으로 유지한다. 키보드 이동과 회전은 동시에 사용할 수 있고, 마우스 이동과 Wheel 회전도 동시에 사용할 수 있다. 이 A/B 테스트는 최종 조작 체계를 확정하지 않는다.

플레이어는 공을 받지 않고 일부러 지나가게 만들어 Cashout할 수도 있다.

---

## 3. 공 이동 / 반사

- 현재 Stage의 기본 공이 Play Field 상단에서 생성된다.
- 기본 공에는 지속적인 아래 방향 중력이 없으며 `gravity = 0`이다.
- Spawn 시 아래쪽 반구를 향하는 초기 velocity를 받는다. 완전한 수직 하강일 필요는 없으며 좌우 성분의 범위와 분포는 tuning 대상이다.
- 충돌이나 명시적인 gameplay effect가 없으면 현재 velocity의 방향과 speed를 유지한다.
- 좌측·우측·상단 벽은 닫힌 반사 경계다. 해당 충돌 규칙이 별도로 speed를 바꾸지 않으면 충돌 전 speed를 유지한다.
- 하단은 벽이 없는 열린 경계다. 아래 방향으로 통과한 공은 Active Cashout/제거 경로로 들어간다.
- 공이 아래로 빠지는 이유는 중력이 아니라 Spawn 방향과 열린 하단 경계 때문이다.
- Paddle은 양면 모두 유효한 충돌면이다. 어느 면이든 실제 접촉 normal과 상대속도를 기준으로 접근 중일 때만 반사한다.
- 충돌은 현재 OBB 한 장의 overlap만 보지 않고, 한 physics tick의 이전/현재 Paddle transform과 공 trajectory 사이에서 가장 이른 연속 접촉을 찾는다.
- 패들에 닿으면 패들 각도, 충돌 위치, Paddle 중심 이동속도와 회전에 따른 접촉점 표면속도의 영향을 받아 새로운 방향과 runtime speed를 얻을 수 있다.
- Paddle hit은 공을 가속할 수 있지만 반복 타격의 무한 가속은 speed cap 또는 동등한 안전장치로 막는다. boost, min/max speed와 계산식은 tuning 대상이다.
- 반사 결과는 현실 물리보다 예측 가능성을 우선한다.

### Spawn speed와 runtime speed

- `base_speed` 또는 Spawn speed는 생성 시 초기 speed를 정해 초기 방향과 velocity를 만드는 기준값이다.
- 현재 Lv1 Shared Skeleton의 Spawn/base speed는 플레이테스트에서 너무 느린 것으로 확인되어 조정 대상이다. 일반적인 눈송이 낙하속도 약 `1.0 m/s`는 움직임의 현실 design reference일 뿐 Godot world unit과 직접 환산하지 않는다.
- 공간은 `1 world unit = 1 logical pixel`, 시간은 second, 게임 속도는 world units/s로 다룬다. Lv1의 `spawn_speed_world_units_per_second`는 한 곳에서 조정하는 게임-space tuning 값이며, 현재 첫 플레이테스트 값은 `160 world units/s`다. 이 값은 viewport 높이·화면 통과시간·전역 meter scale에서 계산하지 않는다.
- runtime velocity와 speed는 Paddle, 접촉 위치, 벽 규칙, Merge, Stage effect, Item, 특수 상태에 의해 달라질 수 있다.
- 같은 등급의 공도 플레이 과정에 따라 서로 다른 runtime speed를 가질 수 있다.
- 현재 버전은 `global_level`별 base speed 차이를 사용하지 않고 공통 Spawn tuning을 사용한다.
- 향후 등급별 `base_speed`를 도입할 수 있지만 이는 생성 기준일 뿐 runtime speed 고정값이 아니다.

### Lv1 크기와 초반 압박

- Lv1은 거의 `.`처럼 읽히는 매우 작은 저해상도 픽셀 눈알갱이다. visual diameter와 simulation/collision diameter는 같은 값으로 시작한다.
- 현재 Lv1 Shared Skeleton의 승인된 기본 크기는 약 8 logical pixel 직경이며, visual/collision 크기는 같은 값으로 유지한다. 이후 크기 변경은 별도 플레이테스트 결정으로만 수행한다.
- 초반 압박은 거대한 Lv1 몇 개가 아니라 작은 공의 물량과 Paddle 이후 생길 수 있는 runtime speed 변화에서 온다.

---

## 4. 머지

같은 `global_level`의 활성 공 두 개가 접촉하면:

```text
Level N + Level N → Level N+1
```

MVP에서 다른 레벨 공은 서로 통과 가능하다.

합체 결과:

- 두 입력 공 제거
- 중간 위치에 상위 공 생성
- 결과 velocity의 방향·speed·계승 방식은 S2 Merge velocity 계약에서 별도로 확정
- 다음 물리 프레임부터 재머지 가능
- 점수 가치와 비주얼 레벨 상승
- Stage 최고 공 여부 확인

---

## 5. 점수

점수는 보존하지 않는다.

상위 공의 `score_value`는 직접 데이터로 정의하며
머지할수록 실질적으로 지수함수 수준으로 폭증한다.

초기 예:

| global_level | 이름 | score_value | `base_color` seed | `fx_tier` |
|---:|---|---:|---|---:|
| 0 | Snowflake | 1 | `#F4FCFF` | 0 |
| 1 | Snowball | 100 | `#EAF8FF` | 1 |
| 2 | Big Snowball | 10,000 | `#72D8FF` | 1 |
| 3 | Giant Snowball | 1,000,000 | `#3A8DFF` | 1 |
| 4 | Moon | 100,000,000 | `#C8C9D8` | 2 |
| 5 | Earth | 50,000,000,000 | `#2878D4` | 2 |
| 6 | Gas Giant | 10,000,000,000,000 | `#D79A57` | 2 |
| 7 | Sun | 1.0e15 | `#FFC247` | 2 |
| 8 | Supernova | 5.0e17 | `#FF6B35` | 2 |
| 9 | Galaxy | 1.0e21 | `#4D42B8` | 3 |
| 10 | Galaxy Cluster | 1.0e25 | `#805CFF` | 3 |
| 11 | Supercluster | 1.0e30 | `#5E75F2` | 3 |
| 12 | Quasar | 1.0e36 | `#E8E6FF` | 3 |
| 13 | Event Horizon | 1.0e43 | `#3A1A61` | 3 |
| 14 | Black Hole | 1.0e50 | `#10091F` | 4 |

`base_color`는 BallDefinition의 기본 식별색 seed다. 다중 색상 텍스처·후광·파티클은 Presentation이 이 값을 보조 팔레트와 함께 해석해 표현한다. 기존에 확정한 Lv13 `1.0e43`, Lv14 `1.0e50` 점수는 팀장 원안의 순서에 따라 각각 `Event Horizon`, `Black Hole`에 유지한다. Lv0 반지름 `2`를 기준으로 레벨마다 반지름을 2배(`radius = 2 ^ (global_level + 1)`)로 사용한다. 이에 맞춰 질량은 Lv0의 `1`을 기준으로 레벨마다 4배(`mass = 4 ^ global_level`)를 사용한다. 따라서 아직 리소스가 없는 Lv7~14에도 두 규칙을 적용한다. 화면상 크기 보정은 BallDefinition이 아니라 StageDefinition의 `visual_radius_scale`이 소유하며, 물리 `radius`와 충돌 반지름을 바꾸지 않는다. visual key는 표시 이름의 snake_case(`gas_giant`, `galaxy_cluster`, `event_horizon`, `black_hole` 등)를 사용한다. 나머지 수치는 플레이테스트용이며 데이터에서 수정한다.

`fx_tier`는 일반 Merge/Cashout의 기본 연출 우선순위이며 전역 `BallDefinition`이 소유한다. Snowflake(Lv0)는 0, Snowball(Lv1)부터 Giant Snowball(Lv3)은 1, Moon(Lv4)부터 Supernova(Lv8)는 2, Galaxy(Lv9)부터 Event Horizon(Lv13)은 3, 최종 Black Hole(Lv14)은 4를 사용한다. Moon과 Galaxy가 다음 Stage의 기본 공으로 재사용되어도 같은 전역 tier를 유지한다. 현재 Stage의 최고 공 생성은 `fx_tier`와 관계없이 Stage Clear 연출을 우선한다.

---

## 6. Cashout

공이 패들 아래 Score Zone을 통과하면
플레이 중 `Cashout`으로 처리한다.

```text
Cashout Reward
=
score_value
+
time_bonus
```

정확히는 `calculate_cashout_score()`로 Active Cashout 점수를 계산한 뒤:

- `stage_score`에 Cashout 점수 추가
- `run_score`에 같은 Cashout 점수 추가
- Stage 남은 시간에 현재 local level의 `time_bonus` 추가
- 공 제거
- Score / Time popup
- 고등급 Cashout일수록 강한 연출

`stage_score`는 현재 Stage의 부분합이고 `run_score`는 Run 전체 누적 합이다.
모든 점수 이벤트에서 두 값에 같은 amount를 한 번씩 더한다.
Stage 종료 시 `run_score += stage_score`를 다시 수행하지 않는다.

바닥은 실패가 아니다.

---

## 7. Time Bonus

각 StageDefinition은 `time_bonus_by_local_level`을 가진다.

같은 global ball이 이전 Stage의 최고 공에서 다음 Stage의 기본 공으로 바뀌므로
Time Bonus를 BallDefinition의 고정값으로 저장하지 않는다.

점수와 달리 시간은 완만하게 증가한다.

초기값:

| Stage 내 상대 등급 | time_bonus |
|---|---:|
| Base / Local Lv0 | 0s |
| Local Lv1 | +0.25s |
| Local Lv2 | +0.5s |
| Local Lv3 | +1s |
| Local Lv4 | +2s |
| Local Lv5 | +4s |

최고 local 공은 생성 즉시 Stage Clear가 잠기므로 일반 Active Cashout 보너스를 실제로 받지 않는다. 따라서 Ground의 Moon(Local Lv4), Planetary의 Galaxy(Local Lv5), Galactic의 Black Hole(Local Lv5)은 표에는 있으나 일반 Cashout 대상이 아니다.

목표:

- 고등급 Cashout을 의미 있게 함
- 더 높은 머지와 시간 확보 사이 선택을 만듦
- 무한 플레이가 되지 않게 함

초기 구현에는 Stage 시간 상한을 강제하지 않는다.
실제 획득 시간과 local level별 Cashout 횟수를 측정한 뒤 시간 인플레가 확인될 때만 상한을 검토한다.

---

## 8. KEEP vs CASHOUT

고등급 공을 계속 살리면:

- 더 높은 공으로 머지 가능
- 점수 가치가 폭발적으로 증가할 수 있음

지금 떨어뜨리면:

- 현재 점수 확정
- Time Bonus 확보
- 새로운 머지를 위한 플레이 시간을 얻음

따라서 플레이어는 공을 단순히 오래 유지하는 것이 아니라
언제 Cashout할지 판단한다.

---

## 9. Stage

각 Stage는 독립적인 제한 시간 라운드다.

Stage 데이터:

```text
stage_index
base_global_level
top_global_level
base_time
clear_score
spawn_rate
```

현재:

1. Ground
2. Planetary
3. Galactic

---

## 10. Stage Clear — Top Ball Clear

현재 Stage 최고 공을 만들면 즉시 Stage 성공 판정.

예:

```text
Ground
Snowflake → Snowball → Big Snowball → Giant Snowball → Moon

Moon Created
→ STAGE CLEAR
```

점수컷은 보지 않는다.

최고 공 자체는 먼저 정상적으로 생성된 뒤 성공 이벤트를 발생시킨다.
성공 판정은 `CLEAR_LOCKED`로 즉시 잠그지만, Scale Shift는 Final Settlement 완료 후 실행한다.

---

## 11. Stage Clear — Score Clear

최고 공을 만들기 전에 Stage 시간이 `0` 이하로 확정되면
`TIME_UP_LOCKED` 후 `FINAL SETTLEMENT`로 이동한다.

Time Up은 physics tick 시작 시각만으로 판정하지 않는다.
해당 tick의 Merge와 Active Cashout을 먼저 확정해 Time Bonus까지 반영한 뒤 종료 여부를 판단한다.
따라서 시간이 잠시 0 이하가 되어도 같은 tick의 Cashout으로 양수가 되면 플레이를 계속한다.
같은 tick에 Top Ball이 생성되면 Top Ball Clear가 Time Up보다 우선한다.

Final Stage Score:

```text
이미 Cashout한 Stage Score
+
현재 화면 모든 활성 공의 score_value
```

판정:

```text
Final Stage Score >= clear_score
→ Stage Clear

Final Stage Score < clear_score
→ Run End
```

---

## 12. Final Settlement

Stage 종료 시 남은 활성 공을 빠르게 정산한다.

중요:

```text
Final Settlement = Score Only
```

**Time Bonus를 절대 주지 않는다.**

화면 공끼리 실제 추가 머지를 계산하지 않는다.
현재 각 공의 기본 `score_value`만 더한다.
Active Cashout 전용 modifier는 적용하지 않는다.

Settlement는 활성 공 snapshot을 한 번 만들고 점수를 일괄 계산한다.
계산된 `settlement_score`는 `stage_score`와 `run_score`에 각각 한 번만 더한다.
일반 Cashout 함수를 호출하지 않으며 `settlement_applied` 잠금으로 중복 실행을 막는다.

연출:

- 공들이 점수판/중앙으로 빨려 들어감
- 숫자가 빠르게 누적
- Stage Score 확정

---

## 13. SCALE SHIFT

Stage 성공 후 Settlement가 끝나면 Scale Shift.

다음 Stage 진입 시:

- `stage_score = 0`
- `stage_time = next_stage.base_time`
- `run_score`, 통계, 최고 기록은 유지

핵심:

> 이전 Stage 최고 공 = 다음 Stage 기본 공

동시에:

- Stage World 변경
- 새 기본 `global_level`
- Spawn Rate 증가
- 공 visual radius 재정규화
- 파티클 밀도 변화
- 사운드 변화
- 기계 상태 변화
- 필요 시 Stage별 물리 변화

---

## 14. Stage 구성

각 Stage는 해당 세계관에 맞는 local 공 5~6종을 사용한다. 전체 Run의 초기 콘텐츠 목표는 중복을 제외한 global 공 15종이다. 이전 Stage의 최고 공이 다음 Stage의 기본 공으로 재사용되므로, Stage별 개수를 단순 합산한 값과 global 공 종류 수는 다를 수 있다.

아래 이름은 현재 테마와 Scale Shift 연결을 보여주는 seed다. 최종 15종의 정확한 Stage 배분, 명칭, 반지름과 점수는 `BallDefinition`/`StageDefinition` 데이터로 확정하며 플레이테스트에서 종류가 과도하다는 피드백이 나오면 축소할 수 있다.

### Ground

```text
Snowflake → Snowball → Big Snowball → Giant Snowball → Moon
```

초기 Spawn: 약 `6/s`

초기 `clear_score`: `4e6` (Giant Snowball 4개 Cashout 상당)

### Planetary

```text
Moon → Earth → Gas Giant → Sun → Supernova → Galaxy
```

초기 Spawn: 약 `15/s`

초기 `clear_score`: `2e18` (Supernova 4개 Cashout 상당)

### Galactic

```text
Galaxy → Galaxy Cluster → Supercluster → Quasar → Event Horizon → Black Hole
```

초기 Spawn: 약 `35/s`

마지막 Stage이므로 `clear_score` 판정을 사용하지 않는다. 데이터 기본값은 `0`이다.

정확한 Stage 제한 시간과 `clear_score`는 밸런스 데이터에서 정한다.

---

## 15. Galactic 최종 Black Hole 기믹

- 거대한 블랙홀이 좌우로 움직임
- 모든 공에 약한 인력을 적용
- 인력은 최대치를 제한
- 패들 조작의 의미를 없애지 않음
- 공을 모아 연쇄 머지를 유도할 수도 있음

이 기믹은 Lv14 `Black Hole` Snowball과 별개의 맵 요소다. 마지막 Galactic Stage의 최고 공은 Lv14 `Black Hole` Snowball이며, 생성 시 다음 Stage 없이 Final Settlement와 Result로 진행한다.

### Black Hole 생성
`MAX SCALE / PERFECT CLEAR → Final Settlement → Result`

### Time Up
`Final Settlement → Result`

다음 Stage 점수컷 판정은 없다.

---

## 16. 아이템

아이템은 아이템을 품은 행성형 `Item Ball`로 Play Field에 등장하며, 현재 Stage의 **3단계 이상 Snowball**이 충돌할 때마다 점차 깨진다.

- 사람 기준 3단계 이상은 데이터의 0-based 표기로 `local_level >= 2`다.
- Stage가 local 공 4종이든 5종이든 3단계, 4단계, 5단계 공은 모두 유효 damage를 줄 수 있다.
- 유효 충돌 한 번당 파괴 hit를 한 번만 반영하고, 같은 접촉의 frame 중복 damage를 막는다.
- hit가 누적될수록 균열·픽셀 파편 등 단계적인 damage 표현을 보여준다.
- 필요한 hit 수는 `ItemDefinition`의 플레이테스트 tuning 값이다.
- 마지막 hit에서 Item Ball 파괴와 아이템 획득을 한 번만 확정하고 CUT-IN을 요청한다.
- CUT-IN의 activation cue에 맞춰 효과를 시작하되, 연출 실패가 아이템 유실이나 중복 적용을 만들지 않게 한다.
- 1~2단계 공과 Paddle은 Item Ball을 즉시 획득하거나 파괴하지 않는다.
- Item Ball은 일반 Snowball Merge 대상이 아니다.
- Item Ball을 놓치면 효과 없이 제거한다.
- 아이템 효과는 Optional Item Layer에 남으며 Core Merge/Settlement 계약을 바꾸지 않는다.

### Blizzard
일정 시간 Spawn Rate 증가.

### Magnet
같은 레벨 근처 공을 약하게 끌어당김.

### Fire Core
패들이 일정 시간 Fire 상태가 되고,
맞은 공이 Fire Snowball이 된다.

Fire 공:

- 같은 레벨 Normal과 머지 가능
- 머지 후 Fire 유지
- Cashout 점수 배수 가능
- 눈 + 불꽃 연출

---

## 17. 고등급 CUT-IN

일반 머지 파티클보다 중요한 이벤트에만 사용한다.

- 현재 게임 이벤트 먼저 확정
- 현재 장면 전체 freeze
- Play Field와 Stage World 전체 dim
- Pixel Machine 패널 진입
- 공 이름 / 이미지 / VALUE 또는 효과
- 빠르게 퇴장
- 즉시 플레이 재개

초기 총 길이:

```text
0.45 ~ 0.70초
```

Stage 최고 공은 곧 Stage Clear / Scale Shift로 이어지므로
일반 CUT-IN과 중복하지 않는다.

---

## 18. 종료 / 결과

Run 종료 시 결과:

- 최종 누적 점수
- 최고 도달 Stage
- 최고 생성 공
- 최고 Cashout 공
- 총 머지 수
- Cashout으로 획득한 총 추가 시간
- 아이템 획득 수
- 최대 동시 활성 공 수

Retry 가능.

---

## 19. 밸런스 핵심

플레이테스트에서 반드시 확인:

### Time Economy
Cashout으로 얻는 평균 추가 시간이 소비 시간보다 너무 커서 무한 루프가 되지 않는가?

### Score Clear
기본 공만 무작정 Cashout해서 `clear_score`를 쉽게 넘기지 않는가?

### Merge Reward
높은 단계까지 머지하는 것이 압도적으로 유리한가?

### Player Agency
초반에는 조작을 잘한 플레이어가 더 빠르게 성장하는가?

### Endgame Chaos
후반 자동 연쇄가 늘어도 실제 공과 패들이 읽히는가?

### Known balancing observation — Vertical Paddle Keep strategy

> **향후 플레이테스트 관찰용 메모이며 확정 게임 계약 또는 구현 지시가 아니다. Merge와 높은 Spawn density가 들어온 뒤 재검토한다.**

현재 `gravity = 0`, 자유회전, 양면 Paddle 물리에서 다음 emergent play가 관찰됐다.

```text
Paddle을 거의 세로로 세움
+
Mouse X로 좌우로 빠르게 흔듦
→ Snowball들이 거의 수평으로 반사
→ 일부는 조금씩 위로 이동
→ Bottom Cashout을 상당히 오래 방지 가능
```

현재는 버그로 확정하지 않는다. Merge와 높은 Spawn density가 들어오면 공을 유지해 Merge를 노리는 숙련 KEEP 전략인지, KEEP vs CASHOUT 선택에 의미를 주는지, 또는 공 축적 위험이라는 trade-off가 생기는지를 먼저 플레이테스트한다.

이후 `Vertical Paddle + 좌우 흔들기`가 대부분 상황에서 거의 무위험 최적해가 되면 dominant strategy / balancing issue로 재검토한다. 그 전에는 이를 막기 위해 gravity, minimum Y velocity, 수평 반사 금지, 세로 Paddle 페널티, 인위적인 downward bias를 추가하지 않는다.

**상태: Known balancing observation / revisit after Merge + higher density.**

### Future Stage Modifier candidate — Snowstorm / Wind Stage

> **향후 후보 메모이며 확정 게임 계약, Stage Task, 구현 승인이 아니다.**

후보 개념은 공통 Stage wind state가 Ball의 X축 운동에 영향을 주고, 바람 방향과 세기가 시간에 따라 변하는 Snowstorm / Blizzard Stage다. normal gravity는 계속 `0`으로 둔다. 바람은 주로 수평 운동에 영향을 주는 Stage effect로만 검토한다.

매 physics frame마다 완전 랜덤한 값을 생성하지 않고, 몇 초 동안 유지·전환되는 gust interval을 후보로 둔다.

```text
calm
→ weak right
→ strong right
→ fade
→ left
→ strong gust
```

향후 Presentation은 snow particle 방향, Stage World 효과, 배경/환경 움직임을 같은 wind state에 맞출 수 있다.

Ball 크기/레벨별 영향 차이, 정확한 wind acceleration, gust 지속시간, Stage 번호·등장 위치, 난이도 보정, Merge와의 상호작용은 아직 결정하지 않는다.

**상태: Future Stage Modifier candidate. 구현 승인 아님.**

### Future Core Mechanic candidate — Paddle Charge / Spring Launch

> **향후 후보 메모이며 확정 게임 계약, Task, 구현 승인이 아니다. Merge 및 Vertical Paddle Keep의 밸런스를 본 뒤 구현 여부를 결정한다.**

후보 조작은 Paddle을 아래로 당겼다가 놓아 기준 Y로 실제 spring-back시키는 Charge / Spring Launch다.

```text
Mouse: paddle click + downward drag + release
Keyboard: ↓ hold + release
release → Paddle이 기준 Y로 실제 spring-back
```

강타는 기존 Paddle의 실제 transform 변화에서 나온 contact velocity와 continuous collision으로만 발생시킨다. 공에 별도의 직접 가속 보너스를 부여하지 않는다.

**상태: Future Core Mechanic candidate. 구현 승인 아님.**

---

## FILE: 09_GAMEPLAY_LOOP_V2.md

# Snowball Effect — Game Planning v2

## 0. 게임 한 줄 정의

> **레트로 픽셀 아케이드 실험기계 안에서 눈송이를 패들로 튕겨 합체시키고,  
> 고등급 공을 더 키울지 지금 Cashout할지 선택하며,  
> 눈덩이 → 행성 → 은하 → 블랙홀 → 우주 규모까지 폭주시키는 3분 내외 액션 머지 아케이드 게임.**

핵심은 단순히 큰 공을 만드는 것이 아니다.

플레이어는 계속 다음 선택을 한다.

```text
이 공을 계속 살려서 한 단계 더 머지할까?
vs
지금 일부러 떨어뜨려 점수와 시간을 확보할까?
```

이 선택이 Snowball Effect의 핵심 게임성이다.

---

# 1. 핵심 재미

Snowball Effect의 재미는 네 가지가 겹치는 데서 나온다.

1. **패들 조작**
   - 어디에서 받을지
   - 어느 방향으로 보낼지

2. **머지**
   - 같은 단계 공끼리 부딪히게 만들어 상위 공 제작

3. **Cashout 판단**
   - 높은 공을 더 키울지
   - 지금 떨어뜨려 점수 + 시간을 받을지

4. **Scale Shift**
   - 이전 Stage에서 최고 등급이었던 공이
   - 다음 Stage에서는 기본 공으로 쏟아짐

즉:

```text
Control
→ Merge
→ Greed or Cashout
→ More Time
→ Bigger Merge
→ Stage Clear
→ Scale Shift
→ Everything gets absurd
```

---

# 2. 기본 조작

## 이동

- `A / D` : 패들 좌우 이동

## 각도

- `← / →` : 패들 각도 조절

이동과 각도 변경은 동시에 가능하다.

패들 조작은 두 가지 역할을 한다.

### 살리기

공 아래로 이동해 받아서 다시 위로 튕긴다.

### 버리기

일부러 공 아래에서 비켜나 고등급 공을 Cashout한다.

따라서 `A/D`는 단순 생존 조작이 아니라
**보유 / 현금화 판단을 실행하는 조작**이다.

---

# 3. 공과 머지

같은 `global_level`의 공 두 개가 접촉하면:

```text
Level N + Level N
→
Level N+1
```

다른 레벨 공은 MVP에서 서로 통과할 수 있다.

---

## 3.1 머지 가치

머지는 단순 합산이 아니다.

상위 공은 이전 공의 합보다 훨씬 큰 가치를 가진다.

예:

```text
Snowflake       1
Snowball        100
Big Snowball    10,000
Giant Snowball  1,000,000
...
```

점수는 실질적으로 지수함수처럼 폭증한다.

따라서:

> 높은 공을 만드는 것 자체가 압도적으로 이득이다.

하지만 높은 공을 무조건 끝까지 들고 있는 것이 항상 정답은 아니다.

그 이유가 Cashout의 **TIME BONUS**다.

---

# 4. Cashout

공이 패들 아래 Score Zone으로 떨어지면 제거되며
해당 공의 보상을 즉시 획득한다.

```text
Cashout
=
Score
+
Time Bonus
```

바닥은 실패 구역이 아니다.

---

## 4.1 Cashout의 의미

높은 공을 계속 보유:

```text
장점
→ 다음 머지 가능
→ 점수 가치가 훨씬 더 커질 수 있음

위험
→ Stage 시간이 부족해질 수 있음
```

지금 Cashout:

```text
장점
→ 현재 점수 확정
→ Time Bonus 확보
→ 더 오래 플레이 가능

대가
→ 그 공으로 다음 머지를 할 수 없음
```

이 때문에 플레이어는 계속:

> 욕심을 더 낼지, 지금 현금화할지

판단한다.

---

# 5. Time Bonus

각 Stage는 공의 local level별 `time_bonus` 값을 가진다.

같은 global ball이 다음 Stage에서 다른 local level이 될 수 있으므로
Time Bonus를 BallDefinition의 고정값으로 저장하지 않는다.

시간 증가는 점수처럼 폭발적으로 커지지 않는다.

목적은:

- 고등급 Cashout에 의미 부여
- 플레이 시간을 조금 연장
- 추가 머지 기회 제공
- 시간 압박과 욕심의 균형 생성

이다.

초기 테스트 방향:

| Stage 내 상대 등급 | Time Bonus 예시 |
|---|---:|
| 기본 공 / Local Lv0 | 0s |
| Local Lv1 | 소량 |
| Local Lv2 | 의미 있는 시간 |
| Local Lv3 | Stage Clear |

정확한 값은 플레이테스트로 조정한다.

---

## 5.1 중요한 규칙

직접 Cashout:

```text
Score + Time Bonus
```

Time Up 후 화면에 남은 공 정산:

```text
Score Only
```

**최종 정산에서는 Time Bonus를 주지 않는다.**

그래야 플레이 중 일부러 높은 공을 떨어뜨릴 이유가 생긴다.

---

# 6. Stage 구조

각 Stage는 독립적인 짧은 라운드다.

현재 Stage:

1. Ground
2. Planetary
3. Galactic

각 Stage에는:

- 기본 공
- 중간 공
- 최고 공
- 제한 시간
- Clear Score
- Spawn Rate

가 있다.

---

# 7. Stage Clear 조건

Stage를 통과하는 방법은 두 가지다.

---

## 7.1 최고 공 제작 — 즉시 Clear

현재 Stage의 최고 공을 만들면 즉시 Stage Clear.

예:

```text
Ground

Snowflake
→ Snowball
→ Big Snowball
→ Giant Snowball
→ Moon

Giant Snowball 생성
→ STAGE CLEAR
```

점수 조건은 보지 않는다.

이것이 가장 좋은 클리어 방식이다.

---

## 7.2 Time Up — Score Clear

최고 공을 만들기 전에 시간이 0이 되면:

```text
TIME UP
```

그 순간:

```text
기존 Cashout Score
+
화면에 남아 있는 모든 공의 현재 Score Value
=
Final Stage Score
```

화면 공은 자동 정산한다.

Time Bonus는 발생하지 않는다.

그 후:

```text
Final Stage Score >= Clear Target
```

이면 다음 Stage로 진출.

부족하면 Run 종료.

---

# 8. Stage 종료 흐름

## 최고 공으로 Clear

```text
Top Ball Created
↓
STAGE CLEAR
↓
남은 공 Final Settlement
↓
Score 정산
↓
SCALE SHIFT
↓
Next Stage
```

## 시간 종료로 Clear

```text
TIME UP
↓
남은 공 Final Settlement
↓
Final Stage Score 계산
↓
Clear Target 판정
├─ PASS → SCALE SHIFT
└─ FAIL → RUN END
```

---

# 9. Final Settlement

Stage 종료 시 화면에 남은 모든 공을 한 번에 정산한다.

연출:

- 공들이 점수판 또는 화면 중심으로 빨려 들어감
- 공마다 점수 숫자가 빠르게 누적
- 마지막에 Stage Score 확정

중요:

- 실제로 남은 공끼리 다시 머지시키지는 않음
- 현재 각 공의 기본 `score_value`를 합산
- Time Bonus는 적용하지 않음
- Active Cashout 전용 modifier는 적용하지 않음

---

# 10. SCALE SHIFT

다음 Stage로 넘어갈 때 발생하는 핵심 연출.

중요한 규칙:

> 이전 Stage의 최고 공이 다음 Stage의 기본 공이 된다.

예:

```text
Ground의 최고
Giant Snowball
↓
Planetary의 기본 공
Giant Snowball
```

따라서:

> “방금 그렇게 힘들게 만든 게 이제 비처럼 떨어진다.”

라는 경험을 만든다.

---

## 10.1 Scale Shift에서 바뀌는 것

동시에 변경:

- Stage World
- 기본 공
- Spawn Rate
- 공의 화면상 Scale 기준
- 파티클 밀도
- 사운드
- 계기판 상태
- 일부 물리 규칙

---

# 11. Stage 구성

## Stage 0 — Ground

```text
Snowflake
→ Snowball
→ Big Snowball
→ Giant Snowball
```

배경:

- 밝은 초원
- 언덕
- 집
- 나무

기계:

- 정상
- 여유로운 계기판

Spawn:

- 초기 약 6/s

---

## Stage 1 — Planetary

```text
Moon
→ Earth
→ Gas Giant
→ Sun
→ Supernova
→ Galaxy
```

배경:

- 지구
- 달
- 위성
- 우주 구조물

Spawn:

- 초기 약 15/s

---

## Stage 2 — Galactic

```text
Galaxy
→ Galaxy Cluster
→ Supercluster
→ Quasar
→ Event Horizon
→ Black Hole
```

배경:

- 성운
- 은하
- 우주 먼지
- 별무리

Spawn:

- 초기 약 35/s

기계:

- 과부하 징후
- 경고등
- 일부 글리치

맵 기믹:

- 상단의 이동하는 Black Hole은 Lv14 Snowball과 별개인 맵 요소다.
- 모든 활성 공에 약한 인력을 적용하되, 패들 조작과 Cashout 경로를 막지 않는다.

---

Stage 2가 마지막 Stage이므로 다음 Stage는 없다.

# 12. Galactic Stage 종료

## Black Hole 완성

```text
Black Hole
→ PERFECT / MAX SCALE CLEAR
→ Final Settlement
→ Result
```

여기서 완성되는 `Black Hole`은 Lv14 Snowball이다. 상단의 Black Hole은 마지막 Galactic Stage 동안 궤적에 간섭하는 맵 기믹이며, 별도 Stage나 별도 공 등급이 아니다.

## Time Up

```text
TIME UP
→ Final Settlement
→ Result
```

마지막 Stage에서는 다음 Stage 진출용 Score Cut은 필요하지 않다.

최종 점수 경쟁으로 끝낸다.

---

# 13. 화면 구조

16:9 전체가 Play Field가 아니다.

```text
[ STAGE WORLD ] | [ CENTRAL PLAY FIELD ] | [ STAGE WORLD ]
```

중앙 세로 영역:

- 공
- 머지
- 패들
- 아이템
- Cashout

좌우:

- Stage 세계
- Retro Pixel Arcade Machine
- 계기판
- 장치
- 배경 연출

---

# 14. 디자인 컨셉

## 메인 방향

> **Retro Pixel Arcade Machine × Cosmic Escalation**

초반:

> 작은 눈덩이 실험기계

후반:

> 우주급 현상을 억지로 담고 있는 과부하 아케이드 장치

키워드:

- pixel
- chunky
- industrial
- arcade
- mechanical
- rough
- cosmic
- absurd

---

# 15. 일반 머지 연출

Vampire Survivors처럼 화면 곳곳에서 계속 보상이 터지는 느낌.

저등급:

- 작은 눈가루
- 작은 플래시
- 짧은 효과음

중등급:

- 얼음 파편
- 링
- 점수 숫자

고등급:

- 큰 파티클
- 화면 흔들림
- 히트스톱
- 특별 사운드

---

# 16. 고등급 CUT-IN

중요한 공 또는 특수 효과는 짧은 CUT-IN을 사용할 수 있다.

일반 동작:

```text
중요 이벤트 확정
↓
현재 게임 화면 freeze
↓
Play Field + Stage World 전체 dim
↓
픽셀 기계 패널 진입
↓
공 이름 / 이미지 / VALUE
↓
빠르게 퇴장
↓
게임 즉시 재개
```

초기 시간:

```text
0.45 ~ 0.70초
```

1초 이상은 기본적으로 피한다.

---

## 16.1 CUT-IN과 Scale Shift

최고 공은 곧 Stage Clear를 발생시키므로
일반 CUT-IN과 Scale Shift를 연속해서 중복하지 않는다.

예:

```text
Big Snowball
→ CUT-IN 가능

Giant Snowball
→ SCALE SHIFT
```

Planetary:

```text
Earth Snowball
→ CUT-IN 가능

Galaxy
→ SCALE SHIFT
```

Galactic:

```text
Galaxy Snowball
→ CUT-IN 가능

Black Hole
→ FINAL RESULT 연출
```

---

# 17. 아이템

## Blizzard

일정 시간 Spawn Rate 증가.

## Magnet

같은 단계 공끼리 약하게 끌어당겨 머지를 유도.

## Fire Core

패들이 일정 시간 Fire 상태.

맞은 공:

```text
Fire Snowball
```

특징:

- 같은 단계 일반 공과 머지 가능
- Fire 상태 전파
- Cashout Score 배수
- 눈 + 불꽃 파티클

---

# 18. 게임의 전략 구조

게임의 실질적인 판단은 다음과 같다.

```text
낮은 공
→ 가능한 한 머지

높은 공
→ 더 머지할 것인가?
→ Cashout할 것인가?
```

시간이 충분하면:

```text
KEEP
→ 더 높은 단계 노림
```

시간이 부족하면:

```text
CASHOUT
→ 점수 확보
→ 시간 확보
→ 새 공들로 추가 머지
```

따라서 가장 높은 점수를 노리는 플레이는 단순히:

> 모든 공을 계속 살린다

가 아니다.

---

# 19. 밸런스에서 확인할 것

정확한 수치는 구현 후 플레이테스트한다.

특히:

### Time Economy

평균적으로 Cashout으로 얻는 시간이
플레이에 소비되는 시간보다 지나치게 많으면
Stage가 사실상 끝나지 않는다.

### Clear Score

최고 공을 못 만들더라도
충분히 잘 머지한 플레이어는 Score Clear가 가능해야 한다.

반대로 기본 공만 계속 Cashout해서
쉽게 Clear Target을 넘으면 안 된다.

### Player Agency

초반에는 패들 조작을 잘한 플레이어가
가만히 있는 플레이어보다 확실히 빠르게 성장해야 한다.

후반에는 Snowball Effect답게
자동 연쇄 머지 비중이 늘어도 된다.

---

# 20. 플레이 경험 곡선

## Stage 초반

- 공 적음
- 조작 정확성 중요
- 머지 목표가 명확

## Stage 중반

- 공 증가
- Cashout 판단 시작
- 높은 공과 낮은 공이 동시에 존재

## Stage 후반

- 시간 압박
- 높은 공 Cashout 유혹
- 최고 공 제작 경쟁

## Scale Shift

- 모든 기준 리셋
- 이전 최고 공이 기본 공으로 등장
- 플레이어가 즉시 스케일 상승 체감

---

# 21. MVP 핵심

반드시:

- A/D 이동
- 방향키 각도
- 같은 단계 머지
- 지수적 점수 폭증
- Cashout
- Stage local level별 Time Bonus
- Time Up Final Settlement
- 최고 공 즉시 Stage Clear
- Score Cut Stage Clear
- Scale Shift
- 이전 최고 → 다음 기본
- Stage별 Spawn 증가
- 중앙 Play Field + 좌우 Stage World
- 픽셀 아케이드 기계
- 고등급 연출
- Web Export
- Result

---

# 22. 일정 부족 시 제거 순서

1. Magnet
2. 복잡한 Fire 전파
3. Black Hole 화면 왜곡 Shader
4. 일부 CUT-IN 종류
5. 개별 고급 공 애니메이션
6. 추가 배경 디테일

제거하지 않음:

- 머지
- Cashout
- Time Bonus
- Stage Clear 두 방식
- Final Settlement
- Scale Shift
- 이전 최고 → 다음 기본
- 패들 이동 + 각도

---

# 23. 현재 게임의 핵심 한 문장

> **더 큰 공을 만들수록 점수는 폭발하지만,  
> 그 공을 언제 떨어뜨려 점수와 시간을 확보할지 결정해야 하는  
> 스케일 폭주형 액션 머지 게임.**

---

## FILE: DESIGN/README.md

# DESIGN

Snowball Effect의 시각/프레젠테이션 설계.

읽기 순서:

1. `00_VISUAL_IDENTITY.md`
2. `01_SCREEN_COMPOSITION.md`
3. `02_STAGE_ART_DIRECTION.md`
4. `03_GAMEPLAY_EFFECTS.md`
5. `04_CUTIN_SYSTEM.md`

게임 규칙과 충돌하면 `02_GAME_RULES.md`가 우선한다.
기술 구현은 `03_TECHNICAL_DESIGN.md`와 함께 확인한다.

---

## FILE: DESIGN/00_VISUAL_IDENTITY.md

# Snowball Effect — Visual Identity

이 문서는 Snowball Effect의 전체 시각 정체성을 정의한다.

---

## 1. 한 줄 디자인 정의

> **Retro Pixel Arcade Machine × Cosmic Escalation**

다르게 표현하면:

> 90년대 픽셀 아케이드 실험기계 안에서 작은 눈덩이의 규모가 우주까지 폭주하는 게임.

초반에는 어둑한 옛날 실험 아케이드 기계 안에서 작은 눈알갱이를 다루는 것처럼 보이고,
후반에는 그 낡은 장치가 감당할 수 없는 우주 현상을 억지로 처리하는 느낌까지 간다.

---

## 2. 핵심 키워드

사용:

- pixel
- chunky
- industrial
- arcade
- mechanical
- tactile
- rough
- readable
- escalating
- absurd
- dark retro arcade
- dim CRT machine
- low-resolution pixel texture

피함:

- 현대 모바일게임식 유리 UI
- 매끈한 SaaS 대시보드
- 지나치게 세련된 SF HUD
- 전체를 검정/빨강으로 칠한 액션게임 스타일
- 고해상도 캐릭터 일러스트 중심 UI
- 얇고 섬세한 벡터 선 중심 디자인
- 밝고 귀여운 캐주얼 퍼즐풍 또는 파스텔 중심 화면
- soft bloom을 넓게 깐 연기·마법형 이펙트
- 둥글고 매끈한 모바일 버튼 UI

---

## 3. 비주얼 구조

화면은 단순 16:9 플레이필드가 아니다.

```text
[ STAGE WORLD ] | [ CENTRAL PLAY FIELD ] | [ STAGE WORLD ]
```

중앙은 실제 물리 게임이 일어나는 세로형 실험통이다.

좌우는:

- 현재 스테이지의 세계
- 기계 프레임
- 계기판
- 장치
- 배경 연출

을 보여주는 공간이다.

따라서 Snowball Effect의 화면 인상은:

> “게임 화면 위에 HUD가 올라간 것”

보다

> “거대한 아케이드 기계의 중앙 실험 챔버를 들여다보는 것”

에 가깝다.

---

## 4. 레퍼런스의 사용 원칙

### Sandtrix / Sand Tetris 계열에서 참고

- 중앙의 어두운 물리 영역
- 주변의 두꺼운 프레임
- 장치/계기판 느낌
- 제한된 색과 투박한 픽셀 질감
- 플레이 영역과 주변 세계의 명확한 분리

복제하지 않음:

- 동일한 레이아웃
- 동일한 프레임 모양
- 동일한 UI 아이콘
- 동일한 색 조합

### Vampire Survivors에서 참고

- 후반의 포화감
- 작은 이벤트가 끊임없이 발생하는 리듬
- 숫자와 파티클이 성장감을 보조하는 방식
- 화면 전체가 “살아 있는” 느낌

복제하지 않음:

- 캐릭터/적 구조
- 무기 표현
- UI 구성
- 원본 에셋 스타일

### 짧은 전투 CUT-IN 계열에서 참고

- 현재 게임 화면을 잠깐 멈춤
- 배경을 어둡게 함
- 강한 패널이 빠르게 통과
- 중요한 이벤트만 강조

복제하지 않음:

- 캐릭터 일러스트
- 특정 게임의 배너/프레임/UI
- 현대적인 검정/빨강 액션 배너

---

## 5. 색과 재질

정확한 팔레트는 아트 제작 단계에서 정하지만, 기본 화면은 밝고 산뜻한 모바일 게임이 아니라 어두운 기계 내부처럼 눌린 톤을 유지한다. 공과 핵심 이벤트만 이 어둠 위에서 또렷하게 읽혀야 한다.

기본 배경과 기계 재질은 짙은 남청, 어두운 청록, 회청색, 검은 보라, 낡은 금속색을 우선한다. 강조색은 제한적으로만 사용한다.

- Snowball: 밝은 회백 또는 푸른 흰색
- 점수와 가독성 강조: 노랑
- 경고·강한 충돌·고조 순간: 주황에서 빨강
- UI 발광과 기계 계기: 청록 CRT 계열

기계 프레임:

- 베이지
- 아이보리
- 탁한 회색
- 철판색
- 오래된 플라스틱
- 작은 볼트와 패널 선

Play Field:

- 주변보다 어두움
- 공 실루엣이 잘 보이는 대비
- 완전한 순수 검정만 고집하지 않음

스테이지 배경:

- Ground도 밝은 모바일풍이 아니라 가장 절제된 남청·회청 기반의 어두운 초기 기계실로 시작
- Planetary부터 색온도와 스케일이 달라짐
- Galactic은 별/성운으로 밀도 증가
- Black Hole은 어두운 중심과 제한적인 강한 링 대비

후반이 화려해져도 화면 전체를 밝게 씻어내지 않는다. 모든 Stage는 레트로 픽셀 아케이드의 거친 재질과 낮은 해상도 감각을 유지한다.

---

## 6. 픽셀 규칙

- 공은 완벽한 벡터 원이 아니라 픽셀 실루엣을 가진다.
- 테두리는 작은 크기에서도 읽혀야 한다.
- 저레벨 공은 몇 픽셀 수준이어도 실제 게임 오브젝트임을 구분 가능해야 한다.
- UI와 기계 프레임도 같은 픽셀 계열을 사용한다.
- 고레벨 오브젝트는 해상도만 올리는 대신 내부 패턴, 링, 후광, 잔상으로 위계를 만든다.
- 픽셀 크기와 필터링이 씬마다 제각각 보이지 않게 일관성을 유지한다.
- 강한 glow는 고등급 순간을 읽히게 하는 짧은 보조 효과로만 사용하며, 픽셀 실루엣을 흐리게 만드는 soft bloom의 대체물이 되지 않는다.

---

## 7. 성장의 시각 언어

스케일 상승은 다음 축에서 동시에 나타난다.

1. 공의 이름과 개념
2. 기본 공의 생성량
3. 배경 세계의 규모
4. 파티클 밀도
5. 점수 자릿수
6. 사운드의 저역과 레이어
7. 화면 반응
8. 기계가 감당하기 힘들어지는 연출

후반에 단순히 “더 큰 원”만 그려서는 안 된다.

---

## 8. 최종 인상

플레이 시작:

> 침침한 픽셀 실험기계 안의 작은 눈알갱이 아케이드

플레이 중반:

> 뭔가 규모가 이상하게 커지고 있음

플레이 후반:

> 기계가 우주급 현상과 숫자를 감당하지 못하는 중

이 변화가 3분 안에 보여야 한다.

---

## FILE: DESIGN/01_SCREEN_COMPOSITION.md

# Snowball Effect — Screen Composition

## 1. 핵심 계약

**16:9 전체 화면을 플레이 영역으로 사용하지 않는다.**

실제 게임 플레이는 화면 중앙의 세로로 긴 `Play Field` 안에서만 일어난다.

```text
┌──────────────────────────────────────────────────────┐
│          │                              │            │
│ STAGE    │      CENTRAL PLAY FIELD      │   STAGE    │
│ WORLD    │                              │   WORLD    │
│          │  balls / merges / paddle     │            │
│          │                              │            │
└──────────────────────────────────────────────────────┘
```

좌우 공간은 단순 빈 여백이 아니라 **현재 Stage 세계와 아케이드 기계 본체**다.

전체 화면은 짙은 남청·청록·회청·검은 보라와 낡은 금속색을 기본으로 한 어두운 픽셀 기계 내부처럼 보인다. 중앙 Play Field는 주변보다 한 단계 더 눌린 톤으로 두고, Snowball·점수·경고·핵심 충돌만 제한적인 밝은 회백, 노랑, 주황~빨강, 청록 CRT 발광으로 읽힌다.

---

## 2. Play Field 역할

중앙에서만 발생:

- 기본 공 스폰
- 공 이동
- 벽 반사
- 머지
- 아이템 낙하
- 패들
- 바닥 점수 회수
- 블랙홀의 게임플레이 영향에 필요한 논리 좌표

Play Field 경계를 넘어 실제 공이 Stage World 영역을 돌아다니게 하지 않는다.

---

## 3. Stage World 역할

좌우/후방:

- 현재 세계 규모 전달
- 아케이드 기계 프레임
- 계기판
- 장치
- 단계별 환경 변화
- 장식 파티클
- 블랙홀 시각
- Cut-in이 지나갈 전체 화면 배경

Stage World는 게임 규칙을 가리는 장식이 아니라 Scale Shift를 읽게 만드는 핵심 구성이다.

---

## 4. 레이어 구조

권장 개념:

```text
Background Stage World
        ↓
Arcade Machine / Frame
        ↓
Central Play Field background
        ↓
Gameplay Balls / Paddle / Items
        ↓
Gameplay Effects
        ↓
HUD
        ↓
Global Dimmer
        ↓
CUT-IN / Scale Shift Presentation
```

CUT-IN 때는 현재 장면 전체가 freeze되고,
`Global Dimmer`가 중앙 Play Field와 좌우 Stage World를 **같이** 어둡게 한다.

---

## 5. 초기 구현값

기준 해상도:

```text
1600 × 900
```

중앙 Play Field의 정확한 폭은 아트와 플레이테스트로 결정한다.

초기 프로토타입에서는 대략 화면 폭의 40~50%를 중앙 Play Field로 사용해도 된다.
이 값은 **밸런스 확정값이 아니라 레이아웃 테스트용 값**이다.

중요한 것은:

- 좌우 Stage World가 충분히 보일 것
- 패들 조작 공간이 지나치게 답답하지 않을 것
- 낙하 공이 서로 합쳐질 공간이 확보될 것

이다.

---

## 6. 프레임

Play Field 주변은 두꺼운 픽셀 기계 프레임을 둔다.

후보 요소:

- 볼트
- 패널 이음새
- 작은 경고등
- 7-segment/CRT 계기판
- 단계 표시
- 최고 공 표시
- 점수 미터
- 과부하 표시등

모든 정보를 채우지 않는다.
장식 계기판과 실제 HUD를 구분한다.

프레임과 HUD는 깨끗한 flat panel이나 둥근 모바일 카드가 아니라 old terminal / CRT / arcade machine의 일부처럼 보인다. 작은 픽셀 테두리, 제한된 청록 계기 발광, 7-segment 또는 거친 레트로 숫자를 사용하되 HUD의 실제 정보 가독성을 희생하지 않는다.

---

## 7. HUD 위치

HUD는 중앙 Play Field를 최소한으로 침범한다.

추천:

좌상/우상 Stage World:

- SCORE
- TIME
- PAUSE

프레임 또는 외곽:

- 현재 활성 아이템
- 현재 Stage 공 족보
- 작은 장식 계기

HUD의 기본 정보 계약은 점수, 시간, 현재 아이템, 일시정지, 공 족보다. Stage 이름, 최고 공, Clear Target 같은 추가 정보가 필요하면 이 항목들의 가독성을 해치지 않는 보조 표시로만 검토한다.

공 족보는 현재 Stage의 local 공 5~6종을 작은 픽셀 아이콘으로 낮은 단계부터 높은 단계까지 한 줄 또는 한 열로 배열한다. 인접한 아이콘의 순서만으로 `같은 공 2개 → 다음 공` 관계가 읽혀야 하며, 예시 이미지처럼 별도의 `NEXT` Spawn 예고 영역은 두지 않는다. Play Field를 가리지 않도록 Stage World 또는 기계 프레임 공간에 배치한다.

중앙 위:

- 특별 발표 텍스트만 잠깐 사용

점수 팝업은 실제 공 위치 근처에서 발생하되 별도 UI/프레젠테이션 레이어에서 처리한다.

---

## 8. 가독성

실제 공:

- 명확한 외곽선
- 장식 눈보다 높은 대비
- Stage가 바뀌어도 배경에 묻히지 않음

Stage World:

- 멋있어도 중앙보다 시각적 우선순위가 낮음
- 강한 움직임은 중요 이벤트 때만
- 밝은 파스텔 배경이나 넓은 soft bloom으로 중앙 공의 대비를 빼앗지 않음

프레임:

- 게임의 개성을 주되 Play Field 내부를 침범하지 않음

---

## 9. Web Resize

16:9 기준으로 설계한다.

브라우저에서는:

- 전체 게임 화면 비율 유지
- 중앙 Play Field 비율 보존
- 좌우 Stage World가 잘려 게임 인상이 사라지지 않도록 함
- 작은 창에서도 입력 가능한 최소 크기 확인

단순히 중앙 Play Field만 확대해 좌우 디자인을 잘라내는 대응은 피한다.

---

## FILE: DESIGN/02_STAGE_ART_DIRECTION.md

# Snowball Effect — Stage Art Direction

## 전체 규칙

Stage 변화는 계절 변화가 아니라 **관측 스케일의 폭증**이다.

이전 최고 공이 다음 Stage의 기본 공이 되는 게임 규칙과
배경의 세계 규모가 같은 순간 재기준화되어야 한다.

---

# Stage 0 — Ground

## 목표 감정

> 작고 평화롭다.

초반이 소박해야 후반 뇌절이 강해진다.

## 배경

- 밝은 초원
- 언덕
- 작은 집
- 나무
- 가벼운 구름
- 단순한 픽셀 원경

## 기계 상태

- 정상
- 깨끗함
- 계기판도 여유로움
- 경고등 거의 없음

## 공

- Snowflake
- Snowball
- Big Snowball
- Giant Snowball
- Moon

눈송이는 몇 픽셀 수준의 작은 조각으로 시작한다.

---

# Stage 1 — Planetary

## 목표 감정

> 방금까지 거대했던 눈덩이가 이제 작은 천체처럼 취급된다.

## 배경

- 지구
- 달
- 인공위성
- 우주 구조물
- 대기권/별

## 기계 상태

- 일부 계기 수치 상승
- 패널에 새로운 경고등
- 더 큰 스케일을 측정하는 느낌

## 공

- Moon
- Earth
- Gas Giant
- Sun
- Supernova
- Galaxy

---

# Stage 2 — Galactic

## 목표 감정

> 화면이 본격적으로 감당하기 어려워진다.

## 배경

- 별무리
- 성운
- 은하
- 우주 먼지
- 느린 원경 움직임

## 기계 상태

- 과부하 경고
- 깜빡이는 계기
- 일부 화면 노이즈 또는 전기 스파크
- 프레임의 작은 떨림 가능

## 공

- Galaxy
- Galaxy Cluster
- Supercluster
- Quasar
- Event Horizon
- Black Hole

이 단계부터 파티클 포화가 눈에 띄게 증가한다.

---

## Galactic 최종 국면 — Black Hole 맵 기믹

## 목표 감정

> 기계가 정상 물리의 통제권을 잃었다.

## 배경

- 거대한 블랙홀
- 회전 링
- 별 왜곡
- 중력 렌즈 느낌
- 불안정한 공간

## 게임플레이

블랙홀은 Lv14 `Black Hole` Snowball과 별개인 맵 기믹이며, 단순 배경이 아니다.

- 좌우로 움직임
- 실제 공 궤도를 약하게 끌어당김
- 합체를 방해하기도 하고 몰아주기도 함

## 기계 상태

- 심한 과부하
- 계기 숫자 폭주
- 일부 라벨 오류/글리치
- 프레임이 우주 현상을 억지로 담고 있는 느낌

## 공

- Galaxy
- Galaxy Cluster
- Supercluster
- Quasar
- Event Horizon
- Black Hole

---

## 공의 크기 재정규화

Stage Shift 후 이전 최고 공이 다음 기본 공이 된다.

그러므로 화면상 공 크기를 그대로 유지하면 안 된다.

표현 의도:

> 공이 작아진 것이 아니라 카메라/관측 스케일이 더 멀리 줌아웃됐다.

따라서 Stage마다 `visual_radius_scale`을 별도로 적용할 수 있다.

게임 규칙의 `global_level`과 화면상 크기를 동일 개념으로 취급하지 않는다.

---

## 기계의 “붕괴”는 연출이다

후반 기계 과부하는 재미있는 프레젠테이션 요소다.

하지 말 것:

- HUD가 실제로 읽히지 않게 깨뜨림
- 입력 지연을 고장처럼 연출
- 공 식별을 방해하는 지속적 화면 글리치

기계가 망가지는 것처럼 보여도 게임은 정확히 작동해야 한다.

---

## FILE: DESIGN/03_GAMEPLAY_EFFECTS.md

# Snowball Effect — Gameplay Effects Hierarchy

## 1. 목표

일반 플레이의 감각은:

> Vampire Survivors처럼 계속 뭔가 터지고 숫자가 올라가지만,
> 실제 공과 중요한 이벤트는 끝까지 읽힌다.

파티클 “양”만 늘리는 것이 아니라 이벤트 위계를 설계한다.

모든 이벤트는 부드러운 현대 모바일 파티클보다 각진 픽셀 파편, 도트 조각, 사각형 스파크를 우선한다. 화려함은 허용하지만 재질감은 끝까지 레트로 픽셀 아케이드풍을 유지한다.

---

## 2. 레이어 위계

### Gameplay Balls

가장 명확해야 한다.

- 실루엣
- 외곽선
- 단계별 식별
- Fire 등의 특수 상태

### Decorative Particles

- 짧은 수명
- 낮은 불투명도
- 공보다 작은 시각적 우선순위
- 충돌/머지와 무관
- soft round particle보다 chunky pixel particle 우선
- 1px / 2px / 3px 크기의 사각형 파편을 혼합 가능
- 강한 blur의 연기형, 마법형, 반짝이형 질감은 피함

### Score Popups

- UI 레이어
- 공과 겹쳐도 충돌 오브젝트처럼 보이지 않음

### CUT-IN / SCALE SHIFT

- 최상위 프레젠테이션 레이어
- 플레이를 매우 짧게 정지시킬 수 있음

---

## 3. 이벤트 Tier

### Tier 0 — Low Merge

- 작은 각진 눈·얼음 도트
- 작은 플래시
- 짧은 소리
- 작은 숫자 또는 생략

화면 곳곳에서 자주 발생한다.

### Tier 1 — Mid Merge

- 더 많은 사각형 얼음 파편
- 얇고 각진 픽셀 링
- 작은 잔상
- 더 큰 숫자
- 아주 약한 카메라 반응

### Tier 2 — High Merge

- 더 큰 각진 픽셀 burst
- 짧은 flash와 제한적인 glow
- 큰 숫자
- 화면 흔들림
- 저역이 추가된 효과음

### Tier 3 — Major Ball / Record

- 짧은 히트스톱
- 강한 화면 반응
- CUT-IN 후보
- 특별 사운드
- 기록/이름 강조

### Tier 4 — Scale Shift

일반 머지가 아니다.

- 스테이지 재기준화
- 배경 세계 교체
- 생성량 변화
- 새 기본 공
- 전체 스케일 변화

일반 CUT-IN보다 강하고 길 수 있다.

### Cashout / Settlement 질감

- Cashout은 공이 하단으로 빠지거나 빨려 들어가며 작은 도트 스파크를 남긴다.
- 일반 Cashout은 큰 연기 구름이나 매끈한 마법 폭발보다 짧은 픽셀 파편과 점수 정보가 우선한다.
- 고등급 Cashout과 중요 이벤트는 burst의 크기·수·짧은 flash를 키울 수 있지만, blur를 늘려 재질을 바꾸지 않는다.

---

## 4. 포화 제어

후반에 낮은 이벤트가 너무 많이 발생하면:

- 저레벨 파티클 개수 자동 감소
- 같은 프레임의 작은 효과 합산
- 작은 점수 팝업 생략
- 동일 효과음 재생 수 제한
- 고레벨 효과의 시각 우선순위 확보

논리 공 수를 숨기기 위해 불투명한 파티클 벽을 만들지 않는다.

---

## 5. 실제 공 식별

실제 공은 항상:

- 파티클보다 선명
- 배경보다 높은 로컬 대비
- 단계별 핵심 형태 유지
- 이동 궤도 추적 가능

해야 한다.

후반의 “화면이 미친다”는 느낌과
“내가 뭘 조작하는지 모르겠다”는 상태는 다르다.

---

## 6. 사운드

낮은 머지:

- 가벼운 톡/얼음 소리

중간:

- 더 두꺼운 충격

높은:

- 저음 레이어
- 큰 충격
- 짧은 공간감

Scale Shift:

- 별도의 상승/전환 사운드

동일 사운드를 동시에 수십 개 재생하지 않는다.
우선순위와 동시 재생 제한을 둔다.

---

## 7. 성능

장식 효과가 프레임을 무너뜨리면 우선 줄인다.

우선순위:

1. 실제 공과 입력
2. 머지 판정
3. Stage 규칙
4. 고레벨 연출
5. 저레벨 장식 파티클

낮은 파티클을 지키기 위해 게임 규칙 성능을 희생하지 않는다.

---

## FILE: DESIGN/04_CUTIN_SYSTEM.md

# Snowball Effect — High-Grade CUT-IN System

## 1. 역할

CUT-IN은 일반 머지 파티클보다 한 단계 높은 **짧은 보상 연출**이다.

중요:

> 별도 화면으로 이동하지 않는다.

현재 플레이 중인 16:9 장면을 그대로 멈추고 어둡게 만든 뒤,
Snowball Effect의 픽셀 기계 패널이 빠르게 화면을 가로질러 지나간다.

CUT-IN의 주인공은 캐릭터가 아니라 **공 또는 특수 효과 자체**다.

---

## 2. 기본 동작

예: Galaxy Snowball 생성

1. 머지 판정 완료
2. 새 공 생성 완료
3. 게임 시뮬레이션 매우 짧게 freeze
4. 현재 Play Field + 좌우 Stage World 전체를 함께 dim
5. CUT-IN 패널이 화면 바깥에서 빠르게 진입
6. 중앙을 가로지르며 짧게 체류
7. 공 이름 / 공 이미지 / 가치 표시
8. 반대쪽으로 빠르게 퇴장
9. dim 해제
10. 즉시 시뮬레이션 재개

CUT-IN 중 게임 상태를 되돌리거나 머지를 지연시키지 않는다.
게임 이벤트는 이미 확정된 후 프레젠테이션만 잠깐 멈춘다.

---

## 3. 시간

초기 테스트:

```text
enter   0.10 ~ 0.15 s
hold    0.20 ~ 0.30 s
exit    0.10 ~ 0.15 s
----------------------
total   0.45 ~ 0.70 s
```

일반 CUT-IN은 기본적으로 1초를 넘기지 않는다.

원칙:

> 강하게 보여주고 빨리 사라져라.

SCALE SHIFT는 별도 시스템이며 0.8~1.0초까지 허용 가능하다.

---

## 4. 디자인

사용:

- 픽셀 테두리
- 기계식 패널
- 베이지/회색/금속 프레임
- 볼트
- 거친 픽셀 질감
- 레트로 숫자
- 현재 공의 픽셀 스프라이트
- 해당 속성 파티클

피함:

- 현대적인 검정/빨강 액션 배너
- 고해상도 캐릭터 일러스트
- 모바일 게임 카드 UI
- 긴 설명문

개념:

```text
╔══════════════════════════════════════╗
║ GALAXY SNOWBALL                     ║
║                                      ║
║        [ PIXEL BALL SPRITE ]         ║
║                              500Qi   ║
╚══════════════════════════════════════╝
```

실제 패널은 정적 중앙 박스가 아니라 수평/사선으로 통과한다.

---

## 5. 정보 우선순위

공 CUT-IN:

1. 이름
2. 공 이미지
3. VALUE / SCORE

예:

```text
GALAXY SNOWBALL
[ sprite ]
VALUE 500Qi
```

아이템/특수 상태:

1. 효과 이름
2. 적용된 공/효과 이미지
3. 핵심 효과 한 줄

예:

```text
FIRE SNOWBALL
[ burning pixel snowball ]
CASHOUT ×10
```

Magnet:

```text
MAGNETIZED
[ magnetic field ]
MERGE ATTRACTION
```

---

## 6. 언제 보여주는가

모든 머지에 사용하지 않는다.

CUT-IN 후보:

- 해당 Stage에서 처음 만든 중요한 고등급 공
- 매우 높은 Tier 머지
- 기록 갱신급 공
- 특별한 아이템/속성이 처음 강하게 적용된 순간
- 게임적으로 큰 상태 변화

일반 머지는 즉시 파티클로 끝낸다.

---

## 7. 남발 방지

필요 상태:

```text
cutin_cooldown
shown_ball_levels
shown_special_events
pending_priority_event
```

규칙:

- 연속 머지가 발생해도 CUT-IN을 큐로 끝없이 쌓지 않는다.
- 낮은 우선순위 이벤트는 버릴 수 있다.
- 높은 우선순위 이벤트가 기존 낮은 이벤트를 대체할 수 있다.
- 일반 CUT-IN 직후 Scale Shift가 발생하면 Scale Shift를 우선한다.
- 동일 공의 첫 발견 CUT-IN은 한 판에 한 번을 기본으로 한다.

---

## 8. SCALE SHIFT와의 차이

### 일반 CUT-IN

- 현재 Stage 유지
- 0.45~0.7초
- 공/아이템 강조
- 플레이 즉시 재개

### SCALE SHIFT

- Stage 자체 변경
- 이전 최고 공 → 다음 기본 공
- 배경 교체
- 생성량 증가
- visual scale 재정규화
- 더 강한 프레젠테이션
- 약 0.8~1.0초 허용

둘을 같은 이벤트로 구현하지 않는다.

---

## 9. 기술 책임

추천:

`PresentationManager`

- 글로벌 dim
- simulation presentation pause 요청
- 우선순위 관리
- CUT-IN cooldown
- Scale Shift와 충돌 조정

`CutInController`

- 패널 enter / hold / exit
- 텍스트와 스프라이트 바인딩
- 이벤트별 테마
- 완료 신호

`EffectManager`

- 일반 머지/회수 파티클
- CUT-IN 여부를 자체 결정하지 않음

`StageManager`

- Scale Shift 발생 여부 결정
- CUT-IN과 별개로 Stage 전환 이벤트 발행

---

## 10. 검증

- CUT-IN 중 실제 시뮬레이션이 움직이지 않음
- 현재 화면 전체가 같이 어두워짐
- 별도 화면으로 전환되지 않음
- 총 길이가 목표 범위
- 연속 이벤트에서 CUT-IN 폭주 없음
- 종료 후 입력 상태가 꼬이지 않음
- Scale Shift와 동시 발생 시 Scale Shift가 우선
- 웹에서 Tween/animation이 정상

---

## FILE: 03_TECHNICAL_DESIGN.md

# Snowball Effect — Technical Design

## 1. 기술 목표

- Godot 4.x Stable
- 브라우저 Web Export
- 1600×900 기준, 비율 유지
- 데스크톱 브라우저 60 FPS 목표
- 최소 성능 목표: 30 FPS 이상
- 논리 공 1,000개 이상 스트레스 테스트
- 장식 파티클은 논리 공과 분리
- 긴 프레임 스파이크를 최소화

---

## 2. 핵심 결정

### 사용

- 중앙 `BallSimulationManager`
- 구조화된 배열 기반 공 데이터
- Uniform Grid / Spatial Hash
- 비활성 인덱스 재사용
- 단일 또는 소수 렌더러
- GPUParticles2D는 장식
- 데이터 중심 Stage/Ball/Item 정의
- 수동 원형 충돌과 반사

### 사용하지 않음

- 공마다 `RigidBody2D`
- 공마다 개별 `_physics_process`
- 모든 공 쌍 전수 비교
- 게임 규칙을 GPU 파티클에 위임
- 프레임마다 공 객체 생성·삭제
- 실제 질량·마찰·회전 물리

---

## 3. 전체 아키텍처

```text
GameManager
 ├─ 입력/게임 상태 조율
 ├─ 전체 누적 점수/결과
 ├─ Run 종료
 └─ 시스템 신호 연결

StageManager
 ├─ 현재 Stage
 ├─ Stage timer / base_time
 ├─ Stage score / clear_score
 ├─ 기본/최고 global_level
 ├─ 생성량
 ├─ Top Ball Clear
 ├─ Time Up / Final Settlement / Score Clear
 ├─ Scale Shift
 └─ 블랙홀 설정

BallSimulationManager
 ├─ 공 데이터 저장
 ├─ 이동 적분
 ├─ 벽/패들/점수 구역 판정
 ├─ 공간 그리드 재구축
 ├─ 합체 후보 탐색
 ├─ 합체 실행
 └─ 블랙홀/아이템 힘 적용

BallRenderer
 ├─ 저레벨 일괄 렌더
 ├─ 고레벨 시각 표현
 └─ 레벨/특수 타입별 외형

Paddle
 ├─ 입력
 ├─ 위치/회전
 └─ 반사 계산용 데이터 노출

ItemManager
 ├─ 아이템 생성
 ├─ Ball 충돌·내구도 기반 획득 판정
 └─ 활성 효과/지속시간

EffectManager
 ├─ 파티클
 ├─ 점수 팝업
 ├─ 카메라 흔들림
 ├─ 히트스톱
 └─ 발표 UI

BackgroundManager
 ├─ 스테이지 배경
 └─ 블랙홀 시각/위치

AudioManager
 ├─ 합체음
 ├─ 회수음
 ├─ 아이템음
 └─ 스테이지 전환음
```

---


## 3.1 전체 화면과 논리 Play Field 분리

`Viewport` 전체와 공 시뮬레이션 Rect를 동일하게 취급하지 않는다.

```text
Viewport 1600×900
 ├─ Stage World / Machine Frame
 └─ PlayFieldRect
      ├─ balls
      ├─ paddle
      ├─ items
      └─ score zone
```

`BallSimulationManager`는 명시적인 `Rect2 play_field_rect`를 사용한다.

벽 반사, 스폰 X 범위, 패들 이동 제한, 점수 구역은 모두 이 Rect 기준이다.

Stage World 배경과 기계 프레임은 논리 충돌 범위를 넓히지 않는다.

---

## 3.2 Presentation 계층

추가 책임:

```text
PresentationManager
 ├─ global dim
 ├─ short simulation presentation pause
 ├─ event priority
 ├─ CUT-IN cooldown
 └─ Scale Shift presentation coordination

CutInController
 ├─ enter / hold / exit animation
 ├─ title / sprite / value binding
 └─ completion signal
```

일반 파티클은 `EffectManager`가 담당한다.

`EffectManager`가 스스로 게임을 멈추거나 Stage를 바꾸지 않는다.

`StageManager`는 Scale Shift의 게임 상태 변경을 결정하고,
Presentation 계층은 이를 화면에 표현한다.


## 4. 공 데이터

Godot의 PackedArray는 구조체 배열을 직접 제공하지 않으므로, MVP에서는 SoA(Structure of Arrays) 형태를 권장한다.

```gdscript
var positions: PackedVector2Array
var velocities: PackedVector2Array
var radii: PackedFloat32Array
var global_levels: PackedInt32Array
var score_values: PackedFloat64Array
var active_flags: PackedByteArray
var special_types: PackedByteArray
var merge_locks: PackedByteArray
```

보조 인덱스:

```gdscript
var active_indices: Array[int]
var free_indices: Array[int]
var indices_by_level: Dictionary
```

### 특수 타입 예시

```gdscript
enum BallSpecial {
    NORMAL,
    FIRE
}
```

### 공 슬롯 생성

1. `free_indices`가 있으면 재사용
2. 없으면 모든 배열 뒤에 슬롯 추가
3. 값을 초기화
4. 활성 인덱스에 추가

### 공 제거

- `active_flags[index] = 0`
- `free_indices.push_back(index)`
- 활성 인덱스는 swap-remove 또는 다음 정리 주기에 압축

매 제거마다 큰 배열 전체를 재구성하지 않는다.

---

## 4.1 Arcade velocity 계약

기본 공 적분에는 지속적인 아래 방향 acceleration을 더하지 않는다.

```text
default gravity = 0
position += velocity * delta
```

Spawn은 아래쪽 반구 안의 방향과 공통 Spawn speed tuning을 결합해 초기 velocity를 만든다. 각도 범위, 분포, 초기 speed의 최소·최대값은 플레이테스트 대상이다.

현재 Lv1의 physical/design reference는 일반적인 눈송이 낙하속도 약 `1.0 m/s`다. 이는 현실의 움직임 인상을 위한 reference이며 Godot world unit과 직접 변환하지 않는다. 공간은 `1 world unit = 1 logical pixel`, 시간은 second, runtime velocity는 world units/s로 관리한다. `GameManager`의 `lv1_spawn_speed_world_units_per_second`는 한 곳에서 조정하는 게임-space tuning 값이고, 현재 첫 플레이테스트 값은 `160 world units/s`다. 현재 구현 전 component range `x = -50~50`, `y = 40~100 world units/s`의 speed magnitude는 약 `40~112 world units/s`였으므로 새 Lv1 Spawn은 이를 낮추지 않는다.

Lv1 radius는 visual과 collision이 같은 `4 world units`(diameter 8)를 사용한다. 이는 현재 Shared Skeleton의 승인된 기본 크기다. `160 world units/s` Spawn speed와 Paddle max speed cap은 별도 플레이테스트 tuning으로 유지한다.

`base_speed` 또는 Spawn speed는 초기 velocity의 기준이다. runtime velocity를 매 tick 해당 값으로 정규화하거나 덮어쓰지 않는다. Paddle, 명시적인 벽 규칙, Merge, Stage effect, Item, 특수 상태는 runtime direction과 speed를 바꿀 수 있다.

현재 버전은 `global_level`별 base speed 차이를 사용하지 않는다. 향후 `BallDefinition`에 등급별 base speed를 도입할 수 있지만, 그 값도 Spawn 기준이며 runtime speed 고정값이 아니다.

---

## 5. 시뮬레이션 순서

권장 `_physics_process(delta)` 순서:

1. 게임 상태 확인
2. 명시적으로 활성화된 스테이지/아이템 전역 힘 계산 — 기본 공에는 지속 중력 없음
3. 공 이동 적분
4. 좌·우·상단 반사 경계 처리
5. 패들 후보 공 판정 및 반사
6. 점수 구역 처리
7. 공간 그리드 재구축
8. 같은 레벨 합체 후보 검사
9. 합체 명령 큐 실행
10. 활성 인덱스 정리
11. 렌더러에 최신 데이터 전달
12. 디버그 지표 갱신

합체 탐색 중 배열을 즉시 크게 변경하지 않는다.  
합체 요청을 큐에 모은 뒤 검사 종료 후 적용한다.

하단에는 반사 벽을 만들지 않는다. 아래 방향으로 열린 경계를 통과한 공만 Active Cashout command에 넣는다.

---

## 6. 공간 그리드

### 목적

공 N개를 모든 쌍으로 비교하면 O(N²)이다.  
화면을 고정 크기 셀로 나누어 주변 후보만 검사한다.

### 자료구조

플레이 영역이 고정이므로 Dictionary 기반 해시보다 1차원 배열 그리드가 더 단순할 수 있다.

```text
cell_x = floor(position.x / cell_size)
cell_y = floor(position.y / cell_size)
cell_index = cell_y * columns + cell_x
```

각 셀은 공 인덱스 목록을 가진다.

### 레벨 분리

같은 레벨끼리만 합체하므로 다음 중 하나를 사용한다.

```text
grid[cell][level] -> indices
```

또는

```text
grids_by_level[level][cell] -> indices
```

실제 구현은 메모리 할당을 줄이는 형태를 선택한다.

### 셀 크기

- 현재 스테이지 기본~중간 공의 지름 기준
- 지나치게 작으면 셀 수와 등록 비용 증가
- 지나치게 크면 후보 수 증가

고레벨 공은 개수가 적으므로 더 넓은 이웃 범위를 검사하거나 별도 목록으로 처리 가능하다.

### 중복 쌍 방지

- `b_index > a_index` 조건
- 각 공은 한 프레임에 한 번만 합체
- `merge_locks`로 예약

---

## 7. 패들 충돌

### 조작 입력

Mouse 입력은 Viewport의 raw pixel을 world X로 그대로 사용하지 않는다. 가장 최근 Mouse position을 Canvas/world 좌표로 변환한 뒤 Play Field 기준 logical X를 구하고, physics tick 시작 시 현재 Paddle center X에 직접 반영한 다음 회전된 Paddle extent를 고려해 field clamp한다. Mouse target 추적 speed cap은 폐기한다.

Paddle simulation은 매 physics tick에 다음 두 transform을 가진다.

```text
previous_transform = 직전 physics tick에서 확정된 Paddle transform
current_transform  = 이번 tick의 Mouse/Keyboard/rotation 입력을 적용해 확정한 transform
```

Mouse는 `current_transform.position.x`를 직접 정한다. Keyboard fallback은 기존 속도 적분으로 current transform을 정해도 된다. 이후 collision system은 입력 source가 아니라 동일한 previous/current transform만 소비한다.

Paddle 중심 선형속도는 `(current_position - previous_position) / physics_delta`로 계산한다. 각속도는 이번 tick에 실제 적용된 signed angle displacement를 `physics_delta`로 나눈다. angle을 `-PI..PI` 등가 범위로 정규화하더라도 ±PI 경계를 넘은 정규화 결과만 빼서 각속도를 계산하지 않는다. 정규화 전 signed displacement 또는 동등한 unwrapped angle을 사용한다.

Mouse Wheel은 tuning 가능한 `mouse_wheel_step_degrees`만큼 기존 Paddle angle state를 변경한다. `←/→`도 같은 angle state를 변경하며 angle min/max clamp는 두지 않는다. 구현은 표현상 동일한 범위로 angle을 정규화할 수 있지만 연속 회전 입력을 멈추지 않는다. `A/D`와 `←/→` 키보드 조작은 A/B 비교용 fallback으로 유지한다. 별도의 마우스 반사 경로나 별도의 rotation state를 만들지 않는다.

공이 수천 개일 수 있으므로 모든 공에 Node/PhysicsBody를 만들지 않고 중앙 `BallSimulationManager` 배열에서 Paddle 하나와 각 활성 공의 후보를 검사한다. Paddle 대 공 검사는 O(N)이며 공 쌍 O(N²) 구조를 만들지 않는다.

### Broad Phase

- previous/current Paddle transform 사이의 보수적인 swept bound를 만든다.
- 공의 이번 tick trajectory가 ball radius만큼 확장한 swept bound와 겹치는 경우만 narrow phase 후보로 둔다.

### Narrow Phase

패들은 양면 회전 OBB다. 권장 최소 continuous collision 방식은 **translation relative sweep + rotation adaptive substep**의 혼합이다.

1. 공의 tick 시작 위치와 velocity로 ball trajectory를 만든다.
2. Paddle previous/current transform을 준비한다.
3. Paddle 회전량을 signed/unwrapped angle로 보간한다. 회전 substep 수는 Paddle 끝점의 회전 이동량이 collision tolerance를 넘지 않도록 정한다.
4. 각 회전 구간 안에서는 Paddle translation과 ball trajectory의 상대운동을 연속 sweep으로 계산한다. circle을 ball radius만큼 확장한 OBB에 대한 segment/TOI query와 동등한 방법을 사용한다.
5. 모든 구간에서 가장 이른 유효 TOI를 선택하고 그 시점의 interpolated Paddle transform, contact point, 양면 outward normal을 사용한다.
6. 시작/끝 overlap과 Paddle 내부에서 시작한 공도 fallback contact로 처리해 penetration 상태를 탈출시킨다.
7. TOI까지 이동한 뒤 반사하고 남은 tick 시간을 새 velocity로 진행한다.

translation 거리를 작은 고정 step으로만 나누는 방식은 Mouse 직접 매핑 시 지나치게 많은 substep을 요구하므로 기본안으로 사용하지 않는다. 반대로 current-frame OBB overlap만 사용하는 방식도 작은 Lv1 공에서 translation/rotation tunneling을 놓치므로 폐기한다. 회전만 adaptive substep하고 각 구간의 translation은 sweep으로 처리하면 현재 해커톤 규모에서 정확도와 Web 비용을 함께 통제할 수 있다.

같은 Paddle sweep에서 한 공의 가장 이른 접촉을 한 번만 commit한다. 반사 후 contact normal 방향으로 separation epsilon을 적용하고, 공이 해당 면에서 분리되기 전에는 같은 접촉을 다시 반사하지 않는다. 이는 양면에 동일하게 적용한다.

### 회전 접촉점 속도

TOI 시점의 Paddle center에서 contact point까지의 world-space 벡터를 `r`이라 하고, signed angular velocity를 `omega`라 한다.

```text
linear_velocity = (current_center - previous_center) / physics_delta
angular_velocity = signed_angle_displacement / physics_delta
angular_contact_velocity = omega * Vector2(-r.y, r.x)
raw_contact_velocity = linear_velocity + angular_contact_velocity
impact_velocity = clamp_length(raw_contact_velocity, maximum_impact_velocity)
```

Godot 2D의 회전 부호와 화면 좌표계에 맞춰 동일한 cross-product 결과를 사용한다. Paddle 끝은 중심보다 `|r|`가 크므로 같은 angular velocity에서도 더 큰 표면속도를 갖고, 회전 방향이 바뀌면 angular contribution 방향도 바뀐다. Wheel event delta 자체를 impact로 사용하지 않고 physics tick에 실제 적용된 angle displacement로만 계산한다.

impact cap은 linear/angular contribution을 각각 자른 뒤 더하는 방식이 아니라 **합산한 raw contact velocity에 한 번** 적용한다. 이후 순서는 다음과 같다.

1. capped `impact_velocity`로 ball relative velocity 계산
2. TOI contact normal을 향해 접근 중인지 판정
3. relative velocity 반사
4. capped impact velocity와 contact-position shaping을 기존 반사 계약에 따라 반영
5. 마지막에 ball runtime speed cap 적용

어떤 반사 항에서도 uncapped linear/angular velocity를 다시 더하지 않는다. Mouse 직접 위치 반영으로 center velocity가 커져도 impact와 최종 ball speed는 별도 tuning으로 제한된다. `base_speed`로 되돌리지는 않는다.

---

## 8. 공 합체

### 판정

```gdscript
var min_distance := radii[a] + radii[b]
if positions[a].distance_squared_to(positions[b]) <= min_distance * min_distance:
    request_merge(a, b)
```

### 속도

Merge 결과 velocity는 아직 확정하지 않는다. 두 입력 speed의 평균/최대/별도 계산, 새 등급의 base speed 사용 여부, 방향 결정과 cap을 S2 Merge velocity 계약에서 함께 정한 뒤 구현한다.

### 연쇄 합체

새로 생성된 공은 같은 프레임에 다시 합체시키지 않는다.  
다음 물리 프레임부터 합체 가능하게 하여 중복과 무한 연쇄를 피한다.

화면상 연쇄감은 파티클과 짧은 간격으로 충분히 느껴진다.

---

## 9. 점수 표현

MVP에서는 `float`/64비트 실수로 점수를 관리한다.

필요 기능:

```gdscript
func format_score(value: float) -> String
```

- 1,000 미만: 정수
- 이후 3자리 단위 접미사
- 접미사 범위 초과 시 과학적 표기
- 소수점 0~2자리
- NaN/Infinity 방어

점수는 데이터 정의에서 읽는다.  
합체 과정의 보존 법칙을 계산하지 않는다.

---

## 10. 렌더링 전략

### 10.1 MVP

하나의 `Node2D`가 `_draw()`로 활성 공을 그린다.

- 저레벨: 원 또는 작은 텍스처
- 높은 레벨: 색상, 외곽선, 내부 무늬를 레벨 데이터로 구분
- 매 프레임 `queue_redraw()`

이 방식으로 성능을 먼저 측정한다.

### 10.2 최적화 후보

병목이 확인될 때만 다음으로 내린다.

- `MultiMeshInstance2D`
- `RenderingServer.canvas_item_add_circle` 계열 저수준 호출
- 레벨별 별도 일괄 버퍼
- 화면 밖 렌더 생략

추측으로 처음부터 복잡한 렌더 구조를 만들지 않는다.

### 10.3 고레벨 표현

고레벨 공은 크기만 무한히 키우지 않는다.

- 후광
- 회전 내부 텍스처
- 꼬리
- 외곽 링
- 화면 왜곡
- 색 대비

로 위계를 만든다.

스테이지마다 StageDefinition의 `visual_radius_scale`로 화면상 기본 반지름을 재정규화한다. BallDefinition의 `radius`는 전역 물리·충돌 크기이며 이 보정으로 변경하지 않는다.

---

## 11. 이펙트 예산

장식 파티클은 논리 객체가 아니다.

### 이벤트 등급

| 등급 | 예 |
|---|---|
| 0 | 기본 공 합체 |
| 1 | 중간 공 합체 |
| 2 | 스테이지 상위 공 합체 |
| 3 | 최고 공 생성 / 고레벨 회수 |
| 4 | Scale Shift |

낮은 등급 이벤트가 한 프레임에 너무 많이 발생하면:

- 파티클 수 축소
- 사운드 통합
- 팝업 생략
- 같은 위치 이벤트 합산

높은 등급은 반드시 보이게 한다.

### 히트스톱

전체 트리를 매번 멈추지 말고, `GameManager` 또는 시뮬레이션 시간 스케일을 짧게 제어한다.

- 중간: 사용하지 않음 또는 0.02초
- 높은 합체: 0.05초
- Scale Shift: 0.1~0.2초

연속 이벤트가 시간을 과도하게 멈추지 않도록 쿨다운 또는 최대 누적을 둔다.

---


## 11.1 CUT-IN 기술 규칙

CUT-IN은 별도 게임 씬 전환이 아니다.

현재 장면 위의 최상단 CanvasLayer에서 처리한다.

권장 순서:

```text
game event committed
→ request_cut_in(event)
→ presentation priority check
→ simulation presentation pause
→ dim overlay fade
→ panel enter
→ hold
→ panel exit
→ dim restore
→ simulation resume
```

중요:

- 실제 게임 이벤트는 CUT-IN 시작 전에 이미 확정
- CUT-IN 애니메이션 실패가 게임 상태를 되돌리지 않음
- 연속 이벤트를 무한 큐잉하지 않음
- Scale Shift가 일반 CUT-IN보다 높은 우선순위
- 입력 눌림 상태가 pause/resume 후 꼬이지 않는지 검증
- Tween/AnimationPlayer는 Web Export에서 검증

시간 목표:

```text
normal cut-in: 0.45~0.70s
scale shift: up to about 0.8~1.0s
```


## 12. 아이템 기술

아이템 행성 수는 적으므로 개별 `Area2D` 또는 단순 Node2D 사용 가능하다. 논리 공 배열에 섞지 않는다.

### 획득

- Item Ball과 logical Snowball의 원 충돌 후보를 중앙 simulation 위치 snapshot으로 검사
- `local_level = ball.global_level - current_stage.base_global_level`로 계산
- `local_level >= 2`인 접촉만 유효 damage; 더 높은 단계도 같은 규칙으로 damage 가능
- 한 contact pair는 분리되기 전까지 damage 한 번만 commit
- 유효 hit마다 damage count를 올리고 Presentation에 균열 단계 이벤트 전달
- `required_break_hits` 도달 시 broken/acquired lock과 pending activation을 한 번만 확정
- CUT-IN activation cue에서 ItemManager가 효과를 시작하며, cue가 실패하거나 skip되면 안전한 fallback으로 한 번 적용
- Item Ball 제거 또는 풀 반환은 논리 획득 확정 뒤 수행
- 획득·재획득·만료·Retry 때 read-only active item snapshot을 HUD에 전달

### Blizzard

`StageManager.current_spawn_rate * multiplier`

### Magnet

공간 그리드에서 같은 레벨 이웃 한두 개만 선택해 약한 힘 적용.  
모든 동일 레벨 쌍에 힘을 계산하지 않는다.

### Fire

공의 `special_type` 플래그 변경.  
렌더러와 점수 계산이 이 플래그를 참조한다.

---

## 13. 블랙홀 기술

BackgroundManager가 시각 블랙홀과 논리 위치를 제공한다.

이 블랙홀은 마지막 Galactic Stage에서만 활성화하는 맵 기믹이며, Lv14 `Black Hole` BallDefinition과 별개의 런타임 요소다.

```gdscript
func get_black_hole_position() -> Vector2
func get_black_hole_pull(position: Vector2) -> Vector2
```

논리 인력은 BallSimulationManager에서 적용한다.  
배경 셰이더와 논리 좌표가 크게 어긋나지 않아야 한다.

성능상 공마다 `sqrt`를 줄이고 싶다면 거리 제곱 기반 완만한 함수 사용 가능하다.  
다만 조작감이 우선이며 실제 측정 후 최적화한다.

---

## 14. 데이터 정의

권장 Resource:

```text
BallDefinition
- global_level
- display_name
- score_value
- color
- texture
- fx_tier
- base_speed_override (future/optional; current version does not use per-level differences)

StageDefinition
- stage_index
- display_name
- base_global_level
- top_global_level
- local_ball_levels (Stage별 5~6종; 이전 Stage top과 다음 Stage base 중복 허용)
- base_time
- clear_score
- time_bonus_by_local_level
- spawn_rate
- visual_radius_scale (현재 Stage의 화면상 공 크기 보정; BallDefinition의 물리 radius는 변경하지 않음)
- background_id
- global_force_scale (explicit Stage effect only; not default downward gravity)
- black_hole_enabled

ItemDefinition
- item_type
- spawn_weight
- duration
- magnitude
- required_break_hits
```

초기에는 `.tres` 또는 GDScript Resource를 사용한다.  
밸런스 값이 여러 코드에 중복되지 않게 한다.

초기 BallCatalog는 중복을 제외한 global 공 15종을 목표로 한다. 15는 밸런스 공식이 아니라 첫 콘텐츠 제작 범위이며, 플레이테스트 결과에 따라 데이터 수를 줄일 수 있다. Stage별 5~6종의 테마 구성과 global catalog의 연결은 `StageDefinition`에서 관리한다.

HUD 공 족보는 현재 `StageDefinition.local_ball_levels` 순서대로 `BallCatalog`의 visual key와 display name을 읽어 표시한다. 별도의 Merge progression 사본이나 `NEXT` Spawn queue를 만들지 않는다. `stage_changed(stage_definition)`을 받을 때 목록을 한 번 갱신하고, HUD가 Merge 결과나 Stage 데이터를 수정하지 않는다.

현재 S1의 Lv1 Spawn speed와 runtime speed cap은 공통 physics tuning이다. Mouse position은 직접 매핑하므로 movement speed cap을 사용하지 않는다. Paddle contact impact cap, ball reflection speed cap, rotation collision tolerance와 최대 rotation substep 수는 서로 다른 tuning이며 확정 디자인값이 아니다. 향후 BallDefinition override를 추가하더라도 runtime velocity를 지속적으로 고정하는 용도로 사용하지 않는다.

---

## 15. 신호

권장 신호:

```gdscript
signal cashout_completed(score_amount: float, time_bonus: float, world_position: Vector2, ball_level: int)
signal ball_merged(result_level: int, world_position: Vector2)
signal highest_level_changed(new_level: int)
signal stage_timer_changed(time_left: float)
signal stage_time_up(stage: int)
signal final_settlement_started(stage: int)
signal final_settlement_completed(stage: int, final_stage_score: float)
signal stage_clear_decided(stage: int, reason: StringName)
signal stage_clear_completed(stage: int, reason: StringName)
signal stage_failed(stage: int)
signal stage_shift_started(from_stage: int, to_stage: int)
signal stage_shift_completed(stage: int)
signal item_planet_damaged(item_type: int, current_hits: int, required_hits: int, world_position: Vector2)
signal item_planet_broken(item_type: int, world_position: Vector2)
signal item_collected(item_type: int)
signal active_items_changed(items: Array)
signal resume_requested()
signal settings_requested()
signal main_menu_requested()
signal game_finished(result: Dictionary)
```

EffectManager와 UI는 이 신호를 구독한다.  
시뮬레이션 코드가 UI 노드를 직접 찾아 수정하지 않는다.

---

## 16. 디버그 HUD

개발 빌드에서 토글 가능한 HUD:

- FPS
- 물리 프레임 시간
- 활성 공 수
- 최대 활성 공 수
- 생성량/초
- 합체/초
- 충돌 후보 검사 수
- 실제 합체 수
- 현재 스테이지
- 현재 기본 global_level
- 장식 파티클 수 또는 emitter 상태

웹 빌드 성능을 반드시 측정한다.

---

## 17. 성능 게이트

### Phase 1

- 100개 공
- 60 FPS 목표

### Phase 3

- 1,000개 논리 공
- 30 FPS 이상
- 전수 비교 없음
- 프레임 스파이크가 반복되지 않음

### 후반 연출

- 논리 공 + 파티클 + 배경을 함께 켠 웹 빌드에서 플레이 가능
- 성능이 떨어지면 먼저 장식 파티클과 팝업을 줄임
- 게임 규칙을 임의로 제거하지 않음

---

## 18. 웹 Export 주의

- 브라우저 콘솔 오류 확인
- 오디오 자동재생 제한 대응: 첫 입력 후 오디오 시작
- 캔버스 리사이즈와 비율 유지
- 입력 포커스 확인
- 지나치게 큰 초기 에셋 방지
- 스레드가 필요한 기능에 의존하지 않음
- 정적 호스팅에서 상대 경로 검증
- itch.io 또는 Cloudflare Pages 배포를 고려

---

## 19. 테스트 가능성

순수 계산은 가능한 한 함수로 분리한다.

예:

```gdscript
calculate_paddle_reflection(...)
format_score(...)
calculate_black_hole_pull(...)
get_merge_result(...)
```

Godot 테스트 프레임워크를 강제하지 않더라도 디버그 씬 또는 자동 검증 함수로 확인 가능하게 한다.


---

## Stage Timer / Cashout / Settlement 기술 규칙

### Stage clock

한 개의 전역 180초 타이머를 사용하지 않는다.

`StageManager`가 현재 Stage의 남은 시간을 관리한다.

```text
stage_time_left = stage_definition.base_time
```

Stage 진입:

```text
stage_score = 0
stage_time_left = stage_definition.base_time
```

활성 플레이 중 Cashout 발생:

```text
cashout_score = calculate_cashout_score(ball)
effective_time_bonus = get_local_time_bonus(current_stage, ball.global_level)
stage_score += cashout_score
run_score += cashout_score
stage_time_left += effective_time_bonus
```

`time_bonus_by_local_level[0]`은 0으로 시작한다.
시간 보너스는 점수나 Active Cashout 전용 modifier와 별도로 계산한다.
Stage 종료 시 `run_score`에 `stage_score`를 다시 더하지 않는다.

초기 구현에는 Stage 시간 상한을 넣지 않는다.
실제 Stage 플레이 시간, Cashout 총 획득 시간, 초당 평균 획득 시간,
local level별 Cashout 수를 측정하고 인플레가 확인될 때만 상한을 검토한다.

### Physics tick ordering

Stage 종료 판정은 다음 순서를 따른다.

```text
1. stage_time_left -= delta
2. 이동 / 충돌 / Merge 처리
3. Merge 확정 및 Top Ball 여부 기록
4. Active Cashout 점수와 Time Bonus 반영
5. 종료 판정
   - Top Ball 생성 → TOP_BALL_CLEAR
   - 아니고 stage_time_left <= 0 → TIME_UP
   - 그 외 → PLAYING 유지
```

같은 tick의 Cashout으로 시간이 다시 양수가 되면 Time Up을 취소한다.
같은 tick에 Top Ball과 Time Up 조건이 모두 있으면 Top Ball Clear가 우선한다.

### Top Ball Clear

현재 Stage `top_global_level` 공이 생성되면:

1. Stage 성공 상태 잠금
2. 추가 Stage 타이머 감소 정지
3. 일반 CUT-IN보다 Stage Clear 우선
4. `stage_clear_decided(reason = TOP_BALL)` 확정
5. Final Settlement 실행
6. `stage_clear_completed` 후 다음 Stage면 Scale Shift

### Time Up

tick의 Cashout 반영 후에도 시간이 0 이하이면:

1. 새 공 Spawn 정지
2. 플레이 입력/물리 진행 정지 또는 짧게 감속
3. Final Settlement
4. 마지막 Stage가 아니면 `final_stage_score >= clear_score` 판정
5. 성공 → Scale Shift
6. 실패 → Run End

### Final Settlement

Settlement는 게임플레이 머지가 아니다.

SETTLING 진입 시 활성 공 인덱스를 snapshot하고 Settlement 전용 경로로 처리한다.

각 snapshot 공에 대해:

```text
settlement_score += ball.score_value
```

- Time Bonus 없음
- Active Cashout 전용 modifier 없음
- 추가 머지 없음
- `stage_score += settlement_score`와 `run_score += settlement_score`를 한 번만 실행
- 일반 Cashout 함수를 호출하지 않음
- snapshot 공을 settlement reserved/deactivated 처리한 뒤 제거
- `settlement_applied`로 중복 호출 방지
- 공은 연출 큐를 통해 제거
- score 누적 연출은 배치 처리 가능
- 수천 공이 있을 때 각 공마다 무거운 Tween/Node를 만들지 않음

Final Settlement 도중 새로운 Cashout 신호가 중복 발생하지 않게 한다.

### Stage state 예시

```text
READY
PLAYING
CLEAR_LOCKED
TIME_UP_LOCKED
SETTLING
CLEARED
SHIFTING
FAILED
FINISHED
```

Stage 전환과 Settlement는 중복 실행되지 않도록 상태로 보호한다.

---

## FILE: 04_PROJECT_STRUCTURE.md

# Snowball Effect — Project Structure

## 1. 권장 디렉터리

```text
res://
├─ project.godot
├─ scenes/
│  ├─ main/
│  │  └─ main.tscn
│  ├─ gameplay/
│  │  ├─ paddle.tscn
│  │  └─ item_pickup.tscn
│  ├─ backgrounds/
│  │  ├─ ground_background.tscn
│  │  ├─ planetary_background.tscn
│  │  ├─ galactic_background.tscn
│  │  └─ black_hole_background.tscn
│  ├─ effects/
│  │  ├─ merge_effect.tscn
│  │  ├─ cashout_effect.tscn
│  │  ├─ score_popup.tscn
│  │  └─ high_grade_cutin.tscn
│  └─ ui/
│     ├─ hud.tscn
│     ├─ pause_menu.tscn
│     └─ result_panel.tscn
├─ scripts/
│  ├─ core/
│  │  ├─ game_manager.gd
│  │  ├─ stage_manager.gd
│  │  └─ game_state.gd
│  ├─ simulation/
│  │  ├─ ball_simulation_manager.gd
│  │  ├─ spatial_grid.gd
│  │  └─ ball_renderer.gd
│  ├─ gameplay/
│  │  ├─ paddle.gd
│  │  ├─ item_manager.gd
│  │  └─ item_pickup.gd
│  ├─ presentation/
│  │  ├─ effect_manager.gd
│  │  ├─ presentation_manager.gd
│  │  ├─ cutin_controller.gd
│  │  ├─ audio_manager.gd
│  │  ├─ background_manager.gd
│  │  └─ camera_controller.gd
│  ├─ ui/
│  │  ├─ hud.gd
│  │  └─ result_panel.gd
│  └─ utils/
│     ├─ score_formatter.gd
│     └─ math_utils.gd
├─ resources/
│  ├─ balls/
│  ├─ stages/
│  └─ items/
├─ assets/
│  ├─ sprites/
│  ├─ backgrounds/
│  ├─ particles/
│  ├─ audio/
│  ├─ fonts/
│  └─ shaders/
├─ tests/
│  ├─ reflection_test_scene.tscn
│  ├─ merge_test_scene.tscn
│  └─ stress_test_scene.tscn
└─ docs/
   └─ 이 문서 세트
```

처음부터 빈 폴더를 과도하게 만들 필요는 없다.  
단계별로 필요한 파일만 만들되 책임 경계를 유지한다.

---

## 2. Main 씬

권장 씬 트리:

```text
Main (Node)
├─ GameManager
├─ StageManager
├─ BallSimulationManager
├─ BallRenderer
├─ ItemManager
├─ EffectManager
├─ AudioManager
├─ BackgroundManager
├─ Camera2D
├─ StageWorld (Node2D)
├─ MachineFrame (Node2D)
├─ PlayField (Node2D)
│  ├─ Paddle
│  ├─ LeftBoundary
│  ├─ RightBoundary
│  ├─ TopBoundary
│  └─ ScoreZone
└─ UI (CanvasLayer)
   ├─ HUD
   ├─ AnnouncementLayer
   ├─ PauseMenu
   ├─ DebugHUD
   ├─ GlobalDimmer
   ├─ CutInLayer
   └─ ResultPanel
```

경계는 반드시 물리 노드일 필요가 없다.  
BallSimulationManager가 플레이 필드 Rect를 받아 직접 처리해도 된다.

---

## 3. 클래스 책임

### GameManager

책임:

- 게임 상태 (`READY`, `PLAYING`, `PAUSED`, `FINISHED`)
- 전체 누적 점수
- 기록 통계
- Run 상태
- 시작·일시정지·종료·재시작
- 시스템 신호 연결

하지 않는 일:

- 공 이동 계산
- 파티클 직접 생성
- 배경 직접 변경

### StageManager

책임:

- StageDefinition 로드
- 현재 Stage
- Stage 제한 시간 / 남은 시간
- Stage 점수 / clear_score
- 기본/최고 global_level
- 현재 생성량
- Cashout Time Bonus 반영
- 최고 공 즉시 Clear
- Time Up
- Final Settlement
- Score Clear / Fail 판정
- Scale Shift 순서
- 블랙홀 활성 여부와 파라미터

### BallSimulationManager

책임:

- 모든 논리 공
- 생성·제거·재사용
- 이동
- 충돌
- 합체
- 회수
- 전역 힘
- 성능 지표

### BallRenderer

책임:

- 논리 데이터를 화면에 그림
- 레벨·특수 타입에 따른 표현
- 시뮬레이션 규칙을 변경하지 않음

### Paddle

책임:

- 입력
- 위치·회전
- 충돌 계산에 필요한 변환과 속도 제공
- Fire 상태 시각 표현

### ItemManager

책임:

- 아이템 스폰 타이머
- 활성 효과
- 지속시간
- 아이템 획득 신호
- 효과 종료

### EffectManager

책임:

- 합체·회수·아이템·Scale Shift 연출
- 이벤트 등급별 FX 예산
- 히트스톱 요청
- 점수 팝업 풀


### PresentationManager

책임:

- 고등급 CUT-IN 우선순위
- CUT-IN cooldown
- GlobalDimmer
- 짧은 프레젠테이션 pause
- Scale Shift와 일반 CUT-IN 충돌 조정

### CutInController

책임:

- 패널 진입/체류/퇴장
- 공/아이템 이름과 스프라이트 바인딩
- VALUE/효과 텍스트
- 완료 신호

하지 않는 일:

- 머지 판정
- 점수 변경
- Stage 변경

### BackgroundManager

책임:

- 현재 배경 씬 전환
- 블랙홀 위치와 시각
- 배경 파티클
- 논리 시뮬레이션을 직접 수정하지 않음

### AudioManager

책임:

- 효과음 채널
- 합체 레벨별 피치/저음
- 사운드 동시 재생 제한
- 첫 입력 후 오디오 활성화

---

## 4. 데이터 흐름

```text
Input
 → Paddle

StageManager
 → BallSimulationManager: base_level, spawn_rate, global effects

BallSimulationManager
 → signals: merge, cashout, highest_level

GameManager
 ← cashout: score/statistics
 ← timer: finish

EffectManager
 ← merge/cashout/stage/item signals

BackgroundManager
 ← stage changed

HUD
 ← GameManager and StageManager state
```

시스템 간 직접 노드 탐색을 최소화하고, 명확한 참조 또는 신호를 사용한다.

---

## 5. Resource 정의

### BallDefinition

파일 예:

```text
resources/balls/ball_00_snowflake.tres
```

필드:

```text
global_level
display_name
score_value
base_color
texture
fx_tier
base_speed_override  # future/optional; current version uses shared Spawn tuning
```

현재 등급별 base speed 차이는 사용하지 않는다. 향후 override를 도입해도 생성 시 초기 기준일 뿐 runtime speed를 고정하지 않는다. 공통 Spawn speed 범위와 runtime cap은 simulation physics tuning에서 관리한다.

### StageDefinition

```text
stage_index
display_name
base_global_level
top_global_level
base_time
clear_score
time_bonus_by_local_level
spawn_rate
visual_radius_scale  # 화면상 공 크기 보정; 물리 radius에는 영향 없음
background_scene
black_hole_enabled
black_hole_strength
```

### ItemDefinition

```text
item_type
display_name
duration
magnitude
spawn_weight
icon
```

---

## 6. 파일 명명

- 파일: `snake_case`
- 클래스: `PascalCase`
- 변수/함수: `snake_case`
- 상수: `UPPER_SNAKE_CASE`
- 신호: 과거형 또는 사건형 (`ball_merged`, `score_added`)
- private helper는 `_` 접두사 허용

---

## 7. 씬 협업 규칙

- 한 사람이 하나의 큰 `.tscn`을 독점적으로 담당
- 공 시뮬레이션은 코드 중심으로 유지
- 배경과 효과는 별도 씬
- UI는 별도 씬
- Main 씬의 잦은 동시 편집 방지
- 씬 연결은 명시적인 exported NodePath 또는 코드 조립 사용

---

## 8. 의존 방향

권장:

```text
presentation → core state를 읽음
simulation → data와 core interface에 의존
core → presentation 세부를 모름
```

금지:

- BallRenderer가 점수를 변경
- UI가 직접 공 배열을 수정
- BackgroundManager가 공을 제거
- EffectManager가 Stage를 임의로 올림

---

## 9. 최소 초기 파일

Phase 1에서는 아래만 있으면 된다.

```text
project.godot
scenes/main/main.tscn
scenes/gameplay/paddle.tscn
scripts/core/game_manager.gd
scripts/simulation/ball_simulation_manager.gd
scripts/simulation/ball_renderer.gd
scripts/gameplay/paddle.gd
scripts/ui/hud.gd
scripts/utils/score_formatter.gd
```

복잡한 폴더와 클래스를 선행 생성하지 않는다.

---

## FILE: 05_IMPLEMENTATION_PLAN.md

# Snowball Effect — Implementation Plan

## 공식 제출 게이트

- 공식 Track 1 접수 마감: **2026-08-26**
- 내부 기능 동결 목표: **2026-08-25**
- 브라우저 직접 실행 Web Build는 필수다.
- 선택 기능보다 Playability, public URL, 결과/Retry, 실제 플레이 영상 준비를 우선한다.
- 실제 Codex 작업은 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 개발 중 기록한다.

---

# 전체 원칙

- 한 단계씩 구현한다.
- 각 단계 종료 시 플레이 가능해야 한다.
- 아트보다 회색 원과 막대로 전체 루프를 먼저 완성한다.
- 성능은 수치로 확인한다.
- 일정이 부족하면 아래 컷라인을 따른다.

---

# Phase 0 — 프로젝트 부트스트랩

## 목표

Godot 프로젝트가 열리고 빈 Main 씬이 실행된다.

## 작업

- Godot 4 프로젝트 생성
- 기준 해상도와 Stretch 설정
- Input Map 등록
- 폴더 기본 구조
- Main 씬
- 디버그 출력
- Web Export preset 준비 가능 여부 확인

## 완료 조건

- 에디터 실행 성공
- 브라우저 테스트 또는 최소 Export preset 생성 가능
- 파싱 오류 없음

---


# Phase 0.5 — 화면 골격 / 디자인 계약

상세:

- `DESIGN/00_VISUAL_IDENTITY.md`
- `DESIGN/01_SCREEN_COMPOSITION.md`

## 목표

최종 아트를 만들지 않고도 화면의 구조가 Snowball Effect답게 보이게 한다.

## 작업

- 16:9 Viewport
- 중앙 세로 Play Field Rect
- 좌우 Stage World 영역
- 단순 픽셀 기계 프레임 placeholder
- UI가 Play Field를 과도하게 가리지 않는 기본 배치
- Play Field Rect를 시뮬레이션 상수/설정으로 노출

## 완료 조건

- 전체 16:9와 실제 물리 영역이 분리됨
- 공과 패들은 중앙 영역을 벗어나지 않음
- 좌우에 Stage 배경을 표현할 실제 공간이 남음
- 브라우저 resize 시 구도가 유지됨


# Phase 1 — 최소 플레이 루프

상세: `tasks/01_minimum_loop.md`

## 구현

- 상단에서 기본 공 생성
- 아래쪽 반구 초기 velocity로 지속 이동 — 기본 gravity 0
- 좌우·상단 벽 반사와 열린 하단 Cashout
- `A/D` 패들 이동
- `←/→` 패들 회전
- 패들 반사
- 바닥 점수 회수
- 점수 UI
- 개발용 Stage 타이머
- 단순 원 렌더링

## 완료 조건

- 공 100개가 안정적으로 움직임
- 이동과 각도를 동시에 조작 가능
- 반사 방향이 눈으로 학습 가능
- Paddle hit으로 runtime speed가 변할 수 있고 cap으로 폭주하지 않음
- 놓친 공은 점수로 바뀜
- 재시작 가능

---

# Phase 2 — 합체 시스템

상세: `tasks/02_merge_system.md`

## 구현

- 공 `global_level`
- 공 정의 데이터
- 같은 레벨 근접 판정
- 합체 큐
- 상위 공 생성
- 크기·색·점수 변화
- 기본 합체 이펙트
- 최고 생성 레벨 기록

## 완료 조건

- 같은 레벨 두 공만 합체
- 한 공이 같은 프레임에 두 번 합체하지 않음
- 연쇄 합체가 다음 프레임부터 정상 동작
- 다른 레벨 공은 합체하지 않음
- 점수표가 데이터로 관리됨

---

# Phase 2.5 — Cashout / Stage Time Economy

상세: `tasks/02_5_cashout_time_stage_clear.md`

## 구현

- StageDefinition `base_time`, `clear_score`, `time_bonus_by_local_level`
- Stage별 타이머
- 일반 Cashout = Score + Time Bonus
- 최고 공 즉시 Stage Clear
- Time Up 처리
- Final Settlement = Score Only
- Settlement snapshot / 중복 잠금
- `stage_score` / `run_score` 점수 source of truth
- 동일 tick Cashout 회복과 Top Ball 우선순위
- Score Clear / Fail
- 마지막 Stage 예외 흐름

## 완료 조건

- 고등급 공을 Cashout하면 Score와 시간이 함께 증가
- Final Settlement에서는 시간이 증가하지 않음
- Final Settlement에서는 Active Cashout 전용 modifier가 적용되지 않음
- Settlement 재호출 시 점수가 중복되지 않음
- 최고 공 제작 시 즉시 성공 상태
- Time Up 후 점수컷 판정
- 실패 시 Run End
- 성공 시 다음 Stage 준비

# Phase 3 — 대량 시뮬레이션

상세: `tasks/03_mass_simulation.md`

## 구현

- 배열 기반 공 데이터 정리
- 비활성 슬롯 재사용
- Uniform Grid / Spatial Hash
- 후보 검사 수 디버그
- 스트레스 테스트 씬
- 저레벨 렌더 일괄화

## 성능 게이트

- 논리 공 1,000개
- 웹 또는 데스크톱에서 30 FPS 이상
- 전수 비교가 없음
- 활성 수 증가 시 프레임 시간이 완만하게 증가

성능이 이미 충분하면 과도한 저수준 최적화를 하지 않는다.

---

# Phase 4 — Stage와 Scale Shift

상세: `tasks/04_stage_shift.md`

## 구현

- StageDefinition
- Ground / Planetary / Galactic
- Stage별 base_time / clear_score 밸런스 데이터
- 이전 최고 공 = 다음 기본 공
- 생성량 증가
- 크기 정규화
- 낮은 레벨 공 정리
- Stage별 좌우 World 배경 전환
- 아케이드 기계의 Stage 상태 변화
- `SCALE SHIFT`
- visual radius 재정규화
- 개발용 강제 스테이지 전환 키

## 완료 조건

- Ground/Planetary 최고 공 생성 시 Stage Clear
- Time Up Score Clear로도 다음 Stage 진입 가능
- 점수컷 미달 시 Run End
- 새 기본 공이 정상 생성
- 이전 저레벨 공 정리
- 스테이지 전환 중 점수·시뮬레이션이 깨지지 않음

---

# Phase 5 — 보상 연출

상세: `tasks/05_effects.md`

## 구현

- 합체 단계별 파티클
- 회수 단계별 점수 팝업
- 카메라 흔들림
- 고레벨 히트스톱
- Scale Shift 줌
- 사운드 위계
- FX 예산과 동시 재생 제한
- 고등급 공 CUT-IN
- 전체 장면 freeze + dim
- CUT-IN 우선순위/cooldown
- 일반 CUT-IN과 Scale Shift 분리

## 완료 조건

- 낮은 이벤트와 높은 이벤트의 차이가 명확
- 고레벨 회수가 강한 보상으로 느껴짐
- 이펙트가 공과 UI를 완전히 가리지 않음
- 연출 때문에 FPS가 지속적으로 무너지지 않음

---

# Phase 6 — 아이템

상세: `tasks/06_items.md`

## 우선순위

1. Blizzard
2. Fire Core
3. Magnet

## 완료 조건

- 아이템은 현재 Stage의 3단계 이상 Snowball(`local_level >= 2`)이 Item Ball을 여러 번 깨뜨려 획득
- hit 누적 균열/파편 뒤 최종 파괴 시 CUT-IN과 1회 activation
- 놓치면 사라짐
- 지속 시간이 HUD에 표시
- 같은 아이템 재획득 시 갱신
- Fire 공의 합체·점수 배수 정상
- Magnet이 전수 비교를 만들지 않음

---

# Phase 7 — Galactic Black Hole 국면

상세: `tasks/07_black_hole.md`

## 구현

- 마지막 Galactic 스테이지의 Black Hole 맵 기믹
- 배경 블랙홀 이동
- 전역 인력
- 궤도 잔상
- Lv14 Black Hole Snowball과 최종 결과 연결
- 후반 생성량
- 왜곡 또는 대체 연출

## 완료 조건

- 블랙홀 위치에 따라 궤도가 확실히 달라짐
- 플레이가 어려워지지만 불가능하지 않음
- 공이 영구적으로 갇히지 않음
- 후반 물량과 연출을 켠 웹 빌드가 실행됨

---

# Phase 8 — 웹 배포와 제출

상세: `tasks/08_web_export_release.md`

## 구현

- Stage별 정식 제한 시간 / clear_score
- 시작 화면
- 조작 안내
- 결과 화면
- Web Export
- 정적 호스팅
- 브라우저별 확인
- 3분 플레이 영상
- Codex 활용 기록 정리

---

# MVP 컷라인

## 반드시 남김

공식 심사와 제출 관점에서 P0다.


- 패들 이동·회전
- 반사
- 합체
- 점수 회수
- 점수 폭증
- Stage local level별 Time Bonus
- Stage별 제한 시간
- 최고 공 즉시 Clear
- Time Up Final Settlement
- Score Clear / Run Fail
- Ground → Planetary → Galactic
- 스테이지 기본 단위 승격
- 생성량 증가
- 고레벨 이펙트
- Stage 기반 한 Run 결과 화면
- 웹 실행

## 일정 부족 시 순서대로 제거

1. Magnet
2. Fire의 복잡한 전파 규칙
3. Black Hole 왜곡 셰이더
4. Lv14 Black Hole 이후의 확장 공 콘텐츠
5. 개별 고급 공 텍스처
6. 추가 사운드 레이어

## 제거하지 않음

- Scale Shift
- 이전 최고 공이 다음 기본 공이 되는 규칙
- 스테이지별 생성량 증가
- 점수 뇌절
- 이동 + 각도 조작

이 네 가지가 게임 정체성이다.

---

# 추천 3인 역할

## A — 시뮬레이션/코어

- 공 데이터
- 패들 반사
- 합체
- Spatial Grid
- 성능

## B — 연출/아트

- 배경
- 공 외형
- 파티클
- 카메라
- 사운드

## C — 통합/제품

- Stage
- Item
- UI
- Web Export
- 테스트
- 발표와 영상

모두 기능 통합과 플레이 테스트에 참여한다.

---

# 제출용 Phase 9 — Submission Package

상세: `tasks/09_submission_package.md`

## 구현/작성

- 200자 소개 최종 검증
- 16:9 썸네일
- 실제 플레이가 포함된 3분 이하 데모 영상
- 실제 Codex 협업 로그 기반 설명
- public URL 시크릿 창 테스트
- 본선용 3분 피치 초안 준비

## 완료 조건

- `SUBMISSION/06_RELEASE_CHECKLIST.md`의 제출 필수 항목 통과
- 제출 당일 새 기능을 만들지 않아도 되는 상태

---

## FILE: 06_CODEX_WORKING_RULES.md

# Snowball Effect — Codex Working Rules

## 1. 작업 시작 전

반드시:

1. `AGENTS.md` 읽기
2. `00_READ_FIRST.md` 읽기
3. 관련 게임 규칙과 기술 설계 읽기
4. 현재 작업 문서 읽기
5. 기존 파일 구조와 코딩 스타일 확인
6. 변경 범위를 짧게 정리한 뒤 구현

이미 답이 문서에 있는 질문을 사용자에게 다시 묻지 않는다.

---

## 2. 작업 단위

한 번에 하나의 Phase 또는 하나의 명확한 하위 기능만 구현한다.

좋은 예:

- 패들 반사만 구현
- 합체 중복 방지만 수정
- Spatial Grid를 추가하고 수치 비교
- Blizzard만 추가

나쁜 예:

- 시뮬레이션부터 아트, 아이템, UI까지 한 번에 구현
- 전체 구조를 임의로 ECS로 교체
- 요청 없이 C#으로 전환

---

## 3. 코드 변경 원칙

- Godot 4.x API만 사용
- 문법과 API를 추측하지 않음
- deprecated API 사용 금지
- 타입 힌트를 가능한 범위에서 사용
- 함수는 한 책임
- 매직 넘버는 설정 또는 상수
- 게임 규칙과 표현 코드 분리
- 기존 파일 이름과 책임을 존중
- 요청 없는 대규모 리팩터링 금지
- 복잡한 추상화보다 읽기 쉬운 직접 구현 우선

---

## 4. 성능 원칙

절대 하지 않음:

- 수천 개 `RigidBody2D`
- 공마다 개별 `_physics_process`
- N² 전수 충돌
- 매 프레임 대량 `instantiate()`/`queue_free()`
- 저레벨 공마다 개별 타이머와 Tween
- 파티클을 게임 상태로 사용

최적화는 측정 후 수행한다.  
성능 문제를 해결하기 위해 게임 규칙을 몰래 변경하지 않는다.

---

## 5. 씬 파일

- `.tscn`을 직접 수정할 때 기존 형식을 보존
- 한 번에 큰 씬 전체를 재생성하지 않음
- 연결 대상 NodePath 확인
- 없는 리소스 경로를 만들지 않음
- 에디터에서 열 수 있는지 검증
- 가능하면 기능별 작은 씬 사용

---

## 6. 오류 처리

변경 후 최소한 확인:

- GDScript 파싱 오류
- 누락된 NodePath
- 누락된 Resource
- 런타임 null 접근
- 배열 인덱스 오류
- 중복 합체
- 점수 NaN/Infinity
- 웹 콘솔 오류

실행할 수 없는 환경이면 실행하지 못했다고 명시하고, 정적 확인 범위를 적는다.

---

## 7. 가정

작은 구현 세부를 스스로 결정할 수 있다.

예:

- 변수 이름
- 내부 helper 함수
- 디버그 HUD 배치
- 임시 색상

다음은 임의 변경 금지:

- 조작 키
- 점수 철학
- 스테이지 기본 단위 승격
- 바닥 도달의 의미
- Stage 구조
- 마지막 Galactic Stage의 Black Hole 맵 기믹 전역 인력
- 저레벨 공의 데이터 중심 처리

---

## 8. 임시 구현

임시 도형과 placeholder는 허용한다.

조건:

- 파일과 코드에 `TODO` 또는 명확한 이름 사용
- 최종 에셋처럼 속이지 않음
- 핵심 게임 루프는 실제로 작동
- placeholder가 성능 측정을 왜곡하지 않음

---

## 9. 테스트

각 작업에서 다음 중 관련 항목을 검증한다.

- 정상 시나리오
- 경계 시나리오
- 빠른 연속 입력
- 공 수 증가
- 스테이지 전환
- 일시정지
- 재시작
- 웹 크기 변경

테스트용 치트키는 개발 빌드에서 허용한다.

예:

- 공 100개 생성
- 특정 레벨 공 2개 생성
- 다음 Stage 강제 이동
- 시간 10초 남기기

릴리스 UI에는 노출하지 않는다.

---

## 10. 완료 보고

반드시 포함:

- 구현한 것
- 구현하지 않은 것
- 변경 파일
- 실행/검증 방법
- 측정값
- 알려진 문제
- 다음 작업

“완료”라는 말은 완료 조건을 실제로 만족할 때만 쓴다.

---

## 11. Git 작업

사용자가 명시적으로 요청하지 않으면:

- commit 하지 않음
- push 하지 않음
- PR 만들지 않음

변경을 만들 때는 독립적으로 리뷰 가능한 범위를 유지한다.

---

## 12. 금지된 과잉 설계

MVP에서 다음을 새로 도입하지 않는다.

- 자체 DI 컨테이너
- 네트워크 계층
- 데이터베이스
- 복잡한 ECS 프레임워크
- 멀티스레드 작업 시스템
- 별도 빌드 도구
- 대규모 플러그인 의존성

필요성이 측정되기 전에는 단순한 Godot 구조를 사용한다.

---

## 13. Hackathon Evidence Rule

의미 있는 Codex 작업이 끝난 뒤 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 기록할 수 있도록 아래 사실을 작업 보고에 남긴다.

- 해결하려던 실제 문제
- Codex가 변경한 파일/기능
- 사람이 선택한 설계 판단
- 실행하거나 측정한 검증 결과
- before/after 수치가 있다면 실제 측정값

측정하지 않은 FPS, 성능 향상률, 버그 해결 결과를 만들어내지 않는다.

## 14. Submission Stability Rule

공식 제출 제약과 충돌하면 다음 순서를 따른다.

1. public Web Build 실행 가능성
2. 코어 플레이 안정성
3. Scale Shift 가시성
4. 성능
5. 결과/Retry 및 안내 UI
6. 제출 증거와 영상
7. 선택 아이템 / 고급 셰이더 / 추가 콘텐츠

선택 기능을 유지하기 위해 제출 가능한 빌드를 망가뜨리지 않는다.

---

## 15. Hackathon Collaboration Log — REQUIRED

의미 있는 Codex 개발 작업을 마칠 때마다 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 새 항목을 append한다.

로그 작성은 Definition of Done의 일부이며, 로그가 없으면 해당 작업은 완료로 간주하지 않는다.

반드시 실제로 확인된 내용만 기록한다. 테스트하지 않은 것은 `Not verified`, 커밋하지 않은 것은 `Not committed`로 명시한다. 이전 로그를 요약하거나 덮어쓰지 않는다.

기록 항목:
- 날짜/시간
- 작업 또는 문제
- 사람이 결정한 사항
- Codex가 구현·조사·디버깅한 내용
- Codex 제안 중 수용/변경/거절된 중요한 사항
- 변경 파일
- 발생한 오류/문제
- 실제 검증 결과
- 관련 성능 측정값
- 실제 커밋이 존재할 때만 커밋 해시



---

## Stage / Time Economy rules

다음 규칙은 임의 변경 금지:

- Stage별 제한 시간
- 일반 Cashout = Score + Time Bonus
- Final Settlement = Score only
- 최고 공 생성 = 즉시 Stage Clear
- Time Up 후 clear_score 판정
- 성공한 Stage의 Settlement 후 Scale Shift
- Time Up은 같은 physics tick의 Merge와 Active Cashout 반영 후 판정
- 같은 tick에서는 Top Ball Clear가 Time Up보다 우선
- Settlement는 base score만 한 번 반영하고 Active Cashout 전용 modifier를 적용하지 않음
- 점수 이벤트마다 `stage_score`와 `run_score`를 함께 증가시키며 Stage 종료 시 재합산 금지

밸런스 수치(`base_time`, `clear_score`, `time_bonus_by_local_level`)는 플레이테스트로 조정할 수 있지만
규칙 자체를 단순화하거나 제거하지 않는다.

---

## FILE: 07_INITIAL_PROMPT.md

# Codex 최초 실행 프롬프트

아래 내용을 새 Codex 세션의 첫 지시로 사용한다.

---

`AGENTS.md`와 `00_READ_FIRST.md`부터 읽고, `DESIGN/` 문서를 포함한 연결된 기획 및 기술 문서와 `08_HACKATHON_REQUIREMENTS.md`를 순서대로 확인해라.

Godot 4.x로 브라우저에서 실행 가능한 2D 액션 머지 게임 **Snowball Effect**를 구현한다.

핵심 규칙은 다음과 같다.

1. 화면 상단에서 현재 스테이지의 기본 공이 지속적으로 떨어진다.
2. 플레이어는 `A/D`로 하단 패들을 좌우 이동한다.
3. 플레이어는 좌우 방향키로 패들의 각도를 변경한다.
4. 이동과 회전은 동시에 가능하다.
5. 공은 좌우 벽과 패들에 반사된다.
6. 같은 `global_level`의 공 두 개가 접촉하면 다음 레벨 공 하나로 합쳐진다.
7. 다른 레벨 공은 MVP에서 서로 물리 충돌하지 않는다.
8. 공이 패들 아래 점수 구역으로 떨어지면 실패가 아니라 Cashout이며, 활성 Stage에서는 해당 공의 점수와 Time Bonus를 획득한다.
9. 점수는 2배 보존 방식이 아니라 레벨마다 100배, 1,000배 등 의도적으로 폭증하며 데이터에 직접 정의한다.
10. 각 스테이지는 4개의 로컬 레벨을 가진다.
11. 현재 스테이지 최고 공을 처음 만들면 `SCALE SHIFT`가 발생한다.
12. 이전 스테이지의 최고 공은 다음 스테이지의 기본 공이 된다.
13. 스테이지가 오를수록 기본 공 생성량이 증가한다.
14. Ground, Planetary, Galactic의 3개 스테이지를 목표로 한다.
15. 마지막 Galactic 스테이지에서 Lv14 `Black Hole` Snowball이 최고 공이며, 별도의 상단 Black Hole 맵 기믹은 좌우로 이동하며 공에 약한 인력을 가한다.
16. 고레벨 합체와 회수는 강한 파티클, 점수 팝업, 화면 흔들림과 짧은 히트스톱으로 강조한다.
17. Blizzard, Fire Core, Magnet 아이템은 이후 단계에서 추가한다.
18. 16:9 전체가 플레이 영역이 아니다. 실제 공 시뮬레이션은 중앙의 세로형 Play Field에서만 일어난다.
19. 좌우 여백은 Stage World와 Retro Pixel Arcade Machine 프레임/계기판 공간이다.
20. 전체 비주얼 정체성은 Retro Pixel Arcade Machine × Cosmic Escalation이다.
21. 일반 머지는 빠른 포화형 이펙트로 처리하고, 중요한 고등급 이벤트만 짧은 CUT-IN을 사용한다.
22. 일반 CUT-IN은 현재 장면 전체를 freeze + dim한 뒤 픽셀 기계 패널이 약 0.45~0.7초 안에 지나가며, 별도 화면을 띄우지 않는다.
23. SCALE SHIFT는 일반 CUT-IN과 별도이며 Stage 세계, 생성량, 기본 공, visual scale이 실제로 변경되는 더 높은 우선순위 이벤트다.
24. 각 Stage는 독립적인 제한 시간 라운드다. 하나의 전역 180초 타이머로 구현하지 않는다.
25. 일반 Cashout은 Score + 현재 Stage local level의 time_bonus다. Local Lv0는 0초에서 시작한다.
26. 현재 Stage 최고 공 생성은 즉시 Stage Clear다.
27. Time Up 시 활성 공을 Final Settlement하며 Score만 더하고 Time Bonus는 주지 않는다.
28. Time Up 후 final Stage score가 clear_score 이상이면 다음 Stage, 미달이면 Run End다.
29. 성공한 Stage는 Settlement 이후 Scale Shift로 다음 Stage에 진입한다.
30. 마지막 Galactic Stage는 Time Up 또는 Black Hole 생성 후 Final Settlement와 Result로 종료한다.
31. Time Up은 같은 physics tick의 Merge와 Active Cashout을 먼저 반영한 뒤 판정한다. Cashout으로 시간이 양수가 되면 플레이를 계속한다.
32. 같은 tick에서는 Top Ball Clear가 Time Up보다 우선한다.
33. 모든 점수 이벤트는 `stage_score`와 `run_score`에 같은 amount를 한 번씩 더하며 Stage 종료 시 `run_score += stage_score`를 하지 않는다.
34. Final Settlement는 active ball snapshot의 기본 score_value만 한 번 합산하며 Time Bonus, Active Cashout 전용 modifier, 추가 Merge를 적용하지 않는다.

기술 제한:

- 공 수천 개를 개별 `RigidBody2D`나 개별 씬 인스턴스로 만들지 마라.
- 중앙 `BallSimulationManager`가 배열 기반으로 공을 관리해야 한다.
- 모든 공 쌍을 전수 비교하지 마라.
- 합체 후보는 Uniform Grid 또는 Spatial Hash로 줄여라.
- 생성과 제거는 비활성 슬롯 재사용 방식으로 처리해라.
- 게임 규칙 공과 GPU 장식 파티클을 분리해라.
- Godot 4.x API만 사용하고 deprecated API를 사용하지 마라.
- 기능을 한꺼번에 구현하지 말고 항상 실행 가능한 상태를 유지해라.
- 요청하지 않은 대규모 리팩터링을 하지 마라.
- 웹 빌드는 최종 필수 제출 형식이므로 초기 Phase부터 실제 Web Export 가능성을 고려해라.
- 실제 Codex 작업 결과는 나중에 제출 증거가 될 수 있도록 문제/변경/사람의 판단/검증을 작업 보고에 구분해라.

이번 작업에서는 `tasks/01_minimum_loop.md`만 구현해라.

구현 전에:
1. 현재 저장소를 검사한다.
2. 필요한 파일과 변경 계획을 짧게 정리한다.
3. 기존 프로젝트가 있으면 구조를 유지한다.

구현 후:
1. 파싱 오류와 런타임 오류를 확인한다.
2. 최소 플레이 시나리오를 검증한다.
3. 변경 파일, 실행 방법, 검증 결과, 알려진 문제를 보고한다.
4. 합체, Stage Shift, 아이템, 고급 파티클은 아직 구현하지 않는다.


작업 완료 후 `AGENTS.md` 규칙에 따라 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 실제 작업·의사결정·검증 결과를 append해라. 이 로그까지 작성해야 이번 작업을 완료로 간주한다.


이후 머지 시스템이 완성되면 `tasks/02_5_cashout_time_stage_clear.md`를 반드시 구현해
Cashout Time Bonus와 Stage 판정 루프를 확정한 뒤 Scale Shift 작업으로 진행한다.

---

## FILE: 08_HACKATHON_REQUIREMENTS.md

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

---

## FILE: tasks/01_minimum_loop.md

# Task 01 — Minimum Play Loop

## 목적

회색 원과 단순 패들만으로 게임의 가장 작은 플레이 루프를 완성한다.

```text
공 생성 → 아래쪽 초기 velocity → 벽/패들 반사 → 열린 하단 Cashout → 점수
```

합체와 Stage는 아직 구현하지 않는다.

---

## 범위

### 포함

- Main 씬
- 중앙 Play Field Rect + 좌우 Stage World placeholder
- GameManager
- Paddle
- BallSimulationManager
- BallRenderer
- HUD
- 기본 공 생성
- 지속 중력 없는 velocity 이동
- 좌우·상단 벽 반사
- 열린 하단 경계
- 패들 충돌과 반사
- 점수 구역
- 점수 증가
- 개발용 Stage 타이머
- 재시작
- 디버그 활성 공 수

### 제외

- 공끼리 충돌
- 합체
- Stage
- Item
- 파티클
- 블랙홀
- 고급 에셋
- 정식 Stage별 시간 / Clear / Settlement 흐름

---

## 입력

- `A/D`: 패들 이동
- `←/→`: 패들 회전
- `Mouse X`: Play Field logical X로 변환 후 Paddle X에 직접 반영하고 field clamp
- `Mouse Wheel`: 패들 회전 (한 칸당 `mouse_wheel_step_degrees` tuning)
- `R`: 개발용 즉시 재시작
- `Esc`: 일시정지

Input Map에 의미 있는 액션 이름을 사용한다.

```text
paddle_move_left
paddle_move_right
paddle_rotate_left
paddle_rotate_right
pause_game
restart_game
```

---

## 초기 수치

```text
viewport: 1600×900
play_field_width: 전체 폭의 약 40~50%에서 프로토타입 시작(확정값 아님)
spawn_rate: 6/s
gravity: 0
spawn_direction: 아래쪽 반구 안에서 tuning
lv1_physical_design_reference: 일반 눈발 약 1.0 m/s (runtime 환산 없음)
lv1_spawn_speed: 160 world units/s (첫 플레이테스트 tuning)
runtime_speed_min/max: Paddle 반복 타격 폭주 방지용 tuning
paddle_keyboard_speed: 460 px/s
paddle_mouse_position: direct logical-X mapping (no tracking speed cap)
paddle_contact_impact_velocity_cap: separate playtest tuning
paddle_ball_runtime_speed_cap: separate playtest tuning
paddle_rotation_speed: 150 deg/s
paddle_angle: unlimited rotation (equivalent-angle normalization allowed)
mouse_wheel_step_degrees: 5°/step
paddle_width: 240 px
lv1_ball_radius: 4 world units (visual/collision diameter 8; approved Shared Skeleton base size)
```

수치는 한 파일 또는 export 변수에서 쉽게 수정 가능해야 한다.

공간은 `1 world unit = 1 logical pixel`, 시간은 second, 속도는 world units/s다. Lv1 `1.0 m/s`는 physical/design reference이며 runtime value로 직접 환산하지 않는다. 화면 높이 또는 통과시간으로 physical speed를 정의하지 않는다. Spawn/base speed는 초기 velocity를 만드는 기준이며 runtime speed 고정값이 아니다. 현재는 등급별 base speed 차이를 사용하지 않지만 향후 도입은 허용한다.

---

## 패들 반사 완료 조건

- Paddle 앞면과 뒷면 모두에서 실제 접촉 normal을 기준으로 반사
- 공을 패들 표면 밖으로 보정
- 패들 각도에 따라 반사 방향이 명확히 달라짐
- 충돌 위치에 따라 약간의 좌우 편차
- 패들 이동 방향이 소량 반영
- Mouse 직접 위치 반영과 contact impact velocity cap이 분리됨
- 이전/현재 Paddle transform과 ball trajectory의 continuous contact로 translation/rotation tunneling을 방지
- 접촉점 속도에 Paddle 중심 선형속도와 angular contribution이 함께 반영됨
- Paddle hit으로 runtime speed가 변할 수 있음
- tuning 가능한 speed cap으로 반복 타격의 무한 가속 방지
- 반사 후 중력이 상승 속도를 감소시키지 않음
- 같은 공이 패들 안에서 연속 반사되지 않음

---

## 점수

Task 01에서는 모든 기본 공 점수를 1로 사용해도 된다.
Time Bonus와 Stage Clear 판정은 Task 02.5에서 구현한다.

바닥 ScoreZone 통과 시:

- 점수 +1
- 공 비활성화
- 슬롯 재사용
- HUD 갱신

---

## 데이터 구조

처음부터 공마다 Node를 만들지 않는다.

최소 배열:

```gdscript
positions
velocities
radii
active_flags
free_indices
```

Task 01에서는 Spatial Grid가 필요하지 않다.

---

## 완료 조건

- 프로젝트 실행 성공
- 전체 Viewport와 중앙 Play Field가 분리되어 있음
- 공/패들/ScoreZone은 중앙 Play Field 기준으로 동작
- 60초 동안 공이 계속 생성
- 100개 이상 활성 공에서 정상 실행
- A/D 이동 정상
- 방향키 회전 정상
- 동시 입력 정상
- Mouse X가 지연 없이 logical Paddle X에 반영되고, Wheel 회전과 동시에 사용 가능
- 실제 previous/current transform에서 계산한 center/angular velocity가 contact point impact에 반영됨
- 반사 예측 가능
- 바닥 도달 시 점수 증가
- Pause/Restart 정상
- 파싱 및 런타임 오류 없음

---

## 검증 시나리오

1. 패들을 수평으로 두고 공이 거의 위로 반사되는지 확인
2. 왼쪽으로 기울여 왼쪽 궤도가 증가하는지 확인
3. 오른쪽으로 기울여 오른쪽 궤도가 증가하는지 확인
4. 이동 중 공을 맞혀 미세한 이동 보너스 확인
5. 상호작용이 없는 공의 velocity/speed가 지속 중력 없이 유지되는지 확인
6. 상단 벽에서 speed를 유지하며 반사되는지 확인
7. Paddle hit이 runtime speed를 바꿀 수 있고 cap을 넘지 않는지 확인
8. 빠른 Mouse translation과 360° 연속 회전 sweep에서 Lv1 공이 Paddle을 통과하지 않는지 확인
9. Paddle 중심/끝 접촉에서 angular contribution 방향과 크기 차이를 확인
10. 패들을 공 아래에서 치워 열린 하단 Cashout으로 점수가 증가하는지 확인
11. 100개 이상 공에서 FPS 확인
12. 일시정지 중 타이머와 공이 정지하는지 확인
13. 재시작 시 previous/current transform, 접촉 잠금, 배열, 점수, 타이머가 초기화되는지 확인

---

## 작업 보고에 포함

- 실제 생성한 씬 트리
- 반사 계산 설명
- 활성 공 100개 시 FPS
- 변경 파일
- 실행 방법
- 남은 문제

---

## FILE: tasks/02_merge_system.md

# Task 02 — Merge System

## 선행 조건

Task 01이 실행 가능해야 한다.

---

## 목적

같은 레벨 공끼리 접촉하면 상위 공으로 합쳐지는 핵심 규칙을 추가한다.

---

## 포함

- BallDefinition 데이터
- global_level
- 레벨별 반지름·색·점수
- 같은 레벨 근접 판정
- merge lock
- 합체 요청 큐
- 상위 공 생성
- 최고 레벨 기록
- 간단한 합체 플래시 또는 원형 파편
- 점수 formatter의 초기 구조

---

## 제외

- Spatial Grid 최적화 완성
- Stage Shift
- 아이템
- 고급 파티클
- 블랙홀

Task 02에서는 공 수를 제한하고 단순 후보 검사로 기능을 먼저 검증할 수 있다.  
다만 전수 비교 코드는 임시임을 명확히 표시하고 Task 03에서 제거한다.

---

## 초기 공 카탈로그

초기 콘텐츠 목표는 `global_level 0~14`의 총 15종이다. Ground(5종) → Planetary(6종) → Galactic(6종)으로 구성하며, 이전 Stage의 최고 공을 다음 Stage의 기본 공으로 공유한다. Lv13은 `Event Horizon`(1.0e43), Lv14는 최종 Clear 공 `Black Hole`(1.0e50)로 확정한다. 정확한 목록과 배분은 `01_PRODUCT_BRIEF.md` §7 및 Content 데이터에서 관리한다.

아래 값은 점수 곡선과 초기 테마를 잡기 위한 seed이며 전체 15종의 확정 목록이 아니다.

```text
0 Snowflake       1
1 Snowball        100
2 Big Snowball    10,000
3 Giant Snowball  1,000,000
4 Moon            100,000,000
5 Earth           50,000,000,000
6 Gas Giant       10,000,000,000,000
```

나머지 global level도 Ground / Planetary / Galactic 콘셉트가 읽히도록 이름, visual key, 반지름과 점수를 데이터로 정의한다. 값은 코드에 하드코딩하지 않는다.

일반 Merge/Cashout 연출용 `fx_tier`는 전역 BallDefinition 값이다. Lv0 = 0, Lv1~3 = 1, Lv4~8 = 2, Lv9~13 = 3, Lv14 Black Hole = 4를 사용한다. Moon(Lv4)과 Galaxy(Lv9)가 다음 Stage의 기본 공으로 재사용되어도 전역 tier는 변하지 않는다. Stage 최고 공 생성은 기본 `fx_tier`와 별도로 Stage Clear 연출을 우선한다.

---

## 합체 규칙

- 같은 global_level만 합체
- 다른 special_type은 Task 02에서 NORMAL뿐
- 같은 프레임에 한 공이 두 합체에 참여 금지
- 결과 레벨 정의가 없으면 더 합체하지 않음
- 새 공은 다음 물리 프레임부터 합체 가능

합체 위치:

```text
(position_a + position_b) / 2
```

합체 결과 velocity는 아직 미정이다. 두 입력 speed의 평균/최대/별도 계산, 새 등급의 base speed 사용 여부, 방향과 cap을 S2의 별도 Merge velocity 계약에서 확정한 뒤 구현한다.

---

## 완료 조건

- 같은 레벨 두 공이 하나의 상위 공으로 합쳐짐
- 공 수가 2 감소 후 1 증가
- 중복 합체 없음
- 다른 레벨은 통과
- 합체 후 렌더 외형과 점수가 바뀜
- 바닥 회수 시 정의된 점수 사용
- 최고 생성 레벨 HUD 표시
- 재시작 시 기록 초기화

---

## 개발 치트

디버그 키 또는 함수:

- 특정 global_level 공 두 개를 가까이 생성
- 활성 공 모두 제거
- 생성 레벨 변경

릴리스 입력에는 노출하지 않는다.

---

## 검증

- Lv0 두 개 → Lv1
- Lv1 두 개 → Lv2
- Lv0 + Lv1 → 합체 안 함
- 세 개가 동시에 겹쳐도 하나의 합체만 발생
- 새 공이 즉시 같은 프레임 재합체하지 않음
- 고레벨 점수 표시가 K/M/B/T로 정상

---

## FILE: tasks/02_5_cashout_time_stage_clear.md

# Task 02.5 — Cashout, Time Bonus, Stage Clear

## 목적

Snowball Effect의 핵심 전략인 다음 선택을 실제 플레이 규칙으로 구현한다.

```text
KEEP for bigger merge
vs
CASHOUT for Score + Time
```

선행:

- Task 01 최소 루프
- Task 02 머지 시스템

---

## 1. 데이터

BallDefinition:

```text
score_value
```

StageDefinition:

```text
base_time
clear_score
base_global_level
top_global_level
spawn_rate
time_bonus_by_local_level
```

같은 global ball이 Stage에 따라 다른 local level이 되므로 Time Bonus를 BallDefinition에 저장하지 않는다.

초기값:

```text
Local Lv0 = +0s
Local Lv1 = +0.25s
Local Lv2 = +0.5s
Local Lv3 = +1s
Local Lv4 = +2s
Local Lv5 = +4s
```

최고 local 공은 생성 즉시 Stage Clear가 잠기므로 일반 Active Cashout 보너스를 실제로 받지 않는다. 따라서 실제 Cashout 보너스 최대치는 Ground에서 +1s, Planetary와 Galactic에서 +2s다.

초기 `base_time` 테스트 seed는 Ground 45초, Planetary 40초, Galactic 35초다. Black Hole은 별도 Stage가 아니라 마지막 Galactic Stage의 Lv14 Snowball 및 맵 기믹이다.
`clear_score`는 마지막 Stage를 제외한 Stage별 데이터다. 최고 공은 생성 즉시 Clear되므로, 최고 공보다 한 단계 낮은 Cashout 가능 공 점수의 4배를 초기값으로 사용한다. Ground는 Giant Snowball(`1e6`) 기준 `4e6`, Planetary는 Supernova(`5e17`) 기준 `2e18`이다. 마지막 Galactic Stage는 `clear_score`를 판정에 사용하지 않으며 데이터 기본값은 `0`이다.
둘 다 플레이테스트 전 확정값이 아니다.

초기 구현에는 Stage 시간 cap을 넣지 않는다.

---

## 2. 점수 Source of Truth

모든 점수 이벤트에서:

```text
stage_score += amount
run_score += amount
```

- `stage_score`: 현재 Stage 표시와 clear 판정용 부분합
- `run_score`: 전체 Run 누적 합

Stage 종료 시 `run_score += stage_score`를 다시 수행하지 않는다.

---

## 3. 일반 Active Cashout

공이 Score Zone을 통과하면:

```text
cashout_score = calculate_cashout_score(ball)
local_level = ball.global_level - stage.base_global_level
time_bonus = stage.time_bonus_by_local_level[local_level]

stage_score += cashout_score
run_score += cashout_score
stage_time_left += time_bonus
remove_ball_without_settlement()
```

Active Cashout 전용 item modifier는 `calculate_cashout_score()`에서만 적용한다.
Time Bonus 계산과 섞지 않는다.

UI 예:

```text
+50B
TIME +1.0s
```

---

## 4. Physics Tick 순서와 종료 우선순위

한 physics tick은 다음 순서로 처리한다.

```text
1. stage_time_left -= delta
2. 이동 / 충돌 / Merge 처리
3. 이번 tick의 Merge 확정 및 Top Ball 여부 기록
4. 이번 tick의 Active Cashout Score / Time Bonus 반영
5. 종료 판정
   - Top Ball 생성 → TOP_BALL_CLEAR
   - 아니고 stage_time_left <= 0 → TIME_UP
   - 그 외 → PLAYING
```

따라서 시간이 잠시 0 이하가 되어도 같은 tick의 Cashout으로 양수가 되면 Time Up을 취소하고 계속 플레이한다.
같은 tick에 Top Ball 생성과 Time Up 조건이 모두 있으면 Top Ball Clear가 우선한다.

---

## 5. Top Ball Clear

현재 Stage 최고 `global_level` 공이 생성되면:

1. `stage_clear_decided(reason = TOP_BALL)`
2. `CLEAR_LOCKED`
3. Spawn / Timer / gameplay 정지
4. 일반 CUT-IN 중복 억제
5. Final Settlement
6. `stage_clear_completed`
7. 다음 Stage면 Scale Shift, 마지막 Stage면 Result

점수컷은 보지 않는다. 생성된 Top Ball도 Settlement snapshot과 점수에 포함한다.

---

## 6. Time Up

tick의 Cashout까지 반영한 뒤 `stage_time_left <= 0`이고 Top Ball이 생성되지 않았다면:

1. `TIME_UP_LOCKED`
2. Spawn / Input / gameplay 정지
3. Final Settlement
4. 마지막 Stage가 아니면 `stage_score >= clear_score` 판정
5. 성공 → `CLEARED` → Scale Shift
6. 실패 → `FAILED` → Run End
7. 마지막 Stage → Result

---

## 7. Final Settlement

Settlement는 일반 Cashout과 다른 전용 경로다.

```text
SETTLING 진입
→ active ball index snapshot
→ snapshot 공 settlement_reserved/deactivated
→ settlement_score = 각 공의 base score_value 합
→ stage_score += settlement_score
→ run_score += settlement_score
→ 공 제거
→ settlement_applied = true
→ 정산 연출
```

금지:

- Time Bonus
- Active Cashout 전용 modifier
- 추가 Merge
- 일반 Cashout 함수 호출
- `run_score += stage_score`
- Settlement 중복 적용
- 활성 공마다 무거운 씬/Tween 생성

---

## 8. Stage 상태

```text
READY
PLAYING
CLEAR_LOCKED
TIME_UP_LOCKED
SETTLING
CLEARED
SHIFTING
FAILED
FINISHED
```

Stage 진입 시:

```text
stage_score = 0
stage_time_left = stage.base_time
settlement_applied = false
```

`run_score`, 통계, 최고 기록은 유지한다.

---

## 9. 코어와 선택 아이템 경계

코어 게임:

- Merge
- Cashout
- Time Bonus
- Stage Timer
- Settlement
- Scale Shift

선택 아이템 계층:

- Blizzard
- Fire Core
- Magnet

선택 아이템을 제거해도 이 Task의 코어 상태 흐름과 Settlement 규칙은 바뀌지 않아야 한다.

---

## 10. 검증

### Cashout 회복

- tick 시작 시 시간이 0 이하가 되어도 같은 tick의 Cashout으로 양수가 되면 PLAYING 유지
- Local Lv0 Cashout은 시간을 늘리지 않음
- Local Lv1/Lv2가 Stage 데이터의 시간만큼 증가

### 종료 우선순위

- 같은 tick의 Top Ball + Time Up → Top Ball Clear
- Top Ball 생성 후 추가 Cashout/Merge가 Stage 상태를 바꾸지 않음

### Settlement

- snapshot의 기본 점수 합산
- Top Ball 포함
- Time Bonus 0
- Active Cashout 전용 modifier 0
- 재호출해도 점수 추가 0
- Stage Score와 Run Score가 같은 settlement amount만큼 한 번 증가

### Score Clear

- `stage_score >= clear_score` → 성공
- 미달 → 실패
- Stage 종료 시 Run Score에 Stage Score를 다시 더하지 않음

### Time Economy 계측

- 실제 Stage 플레이 시간
- Cashout 총 획득 시간
- 초당 평균 획득 시간
- local level별 Cashout 수
- 종료되지 않는 Stage 발생 여부

---

## 작업 보고

- 사용한 초기 `base_time`, `clear_score`, `time_bonus_by_local_level`
- 정상 Clear / Score Clear / Fail / Cashout 회복 테스트 결과
- 점수 중복과 Settlement 재호출 테스트 결과
- Time Economy 측정값
- 변경 파일
- Codex collaboration log 업데이트


---

## FILE: tasks/03_mass_simulation.md

# Task 03 — Mass Simulation and Spatial Grid

## 목적

공 수가 증가해도 웹에서 실행 가능한 구조로 바꾼다.

---

## 필수 변경

- 공 데이터 SoA 배열
- free index 재사용
- active index 효율적 순회
- Uniform Grid / Spatial Hash
- 같은 레벨 후보만 검사
- 합체 큐
- 디버그 성능 HUD
- 스트레스 테스트 씬 또는 모드

---

## 금지

- 모든 쌍 전수 비교를 남겨두고 단순히 공 수 제한
- 공마다 Node 생성
- Dictionary와 Array를 매 프레임 과도하게 새로 생성
- 성능을 위해 합체 규칙 삭제

---

## 그리드 요구

- 플레이 영역 기준 고정 열/행
- 셀 등록 시 기존 버퍼 재사용
- 자기 셀과 인접 셀만 검사
- 쌍 중복 방지
- 레벨 필터
- 고레벨 큰 공은 필요한 만큼 더 넓은 셀 범위 검사

---

## 측정 항목

```text
FPS
physics_ms
active_balls
spawn_rate
candidate_checks/frame
merges/frame
max_active_balls
```

---

## 스트레스 시나리오

1. 합체 비활성, 기본 공 1,000개
2. 합체 활성, 1,000개
3. 생성량 80/s, 30초
4. 패들 이동·회전 지속
5. 점수 구역에서 대량 제거
6. 재시작 후 메모리와 공 수 정상화

---

## 완료 조건

- 전수 비교 제거
- 1,000개 논리 공에서 데스크톱 30 FPS 이상
- 가능하면 60 FPS 근접
- 웹 빌드 또는 Web Export 테스트 가능
- 반복 생성·제거에서 프레임 스파이크가 지속되지 않음
- 후보 검사 수가 N²보다 현저히 적음
- 결과가 Task 02 규칙과 동일

---

## 최적화 우선순위

1. 불필요한 객체 생성 제거
2. 후보 검사 감소
3. 렌더 배치
4. 업데이트 빈도 분리
5. 저수준 RenderingServer

처음부터 5번으로 가지 않는다.

---

## FILE: tasks/04_stage_shift.md

# Task 04 — Stage Shift

## 목적

게임의 핵심 정체성인 스케일 상승을 구현한다.

---

## 구현 스테이지

1. Ground
2. Planetary
3. Galactic


## 필수 규칙

- 스테이지마다 base_global_level과 top_global_level이 있음
- 최고 공 최초 생성 시 Stage Clear; Settlement 완료 후 다음 스테이지
- 이전 최고 공 = 다음 기본 공
- 생성량 증가
- 화면상 크기 정규화
- StageDefinition의 `visual_radius_scale`로 렌더 크기 보정
- 새 기본 레벨보다 낮은 공 정리
- 좌우 Stage World 배경 전환
- HUD 공 족보를 새 Stage의 local 공 5~6종으로 교체
- Retro Pixel Arcade Machine의 Stage 상태 변화
- `SCALE SHIFT` 발표
- Time Up Score Clear 후에도 동일한 Scale Shift 진입

---

## 초기 데이터

```text
Ground:
base 0, top 4, spawn 6/s

Planetary:
base 4, top 9, spawn 15/s

Galactic:
base 9, top 14, spawn 35/s
```

---

## 전환 순서

1. Stage Clear 결정 (Top Ball 또는 Score Clear)
2. 중복 전환 잠금
3. Final Settlement 완료 확인
4. 시뮬레이션 짧게 감속
5. `SCALE SHIFT`
6. Stage 데이터 변경
8. 렌더 크기 스케일 재설정
9. 배경 전환
10. 새 Stage 공 족보 갱신
11. 새 생성량 적용
12. 시뮬레이션 정상화

---

## 주의

- 최고 공이 생성되자마자 바닥으로 떨어져도 Stage는 전환됨
- 같은 최고 공이 여러 개 생겨도 한 번만 전환
- 전환 중 새 전환 요청 무시
- 전환 후 기존 고레벨 공 인덱스와 정의가 깨지지 않음
- `run_score`, 통계, 최고 기록은 유지
- 새 Stage의 `stage_score`는 0, `stage_time`은 해당 Stage의 `base_time`으로 초기화
- 새 기본 공이 화면상 너무 커 보이지 않게 정규화

---

## 완료 조건

- Ground → Planetary
- Planetary → Galactic
- 배경과 생성량 변화
- 새 기본 공 생성
- 이전 저레벨 공 정리
- Scale Shift 연출
- 강제 전환 디버그 기능
- 재시작 시 Ground로 복귀


---

## 디자인 계약

`DESIGN/02_STAGE_ART_DIRECTION.md`를 따른다.

- Ground는 일부러 소박하고 평화롭게 시작
- Planetary는 천체 규모의 급격한 확대
- Galactic은 화면/계기 밀도 증가
- 후반 기계는 과부하처럼 보여도 실제 HUD와 조작 가독성은 유지
- 이전 최고 공의 화면상 크기는 새 Stage 기준으로 재정규화
- 재정규화는 Stage 데이터가 소유하며 BallDefinition의 물리 반지름을 변경하지 않음

---

## FILE: tasks/05_effects.md

# Task 05 — Effects, Game Feel, and High-Grade CUT-IN

## 목적

일반 머지의 지속적인 포화감과
고등급 이벤트의 짧고 강한 보상을 계층화한다.

반드시 읽기:

- `DESIGN/03_GAMEPLAY_EFFECTS.md`
- `DESIGN/04_CUTIN_SYSTEM.md`

---

## 일반 이벤트 계층

### Tier 0
- 기본 머지
- 작은 눈가루
- 작은 플래시
- 짧은 효과음

### Tier 1
- 중간 머지
- 얼음 파편
- 얇은 링
- 작은 숫자
- 아주 약한 카메라 반응

### Tier 2
- 높은 머지
- 큰 파티클
- 강한 링
- 큰 숫자
- 화면 흔들림
- 저음

### Tier 3
- 중요 고등급 공 / 기록
- 짧은 히트스톱
- CUT-IN 후보
- 특별 사운드

### Tier 4
- SCALE SHIFT
- 일반 CUT-IN과 별도
- Stage 세계/기본 단위/생성량이 실제 변경

---

## 뱀서식 포화 원칙

- 낮은 이벤트는 많이 발생
- 높은 이벤트는 적지만 강함
- 낮은 효과가 높은 효과를 가리지 않음
- 낮은 점수 팝업은 과밀 시 생략 가능
- 사운드 동시 재생 제한
- 실제 공의 외곽선/실루엣은 항상 읽힘

---

## CUT-IN 구현

필수:

- 현재 장면을 그대로 사용
- 전체 16:9 freeze
- 중앙 Play Field + 좌우 Stage World 함께 dim
- 픽셀 기계 패널 진입/체류/퇴장
- 공 이름 / 공 이미지 / VALUE
- 별도 화면 전환 금지

초기 타이밍:

```text
enter 0.10~0.15s
hold  0.20~0.30s
exit  0.10~0.15s
total 0.45~0.70s
```

기본적으로 1초 초과 금지.

---

## 남발 방지

- cooldown
- 한 판에 이미 보여준 공 레벨 추적
- 이벤트 priority
- 낮은 이벤트 큐 누적 금지
- Scale Shift 우선

---

## CUT-IN 시각

사용:

- chunky pixel frame
- beige / gray / metal
- bolts
- retro numbers
- ball sprite

금지:

- 현대 검정/빨강 액션 배너
- 고해상도 캐릭터 일러스트
- 긴 설명문

---

## 완료 조건

- 일반 머지가 계속 터져도 공 식별 가능
- 고등급 이벤트가 명확히 더 강함
- CUT-IN이 현재 게임 화면 위에서 동작
- CUT-IN 길이가 목표 범위
- 연속 이벤트에서 CUT-IN 폭주 없음
- CUT-IN 종료 후 입력/시뮬레이션 정상
- Scale Shift와 충돌 시 Scale Shift 우선
- 웹 빌드에서 Tween/Animation 정상
- 연출 후에도 성능 게이트 유지


---

## Cashout / Settlement 연출

일반 고등급 Cashout:

- Score popup
- `TIME +Xs`
- 필요 시 Tier 3 반응

Time Up 또는 Stage Clear Settlement:

- 활성 공들이 점수판/중앙으로 빠르게 수렴하는 표현
- Stage Score 카운트업
- Time Bonus popup 금지
- 공 수가 많으면 개별 Tween 대신 배치/샘플링 연출

Stage 최고 공은 일반 CUT-IN보다 Stage Clear / Scale Shift 연출을 우선한다.

---

## FILE: tasks/06_items.md

# Task 06 — Items

## 목적

현재 Stage의 3단계 이상 Snowball로 아이템 행성을 여러 번 깨뜨려 획득하는 짧은 폭발 구간과 뇌절 변형을 만든다.

---

## 공통 규칙

- 아이템은 작은 행성 형태의 `Item Ball`에 담겨 Play Field에 등장
- Item Ball은 일반 Snowball Merge 대상이 아님
- 현재 Stage의 3단계 이상 공만 파괴 damage를 줄 수 있음
- 데이터 기준으로 `local_level >= 2`; 그보다 높은 local level도 모두 유효
- 유효 Snowball 충돌마다 damage 1회와 균열/픽셀 파편 단계 갱신
- 동일 contact가 여러 physics frame에 걸쳐도 분리 전에는 중복 damage 없음
- `required_break_hits` 도달 시 파괴·획득 lock을 한 번만 확정
- 파괴 CUT-IN의 activation cue에서 아이템 효과 시작
- CUT-IN 실패/skip 시에도 확정된 아이템은 안전하게 한 번 적용
- 1~2단계 공과 Paddle은 즉시 획득 또는 파괴하지 않음
- 놓치면 제거
- 지속 효과는 HUD 표시
- 같은 효과 재획득 시 지속시간 갱신
- 다른 효과 동시 유지 가능
- 파괴 연출 실패나 지연이 실제 아이템 적용을 중복시키지 않음

---

## 1. Blizzard

```text
duration: 5s
spawn multiplier: ×3
```

연출:

- `BLIZZARD!`
- 장식 눈 증가
- 생성음 가속

완료 조건:

- 정확히 지속시간 동안 생성량 증가
- 종료 후 원래 Stage 생성량 복원
- 중첩 곱셈 버그 없음

---

## 2. Fire Core

```text
duration: 8s
cashout multiplier: ×10
```

- 패들이 불꽃 상태
- 닿은 공이 Fire 특성
- Fire + Normal 같은 레벨 합체 가능
- 결과는 Fire
- Fire + Fire도 Fire
- 눈+불 파티클
- ×10은 Active Cashout 전용 modifier
- Final Settlement에는 적용하지 않음
- Time Bonus에는 적용하지 않음

완료 조건:

- 특수 타입 렌더
- 점수 배수
- 합체 전파
- 지속시간 종료 후 새로 맞는 공은 Normal 유지
- 기존 Fire 공은 Fire 유지

---

## 3. Magnet

```text
duration: 7s
```

- 같은 레벨 인접 공끼리 약한 흡인
- Spatial Grid 후보 사용
- 최대 힘 제한
- 패들 조작을 무시할 정도로 강하지 않음

완료 조건:

- 연쇄 합체 증가가 체감
- N² 계산 없음
- 공이 한 점에 영구 정체되지 않음

---

## 아이템 행성 스폰

초기:

```text
첫 아이템: 게임 시작 15~25초
이후: 12~20초 랜덤
```

Stage가 오르면 약간 자주 나올 수 있다.

행성의 정확한 `required_break_hits`, 낮은 단계 공과의 물리 반응, 등장 궤적은 아직 확정하지 않는다. 파괴 가능 여부는 고정 global level이 아니라 현재 Stage 기준 `local_level >= 2`로 계산한다.

---

## 디버그

키로 각 아이템 강제 활성화 가능.  
릴리스에서는 제거 또는 개발 플래그로 숨김.


---

## 아이템 CUT-IN

강한 아이템/특수 속성의 첫 적용에는 짧은 CUT-IN을 사용할 수 있다.

예:

```text
FIRE SNOWBALL
[ burning pixel snowball ]
CASHOUT ×10
```

모든 아이템 획득마다 강제로 띄우지 않는다.
일반 공 고등급 CUT-IN과 동일한 cooldown/priority 시스템을 사용한다.

---

## FILE: tasks/07_black_hole.md

# Task 07 — Galactic Black Hole Map Gimmick

## 목적

마지막 Galactic Stage의 물리 규칙을 바꿔 기존 조준법을 흔든다. 이 Task의 이동 블랙홀은 Lv14 `Black Hole` Snowball과 별개의 맵 기믹이다.

---

## 스테이지 데이터

```text
base_global_level: 9
top_global_level: 14
spawn_rate: 35/s
black_hole_enabled: true
```

공:

```text
Galaxy
Galaxy Cluster
Supercluster
Quasar
Event Horizon
Black Hole
```

`Black Hole`은 이 Stage의 Lv14 최고 Snowball이다. `black_hole_enabled`는 상단 이동 블랙홀 맵 기믹의 활성 여부를 뜻하며, Snowball의 생성·등급과는 별개다.

---

## 블랙홀 이동

- 화면 상단에서 좌우 왕복
- 사인파 또는 부드러운 Tween
- 이동 속도와 범위는 Stage 데이터
- 논리 위치와 시각 중심 일치

---

## 인력

모든 활성 공에 약한 가속도.

요구:

- 거리에 따라 강해짐
- 최소 거리와 최대 힘 제한
- 패들 반사 후에도 영향
- 공이 경계 밖으로 영구 이탈하지 않음

게임용 근사치 사용.

---

## 게임 감각

- 블랙홀이 왼쪽이면 궤도가 왼쪽으로 휨
- 이동하면서 공 무리가 따라 움직임
- 같은 레벨이 모여 연쇄 합체 가능
- 높은 공을 의도한 곳에 보내기 어려워짐
- 혼돈이지만 패들 조작은 여전히 의미 있음

---

## 시각

우선순위:

1. 회전 링과 별 파티클
2. 곡선 잔상
3. 저음 환경음
4. 가능하면 화면 왜곡 셰이더

셰이더가 일정에 부담이면 생략 가능하다.

---

## 완료 조건

- 블랙홀 위치에 따라 공 궤도가 명확히 변함
- 중력이 강해도 게임이 계속 진행
- 공이 블랙홀에 영구 고정되지 않음
- Galactic 최종 국면의 생성량에서 성능 확인
- Black Hole 생성과 결과 화면 정상


---

## Stage 디자인

`DESIGN/02_STAGE_ART_DIRECTION.md`를 따른다.

- 좌우 Stage World에서 거대한 블랙홀을 표현
- 회전 링 / 별 왜곡 / 우주 먼지
- 아케이드 기계는 과부하 상태처럼 보임
- 계기 글리치는 장식이며 실제 HUD 가독성을 깨지 않음
- 논리 블랙홀 위치와 시각 중심은 가능한 한 일치

---

## FILE: tasks/08_web_export_release.md

# Task 08 — Web Export and Release Candidate

## 목적

공식 Track 1 필수 조건인 **브라우저 직접 실행 Web Build**를 Release Candidate 수준으로 만든다.

---

## 선행 읽기

- `08_HACKATHON_REQUIREMENTS.md`
- `SUBMISSION/00_OFFICIAL_REQUIREMENTS.md`
- `SUBMISSION/06_RELEASE_CHECKLIST.md`

---

## 정식 게임 흐름

1. Title
2. 즉시 읽히는 조작 안내
3. Start
4. Stage별 제한 시간 기반 플레이
5. Result
6. Retry

로그인, 계정 생성, 별도 승인은 넣지 않는다.

---

## 타이틀 안내

```text
A / D        MOVE
← / →        TILT
MERGE SAME-LEVEL BALLS
DROPPED BALLS BECOME SCORE
```

첫 플레이어가 10초 안에 이해할 수 있어야 한다.

---

## Web Export 필수 확인

Release export 전에 [`../team/GODOT_MCP_SETUP.md`](../team/GODOT_MCP_SETUP.md)의 **Web Export Hygiene / Web Export 주의사항** 절차에 따라 MCP bridge를 종료하고 이전 산출물을 clean한다. MCP가 실행 중인 상태에서 생성한 build는 release 기준 build로 사용하지 않는다.

- Godot Web preset
- public static hosting
- 심사기간 유지 가능한 URL
- 별도 설치 없음
- 별도 접근 승인 없음
- 첫 입력 후 오디오 시작
- 키보드 포커스
- 화면 비율 유지
- 브라우저 resize
- 상대 asset 경로
- 브라우저 console fatal error 없음

최소 Chrome/Edge에서 검사한다. 가능하면 Firefox도 검사한다.

---

## 약 3분 Stage 기반 Release Candidate 조건

- 전체 세션 종료 가능
- 최소 두 번의 Scale Shift가 일반 플레이로 보일 수 있게 밸런스 조정
- 고레벨 점수 formatter 정상
- late-game density에서도 플레이 가능
- 결과 화면에 score / highest stage / highest ball 표시
- Retry가 모든 gameplay state를 초기화

---

## Public-link 검증

반드시 개발 환경이 아닌 조건에서 확인한다.

1. 새 시크릿/Incognito 창
2. 링크 직접 입력
3. 캐시 없는 상태로 load
4. Start
5. 실제 키 입력
6. 한 판 완주
7. Retry
8. browser console 확인

가능하면 다른 PC 또는 다른 네트워크에서도 확인한다.

---

## 완료 조건

- 공식 제출 링크로 사용해도 되는 public build
- Stage 기반 한 판 완주
- result + retry
- 치명 console error 없음
- no login / no approval
- controls visible
- late-game performance acceptable
- `SUBMISSION/06_RELEASE_CHECKLIST.md`의 Web 관련 항목 완료

---

## 이번 Task에서 하지 않는 것

- 데모 영상 편집
- 200자 소개 최종 입력
- 썸네일 제작
- Codex 제출 설명 문안 확정

이것들은 `tasks/09_submission_package.md`에서 처리한다.

---

## FILE: tasks/09_submission_package.md

# Task 09 — Submission Package

## 목적

안정된 Release Candidate를 공식 Track 1 제출물로 패키징한다. 이 Task는 기능 개발 Task가 아니다.

---

## 선행 조건

- `tasks/08_web_export_release.md` 완료
- public URL 안정화
- 큰 기능 추가 중지

---

## 작업

### 1. 200자 소개

`SUBMISSION/03_SUBMISSION_COPY.md`에서 하나를 선택하고 실제 폼에서 200자 제한을 재확인한다.

### 2. Thumbnail

- 16:9
- JPG/PNG
- 10 MB 이하 권장
- Snowball Effect의 게임 화면임이 즉시 보이는 구도
- late-game cosmic scale + paddle + falling objects + title 권장

### 3. Demo video

- 최대 3분
- 실제 플레이 필수
- `SUBMISSION/04_DEMO_VIDEO_SCRIPT.md` 사용
- Scale Shift를 반드시 보여준다.
- 깨진 선택 기능은 영상에서 제외한다.

### 4. Codex collaboration description

- `SUBMISSION/02_CODEX_COLLAB_LOG.md`의 실제 기록만 사용
- 어디에 사용 / 구현 기능 / 해결 문제 / 사람이 직접 결정한 부분을 구분
- fabricated metric 금지

### 5. Final-form verification

- public URL 다시 확인
- thumbnail
- intro
- optional video URL
- Codex write-up

---

## 완료 조건

- `SUBMISSION/06_RELEASE_CHECKLIST.md`의 Submission Form 섹션 완료
- public URL은 제출 직전에도 incognito에서 실행됨
- 새 기능을 추가하지 않고 제출 가능

---

## FILE: SUBMISSION/README.md

# SUBMISSION

공식 Track 1 제출과 본선 발표를 위한 문서다.

읽는 순서:

1. `00_OFFICIAL_REQUIREMENTS.md`
2. `01_JUDGING_STRATEGY.md`
3. 개발 중 `02_CODEX_COLLAB_LOG.md` 유지
4. 제출 시 `03_SUBMISSION_COPY.md`
5. `04_DEMO_VIDEO_SCRIPT.md`
6. 본선 진출 시 `05_FINAL_PITCH.md`
7. 항상 `06_RELEASE_CHECKLIST.md`
8. 일정은 `07_INTERNAL_TIMELINE.md`

공식 사이트가 변경되면 https://openaigame2026.com/ 이 문서보다 우선한다.

---

## FILE: SUBMISSION/00_OFFICIAL_REQUIREMENTS.md

# Official Submission Snapshot

Verified against https://openaigame2026.com/ on 2026-08-07.

## Track 1

- Submission: 2026-08-04 to 2026-08-26
- Judging: 2026-08-27
- Finalists announced / contacted: 2026-08-28 to 2026-08-30
- Offline final: 2026-08-31, Seoul
- Team: up to 3 people
- Team final attendance: one representative
- Final Track 1 elevator pitch: max 3 minutes

## Required

- playable prototype
- core play must be fun
- browser-direct web build
- playable public link
- accessible during judging
- no separate approval required
- controls / execution instructions
- existing projects are allowed, but newly developed challenge-period work must be identified
- title
- game intro <= 200 characters
- thumbnail, recommended 16:9 JPG/PNG and <= 10 MB

## Optional bonus

- demo video <= 3 minutes with actual gameplay
- explanation of how Codex was used

## Judging

1. Playability
2. Originality
3. Codex Collaboration
4. Release Potential
5. Presentation

## Important interpretation for this project

- Web Export is a hard gate, not polish.
- The Codex process should be logged during development.
- Hive expansion is a judging narrative / future release angle; the prototype page does not state that Hive integration itself is mandatory.
- Do not let optional systems delay a stable public build.

---

## FILE: SUBMISSION/01_JUDGING_STRATEGY.md

# Judging Strategy — Snowball Effect

This file translates each official judging criterion into a concrete feature and evidence plan.

---

## 1. Playability

### What judges should feel

Within 10 seconds:

> I understand how to move, tilt, bounce, merge, and score.

Within 60 seconds:

> I can intentionally aim toward another same-level ball.

Within one run:

> The game visibly escalates and ends cleanly.

### Must-have evidence

- one-click public web link;
- no login;
- concise control overlay;
- predictable reflection;
- merge correctness;
- no deadlock / softlock;
- complete stage-based run;
- result + retry;
- browser performance metrics.

### Kill conditions

Do not ship if:

- the paddle sometimes misses obvious contacts;
- the ball gets trapped indefinitely;
- Scale Shift can fail due to duplicate state;
- the browser build crashes late game;
- restart leaves old state behind.

---

## 2. Originality

Do not pitch the game as merely:

> Breakout + Suika.

Pitch the signature loop:

> Every time you reach the top of a scale, yesterday's ultimate object becomes today's basic falling particle. The playfield, spawn density, score, background, and eventually physics all snowball together.

### Originality proof sequence

Show this in the demo video:

```text
Snowflake
  ↓ merge
Giant Snowball
  ↓ SCALE SHIFT
Giant Snowballs now fall as the basic unit
  ↓
Earth / Solar
  ↓ SCALE SHIFT
Solar units rain across a galactic background
  ↓
Black Hole gravity bends the whole field
```

The important reveal is the **unit re-baselining**, not just bigger sprites.

---

## 3. Codex Collaboration

The strongest evidence is a before → Codex task → verified result chain.

Good entries:

- initial Godot scene bootstrap;
- custom paddle reflection debugging;
- merge duplicate bug;
- N² merge prototype → Spatial Grid optimization;
- Web Export bug and fix;
- performance profiling;
- scene integration issue;
- test/debug tooling.

Each log entry should capture:

1. problem or goal;
2. prompt / task document;
3. Codex contribution;
4. human decision;
5. verification;
6. result / metric.

A long prompt history without verification is weak evidence.

---

## 4. Release Potential

The prototype should already contain the seeds of a releasable arcade loop:

- 3-minute session;
- score;
- highest stage;
- highest generated / cashed-out ball;
- Retry;
- visually shareable result.

Future release path, only as a pitch:

```text
Web prototype
→ daily challenge / fixed seed
→ leaderboard and achievements
→ account / cross-device progression
→ seasonal modifiers
→ Hive-backed release services if appropriate
```

Do not implement speculative backend work before the browser game is stable.

---

## 5. Presentation

Three presentation surfaces should tell the same story.

### Thumbnail

Show:

- paddle at bottom;
- dense falling snowballs;
- one obviously huge celestial snowball;
- cosmic background / scale contrast;
- readable `SNOWBALL EFFECT` title.

Avoid a thumbnail that looks like a generic snow scene.

### 3-minute demo video

Show actual play first. Explain later.

### Final 3-minute pitch

Structure:

1. What is it? — 20 sec
2. What is the mechanic? — 40 sec
3. What is the Snowball Effect twist? — 60 sec
4. How Codex helped build it — 30 sec
5. Why it can grow beyond the prototype — 20 sec
6. Finish on the strongest live visual — 10 sec

---

# One-line judging strategy

**Protect playability first, make the Scale Shift impossible to miss, and document real Codex problem-solving as carefully as the code itself.**


---

## Presentation / Visual Identity

발표와 영상에서는 초반 Ground와, Lv14 Black Hole Snowball 및 이동 블랙홀 맵 기믹이 있는 후반 Galactic을 반드시 대비시킨다.

시각 한 줄:

> Retro Pixel Arcade Machine × Cosmic Escalation

보여줄 핵심:

- 중앙 세로 Play Field와 좌우 Stage World
- 이전 최고 공이 다음 Stage의 기본 공이 되는 Scale Shift
- 점점 과부하되는 픽셀 아케이드 기계
- 일반 머지는 포화형 FX, 중요 이벤트는 1초 미만 CUT-IN
- 후반에도 실제 공과 패들 조작이 읽히는 Readable Chaos


---

## Updated Core Loop — Greed vs Cashout

Snowball Effect의 플레이어 선택은 단순 머지가 아니다.

- 높은 공을 계속 살리면 다음 머지로 점수가 폭발할 수 있다.
- 지금 Cashout하면 현재 점수와 추가 시간을 얻는다.
- Stage 최고 공은 즉시 Clear.
- 시간이 끝나면 화면 공까지 Score-only Final Settlement.
- 목표 점수를 넘기면 Score Clear.

이 구조를 Originality / Playability 설명의 핵심으로 사용한다.

---

## FILE: SUBMISSION/02_CODEX_COLLAB_LOG.md

# Codex Collaboration Log

> This is an evidence log, not marketing copy.
> Record only work that actually happened in Codex.
> Do not backfill imagined sessions.

---

## How to use

Create one entry for a meaningful Codex task or problem-solving episode.
Small autocomplete-style changes do not need individual entries.

Recommended evidence to preserve when practical:

- prompt or referenced task file;
- branch / commit SHA after the change exists;
- screenshot of before/after or debug output;
- performance metric;
- error message that was solved.

---

## Entry template

### YYYY-MM-DD — Short task name

**Goal / problem**

- What needed to be built or fixed?

**Context given to Codex**

- Files or task document:
- Important constraints:

**What Codex did**

- Implementation:
- Diagnosis:
- Tests / checks suggested or executed:

**What the human decided**

- Gameplay decisions:
- Architecture decisions accepted / rejected:
- Manual changes, if any:

**Verification**

- Scenario tested:
- Result:
- Metric before:
- Metric after:

**Artifacts**

- Commit / diff:
- Screenshot / video:
- Relevant log:

**Why this is meaningful collaboration**

- One or two sentences.

---

# Summary table

Fill this as work progresses.

| Date | Task | Codex contribution | Human decision | Verified result | Evidence |
|---|---|---|---|---|---|
| 2026-08-09 | v1.4 규칙 계약·Goal 재구성·S0-G1 | 충돌 문구 정리, Goal/Gate 분해, Godot 부트 파일 작성 | tick 순서, Top Ball 우선, score source, item 분리 확정 | 정적 검사 7/7; Godot 런타임 미검증 | working tree diff, `docs/goals/STATUS.md` |

---

# Submission-answer scratchpad

Use actual entries above to answer these official prompts later.

## Where was Codex used?

TBD from actual logs.

## What features did Codex implement?

TBD from actual logs.

## What problems did Codex solve?

TBD from actual logs.

## What did the developer decide or implement directly?

Core design decisions already defined by the human include, unless later changed:

- A/D movement + arrow-key tilt control scheme;
- dropped balls are score, not failure;
- intentionally explosive score scaling;
- previous stage ultimate becomes next stage base unit;
- stage-by-stage density escalation;
- Black Hole as a late-stage global trajectory modifier;
- game-feel priority over realistic physics.

Do not describe future Codex work as completed.

---

> **Append-only log.** 새 개발 작업은 아래에 시간순으로 추가한다. 이전 기록을 덮어쓰지 않는다. 실제로 수행·검증한 내용만 기록한다.

### 2026-08-09 — v1.4 규칙 계약과 Goal 재구성, S0-G1 부트스트랩

**Goal / problem**

- v1.4 문서에 남은 Stage Timer, Top Ball, Settlement, Score 누적 충돌을 제거하고 구현 단위를 검증 가능한 Goal로 바꾼다.
- 첫 Goal인 Godot 프로젝트 부트 파일을 만든다.

**Context given to Codex**

- Files or task document: `SnowballEffect_Codex_Context_v1.4.zip`, 대화에서 합의한 최종 상태 흐름.
- Important constraints: Cashout same-tick time rescue, Top Ball priority, Settlement base score/idempotence, `run_score += stage_score` 금지, Core/Optional item 분리.

**What Codex did**

- Implementation: 현재 문서를 `docs/current/`로 정리하고 루트 문서 규칙을 갱신했다. S0~S9를 독립 Goal과 Quality Gate로 재구성했다. `project.godot`과 최소 Main 씬을 작성했다.
- Diagnosis: 구버전 경로, 고정 180초 표현, BallDefinition Time Bonus, Top Ball 즉시 Shift 표현, 중복 번호와 실행 상태 중복 관리 위험을 확인했다.
- Tests / checks suggested or executed: 프로젝트 파일 존재, Main 경로, 1600×900, Godot 4 config/scene format, Main root를 PowerShell로 검사해 7/7 통과했다.

**What the human decided**

- Gameplay decisions: physics tick 종료 판정 순서와 Cashout 구조, Top Ball 우선순위, Stage별 Timer/Time Bonus를 최종 계약으로 확정했다.
- Architecture decisions accepted / rejected: stage/run score를 이벤트마다 함께 누적하고 Stage 종료 재합산을 금지했다. Fire를 Cashout-only optional modifier로 격리했다.
- Manual changes, if any: 없음.

**Verification**

- Scenario tested: 설정 파일과 씬 참조의 정적 일관성 검사.
- Result: 7/7 통과. PATH와 일반 설치 위치에서 Godot 실행 파일을 찾지 못해 엔진 parse/run 및 Web smoke는 수행하지 못했다.
- Metric before: 구현 프로젝트 파일 없음.
- Metric after: 최소 Godot 프로젝트 파일 2개와 생성물 제외용 `.gitignore` 존재.

**Artifacts**

- Commit / diff: 아직 commit하지 않은 working tree 변경.
- Screenshot / video: 없음.
- Relevant log: `docs/goals/STATUS.md`의 S0-G1 Evidence.

**Why this is meaningful collaboration**

- 구현 전에 상태 전이와 점수 소유권 충돌을 실행 가능한 테스트 계약으로 바꾸고, 검증되지 않은 런타임 결과를 완료로 주장하지 않은 첫 개발 단위다.

---

## FILE: SUBMISSION/03_SUBMISSION_COPY.md

# Submission Copy Drafts

These are editable drafts. Verify character limits in the live form before submission.

---

## Game title

**Snowball Effect**

---

## Korean game introduction — primary

> 작은 눈송이를 패들로 튕겨 같은 단계끼리 합치세요. 거대 눈덩이에서 행성·은하·블랙홀까지 스케일이 폭주하고, 이전 스테이지의 최고 공은 다음 스테이지의 기본 공이 되어 더 거대한 눈사태를 만듭니다.

Current draft length: **110 characters** by Python `len()` counting. Re-check in the live form before submission.

---

## Shorter fallback

Current draft length: **95 characters** by Python `len()` counting.

> 눈송이를 튕겨 합치고 우주까지 키우는 2D 액션 머지 게임. 최고 단계 공은 다음 세계의 기본 공이 되어 더 많이 쏟아지고, 점수와 화면과 물리까지 눈덩이처럼 폭주합니다.

---

## One-line pitch

> 어제의 최종보스가 오늘의 눈송이가 되는 액션 머지 게임.

Alternative:

> 눈송이 하나에서 시작해 게임 전체가 우주 규모로 눈덩이처럼 커지는 3분 아케이드.

---

## Controls copy

```text
A / D        MOVE
← / →        TILT
MERGE SAME-LEVEL BALLS
DROPPED BALLS BECOME SCORE
```

Korean alternative:

```text
A / D        패들 이동
← / →        패들 기울이기
같은 공끼리 합체
놓친 공은 점수가 됩니다
```

---

## Core-feature bullets for video / page

- Move and tilt the paddle to aim rebounds.
- Merge equal-level snowballs into absurdly larger objects.
- Cash out falling balls for exponentially escalating score.
- Trigger `SCALE SHIFT`: the previous ultimate ball becomes the next stage's basic falling unit.
- Survive a playfield that escalates from snowfall to planetary rain to black-hole gravity.

---

## Release-potential copy

> Snowball Effect is designed as a short replayable browser arcade game. Score, highest stage, daily challenge rules, achievements, and leaderboards can extend the same three-minute loop into a competitive live service, with platform services such as Hive considered for a later release phase.


---

## Updated Core Loop — Greed vs Cashout

Snowball Effect의 플레이어 선택은 단순 머지가 아니다.

- 높은 공을 계속 살리면 다음 머지로 점수가 폭발할 수 있다.
- 지금 Cashout하면 현재 점수와 추가 시간을 얻는다.
- Stage 최고 공은 즉시 Clear.
- 시간이 끝나면 화면 공까지 Score-only Final Settlement.
- 목표 점수를 넘기면 Score Clear.

이 구조를 Originality / Playability 설명의 핵심으로 사용한다.

---

## FILE: SUBMISSION/04_DEMO_VIDEO_SCRIPT.md

# <= 3 Minute Demo Video Script

Target length: **2:20 to 2:50**. Do not use the full three minutes unless the material earns it.

Actual gameplay should dominate the video.

---

## 0:00–0:08 — Hook

Visual:

- late-game screen first;
- huge celestial ball;
- score explosion;
- quick cut to title.

Text / VO:

> 눈송이 하나가 우주를 망가뜨릴 때까지 키워봅니다. Snowball Effect입니다.

---

## 0:08–0:28 — Explain in one play sequence

Show actual input overlay.

- A/D move;
- arrow keys tilt;
- hit a ball;
- intentionally aim it into an equal ball;
- merge.

VO:

> 패들은 좌우로 움직이고 각도를 따로 조절합니다. 같은 단계의 공을 서로 맞히면 더 큰 공으로 합체합니다.

---

## 0:28–0:45 — Cash-out and insane scoring

Show a ball falling below paddle and being scored.

VO:

> 놓친 공은 목숨을 깎지 않습니다. 지금 현금화할지 더 튕겨서 훨씬 큰 단계로 만들지 선택합니다. 점수는 2배가 아니라 100배, 1,000배씩 폭주합니다.

---

## 0:45–1:20 — Signature Scale Shift

This is the most important sequence.

Show:

1. Ground top ball created;
2. hit-stop / `SCALE SHIFT`;
3. background zoom / change;
4. that former top ball starts falling as the new base unit;
5. spawn density rises.

VO:

> 핵심은 Scale Shift입니다. 방금 어렵게 만든 최고 단계 공이 다음 스테이지에서는 기본 눈송이처럼 쏟아집니다. 공의 크기만이 아니라 세계의 기준 자체가 계속 커집니다.

---

## 1:20–1:45 — Escalation montage

Quick actual-play cuts:

- Planetary;
- Galactic;
- denser field;
- large score popups;
- high-tier merge effect.

Minimal VO:

> 그래서 한 판 안에서 화면 밀도, 배경, 점수, 이펙트가 같이 눈덩이처럼 커집니다.

---

## 1:45–2:05 — Black Hole / optional item highlight

If Black Hole is stable, show gravity bending a trajectory.

VO:

> 후반에는 블랙홀이 움직이며 모든 공의 궤도를 휘게 해, 처음 배운 조준법 자체를 흔듭니다.

If Black Hole is not stable, replace this section with Fire Core or another polished feature. Never show a broken feature for scope credibility.

---

## 2:05–2:25 — Codex collaboration

Do not switch to a long coding screencast.

Use 2–3 quick overlays:

- a task markdown;
- a Codex implementation / debug moment;
- performance metric before/after.

VO template:

> 개발은 기능을 작은 작업 문서로 나눠 Codex와 반복했습니다. 예를 들어 [actual feature] 구현과 [actual bug/performance issue] 해결에 Codex를 사용했고, 조작 방식과 Scale Shift 같은 핵심 게임 규칙은 직접 결정했습니다.

Fill only with actual logged work.

---

## 2:25–2:40 — Result / release loop

Show result panel:

- score;
- highest stage;
- highest ball;
- Retry.

VO:

> 한 판은 3분. 점수와 최고 스테이지를 갱신하며 바로 다시 도전할 수 있습니다.

---

## 2:40–2:50 — Final image

Return to strongest late-game moment.

Text:

```text
SNOWBALL EFFECT
Build small. End cosmic.
```

No long credits inside the main 3-minute demo.

---

## FILE: SUBMISSION/05_FINAL_PITCH.md

# Track 1 Final — 3 Minute Pitch Draft

The final event specifies a maximum three-minute elevator pitch. This script is designed to be spoken while the game is already open and ready.

Do not spend pitch time launching the build or typing a URL.

---

## 0:00–0:20 — Hook

> Snowball Effect는 작은 눈송이 하나가 게임 전체를 우주 규모까지 키워버리는 3분 액션 머지 게임입니다. 브레이크아웃처럼 튕기고, 같은 단계끼리 합치지만, 핵심은 공 하나가 아니라 세계의 기준 자체가 계속 커진다는 점입니다.

Show normal early play immediately.

---

## 0:20–0:55 — Control and decision

> A와 D로 패들을 이동하고, 방향키로 각도를 따로 조절합니다. 그래서 어느 공을 받을지와 어디로 튕길지를 동시에 결정합니다. 같은 단계의 공을 맞히면 합체하고, 아래로 떨어진 공은 실패가 아니라 점수가 됩니다. 지금 점수로 바꿀지, 계속 튕겨 더 큰 단계로 만들지가 플레이의 선택입니다.

Demonstrate one intentional merge and one cash-out.

---

## 0:55–1:45 — Signature mechanic

> 그리고 이 게임의 이름 그대로 Snowball Effect가 시작됩니다. 현재 스테이지의 최고 공을 만들면 Scale Shift가 일어납니다. 방금까지 어렵게 만들던 최고 공이 다음 세계에서는 기본 공이 되어 위에서 쏟아집니다. 생성량도 늘고, 점수는 수백 배씩 뛰고, 초원은 행성과 은하 규모로 바뀝니다.

Trigger or show a prepared Scale Shift.

> 결국 처음의 작은 눈송이가 행성, 은하, 블랙홀까지 이어집니다. 후반에는 블랙홀이 움직이며 공의 궤도까지 휘게 만들어 플레이 규칙도 함께 변합니다.

---

## 1:45–2:15 — Codex collaboration

Replace brackets from the real collaboration log.

> 이 프로젝트는 작업을 기능별 Markdown으로 쪼개 Codex와 반복 개발했습니다. Codex는 [actual implemented feature]를 구현하고, [actual problem]을 진단해서 [verified result]까지 확인하는 데 활용했습니다. 반대로 이동과 각도를 분리한 조작, 점수가 폭발적으로 증가하는 방식, 그리고 이전 최고 공이 다음 기본 공이 되는 Scale Shift는 직접 설계한 게임 규칙입니다.

Show one visual piece of evidence, not a wall of text.

---

## 2:15–2:40 — Release potential

> 현재는 설치 없이 바로 플레이하는 짧은 웹 아케이드지만, 세션 점수와 최고 단계라는 경쟁 축이 이미 있습니다. 이후 데일리 챌린지, 리더보드, 업적과 계정 진행으로 확장할 수 있고, 실제 출시 단계에서는 Hive 같은 서비스 연동도 자연스럽게 붙일 수 있습니다.

---

## 2:40–3:00 — Finish on spectacle

Do not finish on a slide. Finish on the game.

> 목표는 간단했습니다. 3분 뒤 플레이어가 '처음엔 눈송이였는데 왜 우주가 이러지?'라고 말하게 만드는 것. Snowball Effect입니다.

Show the strongest late-game effect or final Scale Shift.


---

## Updated Core Loop — Greed vs Cashout

Snowball Effect의 플레이어 선택은 단순 머지가 아니다.

- 높은 공을 계속 살리면 다음 머지로 점수가 폭발할 수 있다.
- 지금 Cashout하면 현재 점수와 추가 시간을 얻는다.
- Stage 최고 공은 즉시 Clear.
- 시간이 끝나면 화면 공까지 Score-only Final Settlement.
- 목표 점수를 넘기면 Score Clear.

이 구조를 Originality / Playability 설명의 핵심으로 사용한다.

---

## FILE: SUBMISSION/06_RELEASE_CHECKLIST.md

# Release & Submission Checklist

## A. Core game

- [ ] A/D movement works.
- [ ] Arrow-key tilt works.
- [ ] Simultaneous movement + tilt works.
- [ ] Reflection is predictable.
- [ ] Same-level merge works.
- [ ] Different levels do not merge.
- [ ] Bottom cash-out awards correct data-defined score.
- [ ] Score formatter survives late values.
- [ ] Scale Shift cannot trigger twice for the same stage.
- [ ] Previous top ball becomes next base ball.
- [ ] Spawn rate changes by stage.
- [ ] At least two Scale Shifts are naturally reachable in a normal approximately three-minute run.
- [ ] Timer ends game cleanly.
- [ ] Results screen works.
- [ ] Retry fully resets state.

## B. Performance

- [ ] No N² merge loop remains in release path.
- [ ] 1,000 logical-ball stress test recorded.
- [ ] Late-stage real gameplay tested.
- [ ] FX throttling works during burst events.
- [ ] Browser frame rate is acceptable.
- [ ] No repeated large allocation spikes discovered in normal play.

## C. Web build

- [ ] Godot Web Export succeeds.
- [ ] Hosted URL uses the final build.
- [ ] Tested from incognito / logged-out browser.
- [ ] No installation required.
- [ ] No access approval required.
- [ ] No login required.
- [ ] First click/input activates audio correctly.
- [ ] Keyboard focus works after loading.
- [ ] Browser resize keeps playable layout.
- [ ] Chrome tested.
- [ ] Edge tested.
- [ ] Firefox tested if time permits.
- [ ] Browser console has no fatal error.
- [ ] URL will remain online throughout judging.

## D. Presentation surface

- [ ] Title screen is readable in a screenshot.
- [ ] Controls are visible.
- [ ] 16:9 thumbnail prepared.
- [ ] Thumbnail exported JPG/PNG <= 10 MB.
- [ ] Thumbnail does not look like a generic snow wallpaper.
- [ ] Strong late-game screenshot captured.
- [ ] Result screen looks shareable.

## E. Submission form

- [ ] Final game title confirmed.
- [ ] Korean intro <= 200 chars verified in actual form.
- [ ] Playable URL pasted and tested.
- [ ] Thumbnail uploaded.
- [ ] Demo video URL added if submitted.
- [ ] Codex collaboration explanation written from real logs.
- [ ] Existing-project disclosure handled if relevant.

## F. Codex evidence

- [ ] `02_CODEX_COLLAB_LOG.md` contains actual sessions.
- [ ] At least one implementation example.
- [ ] At least one debugging/problem-solving example.
- [ ] At least one verification or performance result.
- [ ] Human gameplay decisions are explicitly separated.
- [ ] No fabricated metrics or claimed work.

## G. Final-event readiness

Only needed if selected.

- [ ] Build opened before pitch.
- [ ] Offline/local fallback build available on laptop.
- [ ] Demo save/debug path can quickly reach Scale Shift if live run RNG is slow.
- [ ] Debug controls hidden from public UI.
- [ ] Pitch is under 3 minutes in rehearsal.
- [ ] One representative can explain every major system.
- [ ] Strongest visual is used as the final ten seconds.

---

## FILE: SUBMISSION/07_INTERNAL_TIMELINE.md

# Internal Timeline to Track 1 Submission

> Internal planning document, not an official schedule.
> Official submission deadline: 2026-08-26.

The goal is to freeze the playable build one day before the official deadline.

---

## Aug 7–10 — Core loop

- Phase 0/1
- move + tilt paddle
- reliable reflection
- cash-out
- restart
- first Web Export smoke test

Success gate: the ugly placeholder build is already playable in browser.

---

## Aug 11–13 — Merge + mass simulation

- Phase 2
- same-level merge
- score data
- Phase 3 Spatial Grid
- 1,000-ball stress test
- start real Codex collaboration log

Success gate: the core mechanic works without relying on N² collision.

---

## Aug 14–16 — Scale Shift

- Ground
- Planetary
- Galactic
- unit re-baselining
- spawn-rate escalation
- background transition

Success gate: a normal player can see at least two scale changes inside a 3-minute tuning run.

---

## Aug 17–19 — Game feel

- merge hierarchy
- score popups
- Scale Shift announcement
- camera / hit-stop
- audio hierarchy
- basic art direction

Success gate: a 10-second clip looks recognizably like Snowball Effect, not an engine test.

---

## Aug 20–21 — Optional high-value systems

Priority order:

1. Blizzard
2. Fire Core
3. Black Hole
4. Magnet only if everything above is stable

Cut optional features aggressively if web stability slips.

---

## Aug 22–23 — Release candidate

- final stage-based approximately three-minute loop
- results / retry
- final Web Export
- hosting
- browser tests
- performance pass
- thumbnail composition

Success gate: RC can be submitted today if necessary.

---

## Aug 24 — Submission media

- record actual gameplay
- edit <=3-minute video
- capture thumbnail
- draft 200-char introduction
- assemble Codex collaboration explanation

---

## Aug 25 — Freeze / external test

- send link to another person
- test from incognito / another PC if possible
- verify instructions
- fix only submission blockers
- no new systems

---

## Aug 26 — Submit

- re-test public link
- verify form fields
- upload thumbnail
- optional video
- Codex collaboration write-up
- submit before the last-minute window

No feature development on submission day unless it fixes a blocker.

---
