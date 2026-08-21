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
- Verification: `base_time`, `clear_score`, 5개 `time_bonus_by_local_level`, ordered `local_ball_levels`, spawn rate, `visual_radius_scale` 로드; Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`; Lv7 `Red Giant`와 Lv9 `Nebula`는 15종 BallCatalog에는 유지하되, 합의된 기본 Run의 어느 Stage chain에도 넣지 않음; 초기 seed는 데이터일 뿐 공식이 아님.
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
- Verification: tick의 deadline 전 `valid_play_delta`만 물리/Merge/Cashout을 commit하고 이후 구간의 하단 통과는 Active Cashout으로 인정하지 않음; deadline 전 Cashout Time Bonus는 `PLAYING`을 연장할 수 있음; non-final `stage_score >= clear_score`는 Time Up보다 먼저 `SCORE_CLEAR`를 한 번 요청; local Lv4 생성은 종료 사유가 아님.
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
- Verification: StageManager가 deadline 이후 gameplay를 step하지 않고 deadline 전 Cashout만 Core에 전달; Score Clear `CLEAR_LOCKED→SETTLING→CLEARED→SHIFTING`; clear score 미달 Time Up은 `TIME_UP_LOCKED→SETTLING→FAILED`; timeout 시 남은 공은 Time Bonus 없는 Settlement; 완료 신호 중복에도 전이 한 번.
- Do Not Modify: Core 계산 내부와 Presentation animation 내부.

### S3-G6 Stage HUD

- Owner: Presentation
- Owned Files: `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`, `tests/presentation/**`
- Integration Point: `stage_time_changed`, `score_changed`, `stage_changed`, `stage_ball_progression_changed(stage_id, ordered_global_levels, revealed_count)`, `stage_clear_decided` 구독.
- Dependencies: S3-G2 signal signature와 S3-G1 display data.
- Verification: Stage Time/Stage Score/Run Score/Clear Target과 Stage 이름(`Ground`/`Planetary`/`Galactic`)을 지속 표시; 현재 Stage의 공 족보는 고정 세로 5칸 housing에 배치하고 Stage 진입 시 첫 공만 표시; 새 공을 처음 만들 때 대응 아이콘·이름이 순서대로 정확히 한 번 공개되며 미발견 공은 출력되지 않음; Time Bonus 0이면 time popup 없음; HUD가 Merge 결과나 규칙 state를 변경하지 않음.
- Do Not Modify: Stage runtime, StageManager, resource 값.

### S3-G7 local Lv4 비종료 계약 마이그레이션

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/simulation/ball_simulation_manager.gd`, `tests/core/**`
- Integration Point: local Lv3/Lv4 최초 생성 discovery event와 기존 `end_decision_requested(reason)` 경계를 유지한다.
- Dependencies: S3-G3, S5-G2, S8-G1.
- Verification: Ground Moon과 Planetary Galaxy 생성은 Stage Clear/Settlement를 요청하지 않고 PLAYING을 유지하며 Active Cashout 가능; deadline 전 local Lv4+Time Up은 유효 Merge/discovery/Cashout commit 뒤 남은 시간이 없을 때 Time Up 한 번; 첫 Galactic Black Hole은 discovery 이후 Black Hole Phase 요청으로만 이어짐.
- Do Not Modify: StageManager, HUD/CUT-IN, StageDefinition 값.

### S3-G8 Stage Score gauge

- Owner: Presentation
- Owned Files: `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`, `tests/presentation/**`
- Integration Point: 기존 read-only `score_changed`와 `StageDefinition.clear_score`를 소비한다.
- Dependencies: S3-G6, S3-G7 계약.
- Verification: non-final Stage에서 `stage_score / clear_score` 진행률을 0~100% gauge로 표시; 점수 감소/초과/Stage reset 반영; `clear_score <= 0`인 Galactic에서는 숨김 또는 비결정 상태; HUD가 Clear를 판정하지 않음.
- Do Not Modify: score ledger, StageRuntime/StageManager, StageDefinition 값.

## Exit Gate

[`../QUALITY_GATES.md`](../QUALITY_GATES.md)의 S3 필수 회귀 시나리오 전체, Integration Gate, Desktop/Web smoke 통과.
