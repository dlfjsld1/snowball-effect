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
- Verification: StageManager가 deadline 이후 gameplay를 step하지 않고 deadline 전 Cashout만 Core에 전달; Score Clear `CLEAR_LOCKED→SETTLING→CLEARED`까지 즉시 한 번 처리하고 matching `NEXT STAGE(clear_id)` 전에는 Shift하지 않으며 요청 수락 뒤에만 `SHIFTING`; clear score 미달 Time Up은 `TIME_UP_LOCKED→SETTLING→FAILED`; timeout 시 남은 공은 Time Bonus 없는 Settlement; wrong/stale/duplicate 요청과 완료 신호 중복에도 전이 한 번.
- Do Not Modify: Core 계산 내부와 Presentation animation 내부.

### S3-G6 Stage HUD

- Owner: Presentation
- Owned Files: `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`, `tests/presentation/**`
- Integration Point: `stage_time_changed`, `score_changed`, `stage_changed(definition)`, committed `ball_merged(result_level, world_position)`, `stage_clear_decided` 구독. `stage_changed`에서 현재 `StageDefinition.local_ball_levels`와 `revealed_count=1`을 적용하고, 이후 현재 Stage chain에 속한 committed Merge 결과만 해당 local index까지 공개한다.
- Dependencies: S3-G2 signal signature와 S3-G1 display data.
- Verification: Stage Time/Stage Score/Run Score/Clear Target과 Stage 이름(`Ground`/`Planetary`/`Galactic`)을 지속 표시; 사용자-facing 제목은 정확히 `BALLS`; 현재 Stage의 공 족보는 고정 세로 5칸 housing의 원과 연결선으로 아래에서 위로 배치하고 Stage 진입 시 첫 공만 표시; 공개된 원 안에는 실제 Stage-local `BallTextureLodCatalog` runtime texture를 그 resource의 sampling mode 그대로 24×24 표시하되 Planetary local Lv0 Moon은 Ground local Lv4 Moon의 approved resource identity, Galactic local Lv0 Galaxy는 Planetary local Lv4 Galaxy의 approved resource identity를 공유하고 Galactic local Lv1 Galaxy Cluster는 global Lv11/local Lv1 identity와 16×16 gameplay mapping을 유지한 채 BALLS CRT에서만 선택 A의 전용 24×24 source를 사용; 이 세 HUD-only source override 외 나머지 12개 entry는 현재 Stage의 기존 texture selection을 유지하고 15개 slot identity는 모두 보존; 제목·5개 원·4개 선·아이콘·긴 이름 label의 bounding rect가 실제 106×317 CRT scanline display의 2px inset 안에 위치; 새 공을 처음 만들 때 대응 이미지·이름이 순서대로 정확히 한 번 공개되며 미발견 공의 drawable texture·이미지·이름은 출력되지 않음; Time Bonus 0이면 time popup 없음; HUD가 Merge 결과나 gameplay texture mapping·size·collision·규칙 state를 변경하지 않음.
- Do Not Modify: Stage runtime, StageManager, resource 값.

### S3-G7 local Lv4 비종료 계약 마이그레이션

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/simulation/ball_simulation_manager.gd`, `tests/core/**`
- Integration Point: 기존 `ball_merged(result_level, world_position)`, `top_ball_created(global_level)`, `end_decision_requested(reason)` 경계를 유지한다. 전용 FIRST_CONTACT producer는 이 Goal의 완료 범위가 아니며 S3-G9가 소유한다.
- Dependencies: S3-G3, S5-G2, S8-G1.
- Verification: Ground Moon과 Planetary Galaxy 생성은 Stage Clear/Settlement를 요청하지 않고 PLAYING을 유지하며 Active Cashout 가능; deadline 전 local Lv4+Time Up은 유효 Merge와 기존 discovery/Cashout commit 뒤 남은 시간이 없을 때 Time Up 한 번; 첫 Galactic Black Hole은 Stage Clear가 아니라 기존 Black Hole entity/phase readiness 경로로만 이어짐. 전용 FIRST_CONTACT producer Evidence는 S3-G9 범위다.
- Do Not Modify: StageManager, HUD/CUT-IN, StageDefinition 값.

#### S3-G7 증거 범위 — 역사 보존

S3-G7의 기존 `VERIFIED` 증거는 local Lv4가 종료 사유가 아님과 `SCORE_CLEAR`/`TIME_UP` 중재만 증명한다. Run-scoped seen set, `event_id`, `run_epoch`, 여섯 identity 또는 `first_contact_discovered` producer가 구현됐다는 증거로 소급 사용하지 않는다.

### S3-G8 Stage Score gauge

- Owner: Presentation
- Owned Files: `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`, `tests/presentation/**`
- Integration Point: 기존 read-only `score_changed`와 `StageDefinition.clear_score`를 소비한다.
- Dependencies: S3-G6, S3-G7 계약.
- Verification: non-final Stage에서 `stage_score / clear_score` 진행률을 0~100% gauge로 표시; 점수 감소/초과/Stage reset 반영; `clear_score <= 0`인 Galactic에서는 숨김 또는 비결정 상태; HUD가 Clear를 판정하지 않음.
- Do Not Modify: score ledger, StageRuntime/StageManager, StageDefinition 값.

### S3-G9 Run-scoped FIRST_CONTACT discovery producer

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/simulation/ball_simulation_manager.gd`, `tests/core/s3_g9_**`, `tests/simulation/s3_g9_**`
- Integration Point: `begin_first_contact_run(run_epoch: int) -> bool`, `invalidate_first_contact_run(run_epoch: int) -> bool`, `first_contact_discovered(payload: Dictionary)` v1을 제공한다. Integration이 Run lifecycle을 호출하고 payload를 소비한다.
- Dependencies: S3-G7의 local Lv4 비종료 계약, S5-G2의 ordered Stage chain, S8-G1의 첫 Black Hole entity 전환 readiness.
- Verification: 아래 여섯 identity만 현재 Run에서 각각 정확히 한 번 발행; Stage 변경에는 seen set 유지; Retry/fresh Run에는 새 `run_epoch`로 다시 발견 가능; Main 이동/invalid epoch에는 발행 없음; process-lifetime monotonic `event_id`; deterministic Merge commit 순서; 같은 tick 복수 discovery의 event 순서; duplicate/out-of-chain/local Lv0 재등장 거부; payload schema/type/level/position 검증; 첫 Black Hole payload는 첫 entity와 `BLACK_HOLE_PHASE` handoff를 표시하되 Phase를 시작하지 않음.
- Do Not Modify: GameManager/StageManager/Main wiring, CUT-IN scene/controller, S8 Phase presentation·force·finale, Stage/Clear/score/timer 판정.

지원 identity는 정확히 다음과 같다.

| `first_contact_id` | Stage | `global_level` | `local_level` | `handoff_kind` |
|---|---|---:|---:|---|
| `ground_giant_snowball` | Ground | 3 | 3 | `RESUME_PLAYING` |
| `ground_moon` | Ground | 4 | 4 | `RESUME_PLAYING` |
| `planetary_supernova` | Planetary | 8 | 3 | `RESUME_PLAYING` |
| `planetary_galaxy` | Planetary | 10 | 4 | `RESUME_PLAYING` |
| `galactic_event_horizon` | Galactic | 13 | 3 | `RESUME_PLAYING` |
| `galactic_black_hole` | Galactic | 14 | 4 | `BLACK_HOLE_PHASE` |

payload v1의 필드·순서·reset 계약은 [`../../team/INTEGRATION_CONTRACTS.md`](../../team/INTEGRATION_CONTRACTS.md)의 `FIRST_CONTACT discovery·CUT-IN 계약`을 단일 cross-owner 기준으로 사용한다.

## Exit Gate

[`../QUALITY_GATES.md`](../QUALITY_GATES.md)의 S3 필수 회귀 시나리오 전체, Integration Gate, Desktop/Web smoke 통과.
