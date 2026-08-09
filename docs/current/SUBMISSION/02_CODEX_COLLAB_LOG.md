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
