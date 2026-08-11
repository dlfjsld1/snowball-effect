# S8 — Black Hole and Final Result

원문: [`../../current/tasks/07_black_hole.md`](../../current/tasks/07_black_hole.md)

## 결과

Black Hole 최종 Stage가 플레이 가능하고 Clear 후 Final Result와 완전한 Retry로 끝난다.

## Goals

### S8-G1 Black Hole force

- Owner: Core
- Owned Files: `scripts/simulation/ball_simulation_manager.gd`, `scripts/core/stage_runtime.gd`, `tests/simulation/**`
- Integration Point: StageDefinition의 force parameters를 소비하고 position snapshot을 Presentation에 read-only 제공.
- Dependencies: S5 완료와 S4 performance baseline.
- Verification: 최소 거리/최대 가속도/delta 적용, NaN·폭주 없음, 1,000공 성능 회귀 기록.
- Do Not Modify: Black Hole visual과 Stage resource 값.

### S8-G2 최종 Stage Clear runtime

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/core/settlement_service.gd`, `tests/core/**`
- Integration Point: `final_stage_cleared(result_snapshot)`을 Integration에 제공.
- Dependencies: S8-G1과 S3 Settlement 계약.
- Verification: Top Ball/Score Clear 모두 Final Settlement 실행; 마지막 Clear에 next-stage 요청 없음.
- Do Not Modify: Result UI, GameManager/StageManager.

### S8-G3 Title·Main·Result UI

- Owner: Content/Systems
- Owned Files: `scripts/ui/title_screen.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/result_panel.gd`, `scenes/ui/title_screen.tscn`, `scenes/ui/pause_menu.tscn`, `scenes/ui/result_panel.tscn`, `tests/content/**`
- Integration Point: `start_requested`, `retry_requested`, `resume_requested`, `settings_requested`, `main_menu_requested`; read-only result snapshot 표시 API.
- Dependencies: S8-G2 result snapshot schema와 S0-G2 UI mount 계약.
- Verification: score/highest stage/highest ball 표시; Start/Retry/Pause modal 행동 요청 한 번; Pause modal에 재개·다시 시작·설정·메인 화면이 표시됨; UI가 runtime state를 직접 초기화하지 않음.
- Do Not Modify: GameManager, StageManager, Core result 계산.

### S8-G4 Final Result와 Retry 통합

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/**`
- Integration Point: Core result snapshot, Content UI의 `retry_requested/main_menu_requested`, 모든 Owner의 reset API 연결.
- Dependencies: S8-G2, S8-G3, Presentation reset API.
- Verification: run score/highest stage/highest ball 표시; `CLEARED→Result`; Retry가 배열·점수·타이머·settlement/shift/item/presentation lock 완전 초기화; Main 이동은 Run state를 안전하게 종료하고 Title/Main 화면으로 돌아감.
- Do Not Modify: Result UI 내부와 각 Owner reset 내부.

## Exit Gate

Q-S8, Integration Gate, 전체 Run Desktop/Web 완주.
