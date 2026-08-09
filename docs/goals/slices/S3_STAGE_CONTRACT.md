# S3 — Stage Contract

원문: [`../../current/tasks/02_5_cashout_time_stage_clear.md`](../../current/tasks/02_5_cashout_time_stage_clear.md)

## 결과

Stage Timer, Time Bonus, Top Ball, Time Up, Final Settlement가 확정 계약대로 충돌 없이 동작한다.

## Goals

### S3-G1 Stage 데이터

- Owner: Content/Systems
- Owned Files: `scripts/data/stage_definition.gd`, `resources/stages/**`, `tests/content/**`
- Integration Point: read-only `StageCatalog.get_stage(index)` API와 `StageDefinition` schema.
- Dependencies: S2-G1 BallCatalog; Core가 runtime 필드를 확정.
- Verification: `base_time`, `clear_score`, `time_bonus_by_local_level`, level range, spawn rate 로드; 초기 seed는 데이터일 뿐 공식이 아님.
- Do Not Modify: Stage runtime와 StageManager.

### S3-G2 Stage 진입과 Cashout 점수·시간

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/core/score_ledger.gd`, `tests/core/**`
- Integration Point: StageManager가 호출할 `enter_stage(definition)`; `stage_time_changed`, `score_changed`; S3-G1 data 소비.
- Dependencies: S3-G1, S1-G3.
- Verification: 진입 시 stage score/time reset, run score preserve; Cashout amount를 stage/run에 한 번씩 더하고 local level Time Bonus 반영; 종료 재합산 없음.
- Do Not Modify: StageManager, HUD, StageDefinition 값.

### S3-G3 한 tick의 종료 중재

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/simulation/ball_simulation_manager.gd`, `tests/core/**`
- Integration Point: `end_decision_requested(reason)`을 StageManager에 제공.
- Dependencies: S3-G2와 S2-G3 Merge commit.
- Verification: 시간 차감→물리/Merge→Top Ball→Cashout→종료 판정; 같은 tick Cashout 구조; Top Ball이 Time Up보다 우선.
- Do Not Modify: StageManager state transition과 Presentation.

### S3-G4 Snapshot Settlement

- Owner: Core
- Owned Files: `scripts/core/settlement_service.gd`, `scripts/core/score_ledger.gd`, `tests/core/**`
- Integration Point: `settle(snapshot)`과 `final_settlement_started/finished(amount)` 제공.
- Dependencies: S3-G3 종료 잠금, S2-G1 base score data.
- Verification: active snapshot 고정, base score만 한 번 반영, Time Bonus/Cashout modifier/Merge 없음, 중복 호출 idempotent.
- Do Not Modify: item code, StageManager, Settlement 연출.

### S3-G5 Clear·Fail 상태 통합

- Owner: Integration
- Owned Files: `scripts/core/stage_manager.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`
- Integration Point: Core의 end decision/settlement API와 Presentation의 clear/settlement 완료 signal을 순서대로 연결.
- Dependencies: S3-G2~G4 API와 문서화된 Integration signal 계약.
- Verification: Top Ball `CLEAR_LOCKED→SETTLING→CLEARED`; Time Up `TIME_UP_LOCKED→SETTLING→CLEARED/FAILED`; 완료 신호 중복에도 전이 한 번.
- Do Not Modify: Core 계산 내부와 Presentation animation 내부.

### S3-G6 Stage HUD

- Owner: Presentation
- Owned Files: `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`, `tests/presentation/**`
- Integration Point: `stage_time_changed`, `score_changed`, `stage_changed`, `stage_clear_decided` 구독.
- Dependencies: S3-G2 signal signature와 S3-G1 display data.
- Verification: Stage Time/Stage Score/Run Score/Clear Target/Stage 이름 표시; Time Bonus 0이면 time popup 없음; HUD가 규칙 state를 변경하지 않음.
- Do Not Modify: Stage runtime, StageManager, resource 값.

## Exit Gate

[`../QUALITY_GATES.md`](../QUALITY_GATES.md)의 S3 필수 회귀 5개, Integration Gate, Desktop/Web smoke 통과.
