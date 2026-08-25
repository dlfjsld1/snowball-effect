# S1 — Minimum Loop

원문: [`../../current/tasks/01_minimum_loop.md`](../../current/tasks/01_minimum_loop.md)

## 결과

회색 placeholder만으로 생성→등속 arcade 이동→벽·패들 반사→Active Cashout이 플레이 가능하다.

## Goals

### S1-G1 배열 풀 낙하

- Owner: Core
- Owned Files: `scripts/simulation/ball_simulation_manager.gd`, `scripts/simulation/ball_renderer.gd`, `tests/simulation/**`
- Integration Point: `ball_count_changed(active_count)`와 renderer가 읽을 snapshot API.
- Dependencies: S0 완료; Integration이 PlayField Rect와 simulation mount 제공.
- Verification: 중앙 배열/`free_indices`, 기본 gravity 0, 상호작용 없는 velocity/speed 유지, 좌·우·상단 반사, 열린 하단, 100개 활성 공에서 오류 없음.
- Do Not Modify: Main scene, HUD, StageManager.

### S1-G2 패들 조작과 반사

- Owner: Core
- Owned Files: `scripts/gameplay/paddle.gd`, `scripts/simulation/ball_simulation_manager.gd`, `scenes/gameplay/paddle.tscn`, `tests/core/**`, `tests/simulation/**`
- Integration Point: Integration에 Paddle mount 요청; simulation에 previous/current Paddle transform, signed angular displacement와 contact velocity 계약 제공.
- Dependencies: S1-G1; S0 Input action 계약.
- Verification: 실제 Main runtime에서 A/D 이동과 ←/→ 회전을 각각 및 동시에 입력했을 때 서로 차단되지 않음; Mouse X는 Play Field logical X에 직접 반영되어 target-follow latency가 없음; Mouse 이동과 Wheel 360° 이상 연속 회전을 동시에 사용 가능; previous/current Paddle transform과 ball trajectory의 continuous query가 빠른 translation/rotation에서도 Lv1 공을 놓치지 않음; Paddle 양면이 TOI의 contact normal 및 상대속도를 기준으로 반사; center linear velocity와 angular contact contribution을 합산한 뒤 impact cap 적용; Paddle 중심/끝 및 회전 방향에 따른 반사 차이; ball runtime speed cap, penetration correction, contact separation lock 정상.
- Do Not Modify: `project.godot`, Main scene, Presentation assets.

### S1-G2A 패들 수직 대쉬

- Owner: Core
- Owned Files: `scripts/gameplay/paddle.gd`, `scenes/gameplay/paddle.tscn`, `tests/core/paddle_dash_test.*`
- Integration Point: `project.godot`의 `paddle_dash` Space Input Map만 사용한다. Main, simulation, score와 새 Signal/API 연결은 없다.
- Dependencies: S1-G2의 previous/current Paddle transform과 physical clamp 계약.
- Verification: Space 입력이 화면 기준 위쪽으로만 120 logical units를 기준 leg speed `1200 units/s` 시간 안에 sine ease-out으로 이동하고, 정지 없이 sine ease-in-out으로 원점에 복귀한다. 대쉬 중에도 물리 OBB와 continuous collision provider는 실제 transform을 사용한다. 재사용 대기시간은 5초이며 cooldown 중 activation은 거부된다. 패들 중앙의 기존 초록색 바는 dash 직후 비어 있고 5초 동안 좌→우로 채워진다. matching Scale Shift 완료가 다음 Stage 진입으로 수락되면 cooldown은 즉시 초기화되며 wrong/duplicate 완료 ID에는 유지된다.
- Do Not Modify: Main scene, simulation/score/Stage state, Paddle 본체 PNG. 물리 OBB 폭은 승인된 본체 PNG 폭 `168`과 일치한다.

### S1-G3 Active Cashout 논리

- Owner: Core
- Owned Files: `scripts/simulation/ball_simulation_manager.gd`, `scripts/core/score_ledger.gd`, `tests/core/**`
- Integration Point: `cashout_completed(score_amount, local_level, world_position)`; S1에서는 time bonus를 0으로 둔다.
- Dependencies: S1-G1, S1-G2.
- Verification: ScoreZone 통과 공 비활성화, 슬롯 재사용, cashout score가 stage/run ledger에 각각 한 번 반영.
- Do Not Modify: HUD, StageManager, item modifier.

### S1-G4 최소 HUD

- Owner: Presentation
- Owned Files: `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`, `tests/presentation/**`
- Integration Point: Core의 `score_changed`, `ball_count_changed`를 구독; Main mount는 Integration에 요청.
- Dependencies: S1-G1과 S1-G3 signal signature 확정.
- Verification: Cashout 1회당 점수 한 번 갱신, 활성 공 수 표시, 표시 코드가 gameplay 값을 변경하지 않음.
- Do Not Modify: score ledger, Ball simulation, Main scene.

### S1-G5 Pause·Restart 요청 UI

- Owner: Content/Systems
- Owned Files: `scripts/ui/pause_menu.gd`, `scenes/ui/pause_menu.tscn`, `tests/content/**`
- Integration Point: `pause_requested`와 `retry_requested`만 발행하고 실제 runtime을 직접 초기화하지 않는다.
- Dependencies: S0-G2 UI mount 계약.
- Verification: 버튼/입력이 요청 signal을 한 번 발행하고 gameplay state를 직접 변경하지 않음.
- Do Not Modify: GameManager, Main scene, Core reset 내부.

### S1-G6 Pause와 Restart 통합

- Owner: Integration
- Owned Files: `project.godot`, `scenes/main/main.tscn`, `scripts/core/game_manager.gd`
- Integration Point: Content의 `pause_requested/retry_requested`, Core의 `reset_runtime()`과 Presentation의 `reset_view()` 연결.
- Dependencies: S1-G1~G5의 reset/pause API 제공.
- Verification: Pause 시 simulation 정지; Retry 시 배열, 슬롯, 점수, HUD가 초기화; 두 번 Retry에도 잔존 state 없음.
- Do Not Modify: 각 Owner 내부 reset 구현.

## Exit Gate

Q-S1, Integration Gate, Desktop/Web smoke 통과.
