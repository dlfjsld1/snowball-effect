# S8 — Black Hole and Final Result

원문: [`../../current/tasks/07_black_hole.md`](../../current/tasks/07_black_hole.md)

## 결과

마지막 Galactic Stage에서 첫 Lv14를 이동 Black Hole 기믹으로 전환하고 L3 Frame/Play Field로 확장한다. 두 번째 Black Hole과 충돌하면 최종 회전·폭발·타이틀 연출로 Run을 끝내고 완전한 Retry에 도달한다.

## Goals

### S8-G1 Black Hole force

- Owner: Core
- Owned Files: `scripts/simulation/ball_simulation_manager.gd`, `scripts/core/stage_runtime.gd`, `tests/simulation/**`
- Integration Point: 첫 Lv14 생성에서 `black_hole_phase_started(phase_id, from_rect, to_rect)`와 Black Hole position snapshot을 Integration/Presentation에 read-only 제공.
- Dependencies: S5 완료와 S4 performance baseline.
- Verification: 첫 Lv14가 일반 Clear 없이 Black Hole runtime entity로 한 번 전환; `local_level <= 2` 흡수와 Cashout 상당 점수 차감, run score 0의 즉시 Game Over, 다중 source vector 합산·600 total cap, Black Hole 상호 450 pull, 하단 반사·Cashout 제외, 비성장·Merge 제외, NaN·폭주 없음, 1,000공 성능 회귀 기록; 별도 Stage나 새 BallDefinition을 생성하지 않음.
- Do Not Modify: Black Hole visual과 Stage resource 값.

### S8-G2 두 Black Hole 최종 충돌 runtime

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/core/settlement_service.gd`, `tests/core/**`
- Integration Point: 두 Black Hole 접촉에서 terminal lock과 read-only finale/result snapshot을 Integration에 제공.
- Dependencies: S8-G1과 S3 Settlement 계약.
- Verification: 첫 Lv14는 종료하지 않고 두 번째 Lv14까지 gameplay 지속; 두 Black Hole의 earliest contact가 일반 Merge보다 우선; terminal event 한 번; 추가 Stage Shift 없음.
- Do Not Modify: Result UI, GameManager/StageManager.

### S8-G3 Title·Main·Terminal UI

- Owner: Content/Systems
- Owned Files: `scripts/ui/title_screen.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/result_panel.gd`, `scenes/ui/title_screen.tscn`, `scenes/ui/pause_menu.tscn`, `scenes/ui/result_panel.tscn`, `tests/content/**`
- Integration Point: `start_requested`, `retry_requested`, `resume_requested`, `settings_requested`, `main_menu_requested`; read-only terminal/result snapshot 표시 API.
- Dependencies: S8-G2 terminal snapshot schema와 S0-G2 UI mount 계약.
- Verification: finale에서 gameplay HUD/UI가 사라지고 `SNOWBALL EFFECT` 타이틀, `CLEAR SCORE` 최종 run score, `MAIN MENU` 버튼 표시; Start/Retry/Pause modal 행동 요청 한 번; Pause modal에 재개·다시 시작·설정·메인 화면이 표시됨; UI가 runtime state를 직접 초기화하지 않음.
- Do Not Modify: GameManager, StageManager, Core result 계산.

### S8-G4 Black Hole Finale와 Retry 통합

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/**`
- Integration Point: Core result snapshot, Content UI의 `retry_requested/main_menu_requested`, 모든 Owner의 reset API 연결.
- Dependencies: S8-G2, S8-G3, S8-G5, Presentation reset API.
- Verification: matching `phase_id`에서 L2→L3 logical Rect 활성화 후 같은 Galactic gameplay 재개; 두 Black Hole 접촉 뒤 finale→타이틀→Run End에서 추가 Shift 없음; Retry가 배열·점수·타이머·settlement/shift/phase/Black Hole/item/presentation lock 완전 초기화; Main 이동은 Run state를 안전하게 종료하고 Title/Main 화면으로 돌아감.
- Do Not Modify: Result UI 내부와 각 Owner reset 내부.

### S8-G5 Black Hole Phase presentation

- Owner: Presentation
- Owned Files: `scripts/presentation/background_manager.gd`, `scripts/presentation/presentation_manager.gd`, `scenes/backgrounds/**`, `scenes/effects/**`, `scripts/ui/hud.gd`, `tests/presentation/**`
- Integration Point: `black_hole_phase_started(phase_id, from_rect, to_rect)`를 구독하고 `black_hole_phase_presentation_finished(phase_id)`를 정확히 한 번 반환.
- Dependencies: S5-G4의 Frame/Field 이동 계약과 S8-G1의 phase/position snapshot.
- Verification: L2 `920`에서 L3 `1080`으로 Frame·표시 Play Field·고정 폭 HUD housing이 함께 좌우 대칭 확장; `Galactic` Stage 표시는 유지; 전환 완료 뒤 gameplay Black Hole과 HUD가 활성 상태로 남음; 두 Black Hole 접촉 시 mutual orbit·폭발 뒤 HUD/UI 제거와 타이틀·Clear Score·Main Menu 표시; reduced-effects에서도 상태명·경계 이동·finale가 읽힘; duplicate/stale `phase_id`는 완료로 재사용되지 않음.
- Do Not Modify: StageManager, logical bounds, force 계산, Stage/ball resource 값.

## Exit Gate

Q-S8, Integration Gate, 전체 Run Desktop/Web 완주.
