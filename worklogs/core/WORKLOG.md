# Core Gameplay Worklog

> Append-only. 실제 작업과 검증만 기록한다.

## Entry format

```text
## YYYY-MM-DD — Goal / Task
Owner: Core
Branch:
작업:
변경:
확인:
Codex:
다음 작업 / 주의:
```

## 2026-08-09 — S1-G1 배열 풀 낙하

Owner: Core
Branch: `main` working tree

### 작업

- 공을 개별 Node로 만들지 않는 중앙 SoA 배열 시뮬레이션의 첫 단계를 구현했다.

### 변경

- `BallSimulationManager`: positions/velocities/radii/active flags, active/free index, spawn/deactivate, 슬롯 재사용, 중력, 좌우 벽 반사.
- `BallRenderer`: manager snapshot을 읽어 단일 `Node2D._draw()`에서 원을 일괄 렌더하는 경계.
- `s1_g1_verification`: 100공, 중력, 좌/우 반사, 비활성 슬롯 재사용, 배열 capacity 정합성, 유한값, render snapshot 자동 검증.

### 확인

- Primary `godot` MCP validate: 두 runtime script와 test script/scene 4개 모두 valid.
- Godot 4.7.1 headless test: exit 0, `S1_G1_VERIFIED active=100 capacity=100 reused_slot=50`.
- 기존 Main headless smoke: exit 0.
- 기존 Web release export 회귀: exit 0.

### Codex

- Integration-owned Main/project 파일을 수정하지 않고 Core Owned Files만 변경했다.
- Paddle, Cashout, Merge, Score, Timer 등 다음 Goal 기능은 구현하지 않았다.

### 다음 작업 / 주의

- 다음 가능한 Goal은 S1-G2 패들 조작·반사다.
- 기존 Web preset의 `all_resources`가 local `build/`까지 패킹하는 별도 문제가 관찰됐다. S1-G1 범위 밖이므로 후속 Content/Systems 유지보수에서 수정한다.

## 2026-08-09 — S1-G2 패들 조작·반사

Owner: Core
Branch: `main` working tree

### 작업

- Core-owned 패들 씬에 이동·회전 입력과 예측 가능한 수동 반사 계산 경계를 구현했다.

### 변경

- `Paddle`: A/D 이동, 방향키 회전, 동시 축 처리, Play Field 이동 제한, transform/velocity snapshot API.
- 반사 계산: 회전 선분 broad/narrow phase, 위쪽 접근 제한, 각도·접촉 위치·패들 이동 영향, 최소/최대 속도, 표면 밖 위치 보정.
- `reflection_test_scene`: 실제 Input action 동시 처리와 반사 방향·접촉점·패들 속도·연속 관통 방지를 자동 검증.

### 확인

- Godot 4.7.1 headless test: exit 0, `S1_G2_VERIFIED input=simultaneous reflection=angle_contact_velocity penetration=none`.
- Primary `godot` MCP validate: script/scene/test scene 3개 모두 valid.
- Primary `godot` 실제 runtime: 동시 이동+회전 250ms 후 x `620→735.0003`, rotation `0→0.6545rad`, runtime error 0.
- S1-G1 자동검증과 기존 Main headless smoke: 각각 exit 0.

### Codex

- Integration-owned Main/project 파일과 S1-G1 simulation 파일은 수정하지 않았다.
- Paddle mount wiring, Cashout, Score, Merge 등 다음 Goal 기능은 구현하지 않았다.

### 다음 작업 / 주의

- 다음 가능한 Goal은 S1-G3 Active Cashout 논리다.
- 실제 Main mount와 simulation wiring은 선언된 Integration Goal에서 처리해야 한다.

## 2026-08-09 — S1-G3 Active Cashout 논리

Owner: Core
Branch: `main` working tree

### 작업

- ScoreZone을 지난 공을 Active Cashout으로 한 번만 처리하고 S1 점수를 기록하는 Core 경계를 구현했다.

### 변경

- `BallSimulationManager`: paddle collision provider 소비, ScoreZone command 처리, cashout signal, runtime reset.
- `ScoreLedger`: 모든 점수 이벤트를 stage/run에 같은 amount로 한 번씩 반영하고 score signal 및 reset 제공.
- Cashout 자동검증: 비활성화, 중복 방지, 점수 source-of-truth, 슬롯 재사용, reset 정합성.

### 확인

- Primary `godot` MCP validate 4/4.
- Godot 4.7.1 headless: exit 0, `S1_G3_VERIFIED cashouts=1 stage_score=1 run_score=1 reused_slot=1 reset=clean`.

### Codex

- HUD, Stage, Time Bonus, item modifier는 구현하지 않았다. S1 local level/time bonus는 계약대로 0이다.

### 다음 작업 / 주의

- S1-G4와 S1-G5의 공개 API가 준비되면 S1-G6 Integration에서만 Main을 조립한다.

## 2026-08-09 — S1-G1 arcade physics 계약 복구

Owner: Core
Branch: `main` working tree

### 작업

- 새 계약에 맞춰 지속적인 downward gravity를 제거하고, 자유 이동 중 velocity가 유지되는 중앙 SoA simulation으로 복구했다.

### 변경

- `BallSimulationManager`: 좌·우 경계에 더해 상단 반사 경계를 추가하고 하단은 계속 열어 두었다.
- `s1_g1_verification`: 100공/slot reuse 검증을 유지하면서 free-flight velocity·position 보존과 상단 반사를 검증한다.

### 확인

- Godot 4.7.1 headless verification: exit 0.
- Primary `godot` validate: simulation script, verification script, test scene 3/3 valid.

### 다음 작업 / 주의

- S1-G2에서 Paddle 접촉이 runtime speed를 변화시킬 수 있는 기존 계약과 cap을 재검증한다.

## 2026-08-09 — S1-G2 runtime speed 계약 복구

Owner: Core
Branch: `main` working tree

### 작업

- 기존 Paddle의 각도·접촉 위치·이동속도 반사식을 유지하고, 현재 공 속도가 interaction으로 바뀌며 tuning cap을 넘지 않는지 재검증했다.

### 변경

- `reflection_test_scene`: 동시 A/D+방향키 입력, 각도·접촉 위치·패들 이동의 방향 변화에 더해 runtime speed 변화와 high-speed reflection cap을 검사한다.

### 확인

- Godot 4.7.1 headless verification: exit 0.
- Primary `godot` validate: Paddle script/scene와 reflection test scene 3/3 valid.

### 다음 작업 / 주의

- S1-G3에서 열린 하단 Active Cashout과 ledger 1회 반영을 gravity 0 경로로 회귀 검증한다.

## 2026-08-09 — S1-G3 Active Cashout gravity 0 회귀

Owner: Core
Branch: `main` working tree

### 작업

- Active Cashout 및 ledger 경계를 변경하지 않고, 중력 없는 이동에서 열린 하단만 Cashout임을 다시 검증했다.

### 변경

- `s1_g3_cashout_verification`: 필드 내부의 무상호작용 공이 정지 상태를 유지하는 확인을 추가했다.

### 확인

- Godot 4.7.1 headless verification: exit 0.
- Primary `godot` validate: simulation/ledger/test script/test scene 4/4 valid.

### 다음 작업 / 주의

- 다음은 Integration-owned S1-G6로 Main runtime에서 새 arcade physics Shared Skeleton을 다시 검증한다.

## 2026-08-09 — S1-G1~G3 Lv1 small-snow tuning 회귀

Owner: Core
Branch: `main` working tree

### 변경

- G1 verification은 Lv1 visual/collision radius 2와 160 world units/s free-flight speed를 확인한다.
- G3 cashout verification은 Lv1 radius 2를 전달해 열린 하단, slot reuse, ledger 1회 반영을 회귀한다.
- Paddle 구현과 900 world units/s cap은 유지하고 G2 runtime speed/cap 검증을 다시 실행했다.

### 확인

- Godot 4.7.1 headless: S1-G1/G2/G3 각각 exit 0.
- Primary `godot` validate: 각 Goal의 관련 script/scene 3/3 valid.

### 다음 작업 / 주의

- Spawn scalar와 아래쪽 반구 방향 적용은 Integration-owned GameManager를 다루는 S1-G6에서만 수행한다.

## 2026-08-09 — S1-G2 Mouse Paddle A/B 및 keyboard rotation 회귀

Owner: Core
Branch: `main` working tree

### 변경

- Mouse X는 Paddle target X를 갱신하고, Paddle은 기존 `move_speed = 460` cap 및 field clamp 안에서 실제로 이동한다.
- 매 physics tick 실제 position delta로 `linear_velocity`를 계산해, 반사에는 raw mouse delta가 아닌 clamp된 Paddle velocity만 사용한다.
- Wheel은 tuning 가능한 `mouse_wheel_step_degrees = 5`로 기존 shared angle state를 바꾸며, A/D와 ←/→ keyboard fallback은 유지했다.
- target motion, wheel shared angle, mouse velocity 차이와 reflection 반영을 검사하는 `paddle_mouse_test`를 추가했다.

### 확인

- Primary `godot` validate: Paddle script, Main scene, mouse test scene 3/3 valid.
- Primary Main runtime: Mouse X target 이동, Wheel angle 증가, ← 단독 회전, A+→ 동시 이동/회전, Pause/Retry reset, runtime error 0 확인.

### 다음 작업 / 주의

- Web release export는 clean 상태로 생성됐으나 현재 Chrome automation이 Canvas/WebGL을 제공하지 않아 Mouse/Wheel browser interaction은 Integration 검증 대기다.

## 2026-08-09 — S1-G2 bilateral Paddle / faster Mouse A/B

Owner: Core
Branch: `main` working tree

### 변경

- 기존 top/front-only 조건을 양면 회전 OBB 충돌로 교체했다. OBB closest point와 실제 contact normal을 구하고, 공과 capped Paddle impact velocity의 상대속도가 그 면을 향할 때만 반사한다.
- 공 중심이 Paddle OBB 안에 든 경우에는 상대속도 반대 면 normal을 사용해 penetration/tunneling 후의 방향 가정을 제거했다. correction은 선택한 면의 바깥으로 적용한다.
- Mouse target은 `mouse_move_speed = 1200`으로 추적하되 keyboard `move_speed = 460`은 유지했다. 실제 `linear_velocity`는 그대로 기록하고 반사에는 `maximum_impact_velocity = 900`으로 cap한 값만 사용한다.
- Wheel 5°와 keyboard rotation은 shared angle state에 계속 누적되며 `wrapf`는 표현만 정규화한다. 회전 입력 clamp는 제거했다.
- 기존 reflection test를 외부 script 기반 bilateral test로 교체하고 mouse test에 360° 이상 회전 검증을 추가했다.

### 확인

- Godot 4.7.1 headless reflection/mouse tests: exit 0.
- Godot 4.7.1 headless S1-G1 simulation 및 S1-G3 Active Cashout regression: 각각 exit 0.
- Primary `godot` validate: Paddle, two test scripts/scenes, Main 6/6 valid.
- Primary Main runtime: 0°/90°/180°/270°의 양면 반사 모두 확인. 빠른 Mouse movement 실제 velocity 1200, slow 200; 반사 X 성분은 135 대 30. field right clamp 980 유지. 365° Wheel 뒤 internal equivalent angle 5° 확인.

### 다음 작업 / 주의

- Web Canvas Mouse/Wheel input은 기존 browser tooling 제한으로 아직 `UNVERIFIED`이며 S1-G6 Integration lock이 유지된다.

## 2026-08-09 — S1-G2 direct Mouse mapping / continuous Paddle collision

Owner: Core
Branch: `main` working tree

### 변경

- Mouse X target-follow speed cap을 제거하고 Canvas/world logical X를 physics tick Paddle X에 직접 반영하며 회전 extent로 field clamp한다.
- Paddle은 previous/current transform, signed pre-wrap angle displacement, center linear velocity 및 angular velocity를 기록한다.
- 중앙 simulation은 공의 tick trajectory와 Paddle transform을 사용해 translation relative TOI와 rotation adaptive subdivision을 수행한다. 가장 이른 양면 접촉 하나만 commit하고 separation/contact lock으로 중복 반사를 막는다.
- contact point 속도는 `linear + omega × r`를 합산한 뒤 `maximum_impact_velocity = 900`에서 한 번 cap한다. 최종 ball reflection cap은 유지한다.
- Pause/Retry reset은 transform history와 contact lock 배열을 함께 초기화한다. reflection/mouse tests는 direct mapping·translation sweep·rotation sweep을 검사하도록 갱신했다.

### 확인

- Primary `godot` validate: Paddle, simulation, Main, reflection test scene, mouse test scene 5/5 valid.
- Primary `godot` runtime test scenes: reflection 및 mouse tests 모두 exit 0. 종료 시 bridge shutdown warning만 있고 test/runtime script error는 없었다.
- Main runtime: direct Mouse transform, translation sweep hit, rotation sweep grid 35 hits, signed angular velocity `15.708 rad/s`, Pause/Retry 후 position `(800,760)`, linear/angular velocity `0`, runtime error 0 확인.
- Main runtime stress: 100 active balls, 120 simulation ticks 평균 `134.7µs/tick`.
- Native headless test process는 이 환경의 `user://logs` open failure 후 Godot signal 11로 종료되어 baseline test evidence로 사용하지 않았다. MCP validate와 Primary runtime으로 프로젝트 code 오류와 환경 문제를 구분했다.

### 다음 작업 / 주의

- S1-G6은 Web Mouse/Wheel browser input이 `UNVERIFIED — browser tooling`인 상태라 Integration verification이 남아 있다.
- S2/Merge는 시작하지 않았다.

## 2026-08-09 — S1-G2 Mouse/Keyboard position arbitration regression

Owner: Core
Branch: `main` working tree

### 변경

- Mouse absolute X가 남아 있다는 사실을 매 tick 새 입력으로 취급하지 않도록 position control source를 추가했다.
- 실제 `MouseMotion`은 Mouse source를, 실제 A/D key press는 Keyboard source를 활성화한다.
- Keyboard release는 source를 바꾸지 않으므로 Paddle은 마지막 keyboard 위치에 유지되고, 다음 실제 MouseMotion에서만 direct Mouse mapping으로 복귀한다.
- 기존 Mouse direct mapping, Wheel/방향키 rotation, continuous collision, impact/speed cap은 변경하지 않았다.
- `paddle_mouse_test`에 Mouse → Keyboard → key release 유지 → 새 Mouse motion 복귀 회귀 검증을 추가했다.

### 확인

- Primary `godot` validate: Paddle, mouse test scene, Main 3/3 valid.
- Primary mouse test runtime: exit 0, arbitration regression 포함 `S1_G2_MOUSE_VERIFIED` 출력.
- Primary Main runtime: D release 뒤 Paddle x `980`이 250ms 뒤에도 `980`으로 유지됐다. 게임 script error는 없었고 WASAPI dummy-audio fallback은 환경 경고로 분리했다.
- 최신 clean Web release export: Canvas 1280×720/focus 및 console warning/error 0. in-app browser의 pointer move/drag와 wheel scroll은 Godot Canvas에 전달되지 않아 Web Mouse/Wheel은 `UNVERIFIED — browser tooling`으로 유지한다.

## 2026-08-10 — Lv1 8 logical pixel base-ball tuning

Owner: Core
Branch: `main` working tree

### 변경

- Lv1 visual/collision radius를 `2`에서 `4 logical units`로 조정해 기본 공의 직경을 약 `4`에서 `8 logical pixels`로 두 배 늘렸다.
- Spawn speed, gravity 0, 중앙 SoA simulation, Paddle collision과 Cashout 경계는 변경하지 않았다.

### 확인

- S1-G1의 100공/slot reuse/벽 반사 검증과 S1-G3의 Cashout·ledger·reset 검증을 새 반지름으로 재실행한다.

### 결과

- Godot 4.7.1 CLI headless에서 S1-G1과 S1-G3 verification scene이 각각 exit 0으로 완료됐다.
- Primary `godot` Main runtime은 Spawn radius `4`, diameter `8`을 반환했고 runtime error는 없었다.

## 2026-08-11 — S2-G2 same-level merge candidate discovery

Owner: Core
Branch: `main` working tree

### 변경

- 중앙 SoA simulation에 `global_levels` 배열을 추가하고 spawn, slot reuse, reset과 배열 정합성을 함께 유지했다.
- Core는 `BallCatalog` instance API를 읽기 전용으로 소비해 정의된 global level만 spawn하도록 경계를 추가했다.
- active slot을 index 순서로 정렬해 같은 global level이며 반지름 합만큼 겹친 쌍만 결정적으로 반환한다. 후보 탐색은 상태를 변경하지 않으며 입력 제거·출력 생성은 S2-G3에 남겼다.

### 확인

- Primary `godot` MCP validate: simulation, S2-G2 test scene, S1-G1 regression scene 3/3 valid.
- Primary Main runtime: initial candidates `(0,1),(0,3),(1,3)`, repeated query equal, 다른 level 제외, index 1 deactivate 뒤 `(0,3)`만 유지, runtime error 0.

### 다음 작업 / 주의

- 다음 Core Goal은 S2-G3 결정적 Merge commit이다.
- native headless는 이 환경의 `user://logs` open failure와 signal 11 때문에 이번 Evidence로 사용하지 않았다.

## 2026-08-11 — S2-G3 deterministic merge commit

Owner: Core
Branch: `main` working tree

### 변경

- 같은 level 후보를 계획한 뒤 입력을 모두 deactivate하고, 그 뒤에 output을 spawn하는 두 단계 commit으로 한 공이 tick당 한 번만 소비되게 했다.
- output은 두 input의 midpoint, 다음 global level의 BallDefinition radius, mass-weighted average velocity를 사용한다. velocity는 `maximum_ball_runtime_speed = 900`에서 한 번 제한한다.
- `ball_merged(result_level, world_position)`와 최고 catalog level 생성용 `top_ball_created(global_level)` 이벤트를 제공했다.
- 새 output은 후보 snapshot 뒤에 spawn되므로 같은 commit에서 다시 Merge되지 않고 다음 physics tick부터 후보가 된다.

### 확인

- Primary `godot` MCP validate: simulation, S2-G3 test scene, S2-G2, S1-G3, S1-G1 regression 5/5 valid.
- Primary Main runtime: Lv0 pair → midpoint Lv1 velocity `(50,50)`, 같은 commit의 Lv1 재합체 없음, 다음 commit에서 1회 합체, fast output `900` cap, Lv13 pair → `top_ball_created(14)`, runtime error 0.

### 다음 작업 / 주의

- S2 Core merge contract는 완료됐다. Presentation은 S2-G5에서 `ball_merged`를 구독해 FX를 추가할 수 있다.
- Stage별 top ball 판정과 점수 ledger 연결은 S3의 별도 범위다.
- native headless는 이 환경의 `user://logs` open failure와 signal 11 때문에 이번 Evidence로 사용하지 않았다.

## 2026-08-11 — S1-G2 large-ball Paddle overlap regression

Owner: Core
Branch: `main` working tree

### 변경

- direct Mouse sweep 중 큰 Merge 공이 tick 시작부터 Paddle expanded OBB에 겹친 경우, 이전 Paddle transform에만 보정하던 fallback을 수정했다.
- sweep에서 얻은 entry normal을 유지한 채 최종 Paddle transform의 실제 surface 밖으로 공 중심을 보정한다. 따라서 Paddle이 이후 이동한 위치에 공이 다시 남지 않는다.
- S1-G2 reflection test에 radius `64` 큰 공의 좌·우 direct sweep과 90° 회전 Paddle separation 회귀를 추가했다.
- S1-G1 free-flight test의 촘촘한 probe에는 서로 다른 catalog level을 지정해 S2 Merge가 해당 S1 테스트 목적을 바꾸지 않게 했다.

### 확인

- Primary `godot` validate: Paddle, reflection/mouse/S1-G1/S1-G3 test scene, Main 6/6 valid.
- Primary reflection test: exit 0, large-overlap 포함 `S1_G2_VERIFIED`.
- Primary mouse test: exit 0, `S1_G2_MOUSE_VERIFIED`.
- Primary S1-G1: exit 0, `active=100 capacity=100 reused_slot=50`; S1-G3 test process exit 0.
- Primary Main runtime: radius 64 direct sweep에서 right normal `(1,0)`, left normal `(-1,0)`, 두 경우 모두 Paddle separation true, runtime error 0.

### 다음 작업 / 주의

- 큰 공을 실제 플레이로 다시 확인할 수 있다. 남은 S2 작업은 Presentation-owned S2-G5 Merge 표시 통합이다.
- native headless는 이 환경의 `user://logs` open failure와 signal 11 때문에 이번 Evidence로 사용하지 않았다.

## 2026-08-12 — S3-G2 Stage entry and Active Cashout runtime

Owner: Core
Branch: `codex/s3-g2-stage-runtime`

### 변경

- `StageRuntime`을 추가해 `enter_stage(definition)`에서 `stage_score = 0`, `stage_time_left = definition.base_time`을 보장하고, 이전 `run_score`는 보존했다.
- Active Cashout은 `local_ball_levels.find(global_level)`로 현재 Stage의 local level을 계산한 뒤 해당 Time Bonus를 한 번만 더한다. 따라서 Planetary의 비연속 global Lv8도 local Lv3으로 처리된다.
- `ScoreLedger.begin_stage()`를 추가해 Stage reset과 Run reset을 분리했다. Stage 종료에서 `run_score += stage_score`를 수행하는 API는 만들지 않았다.
- `StageRuntime`은 ScoreLedger를 소유하고 `score_changed`, `stage_time_changed`, `stage_entered`를 Integration/Presentation consumer에 제공한다. GameManager/HUD/StageManager 연결은 S3-G5/G6 범위로 남겼다.

### 확인

- Godot 4.7.1 CLI headless: S3-G2 verification scene exit 0.
- Primary `godot` validate: StageRuntime, ScoreLedger, S3-G2 verification script/scene, S1-G3 regression script 5/5 valid.
- Primary runtime: Ground Lv2 Cashout `+0.5s`, Planetary global Lv8(local Lv3) Cashout `+1.0s`, stage/run score `25/35`, stage time `41`, score/time signal 각각 5회를 확인했다. Main runtime debug error 0.

### 다음 작업 / 주의

- 다음 Core Goal은 S3-G3 tick 종료 중재다. 시간 차감, Merge/Top Ball, Cashout, Time Up 우선순위는 그 Goal에서 simulation과 연결한다.
- S3-G2는 기존 Main cashout wiring을 변경하지 않았다. StageManager/HUD wiring은 Integration/Presentation 소유 Goal에서 수행한다.

## 2026-08-12 — S3-G3 tick-end arbitration

Owner: Core
Branch: `codex/s3-g3-tick-arbitration`

### 변경

- `StageRuntime.process_tick(delta, top_ball_created, cashouts)`에 Stage time decrement 뒤 pending Cashout 반영, Top Ball 우선, Time Up 순서와 1회 `end_decision_requested(reason)` lock을 구현했다.
- Stage 전환은 end lock을 초기화하므로 Integration StageManager가 settlement/shift 뒤 다음 Stage를 다시 시작할 수 있다.
- Simulation Cashout signal의 두 번째 값은 임시 local level이 아니라 실제 `global_level`로 바꿨고, 첫 값은 임시 `base_cashout_score`가 아니라 BallDefinition의 base `score_value`로 바꿨다. StageRuntime이 현재 Stage의 local level을 계산하는 단일 책임을 유지한다.
- Catalog 전체 최종 level이 아니라 StageRuntime의 `current_stage.top_global_level`로 현재 Stage Top Ball을 판단한다. GameManager/StageManager/HUD wiring은 변경하지 않았다.

### 확인

- Godot 4.7.1 CLI headless: S3-G3, S3-G2, S1-G3 verification scenes 모두 exit 0.
- Primary `godot` validate: StageRuntime, simulation, S3-G3/S3-G2/S1-G3 verification artifacts 6/6 valid.
- Primary runtime: `0.03 - 0.1 + 1.0 = 0.93s` Cashout recovery는 종료 요청 없이 PLAYING, Top Ball+expired time은 `TOP_BALL_CLEAR` 한 번, 이후 tick은 lock으로 무시됨을 확인했다. Lv3 Cashout은 score `1000000`, global level `3`, active count `0`, Main runtime error 0이다.

### 다음 작업 / 주의

- 다음 Core Goal은 S3-G4 Snapshot Settlement다. settlement 중복 방지와 base score-only 계산은 그 Goal에 남았다.
- S3-G5 Integration이 simulation Cashout/merge 이벤트를 StageRuntime에 연결해야 실제 Main의 임시 1점 Ledger/HUD를 Stage 계약으로 교체할 수 있다.

## 2026-08-12 — S3-G4 snapshot settlement

Owner: Core
Branch: `codex/s3-g4-snapshot-settlement`

### 변경

- `SettlementService`를 추가했다. `settle(snapshot)`은 각 snapshot entry의 `global_level`에서 BallCatalog base `score_value`만 읽고, snapshot에 포함된 cashout modifier나 임의 score 값은 사용하지 않는다.
- 정산 직전에 `settlement_applied`를 잠가 중첩/재호출을 막고 `final_settlement_started(amount)` → score ledger 1회 반영 → `final_settlement_finished(amount)` 순서로 signal을 제공한다.
- `reset_for_stage()`만 다음 Stage의 새 정산을 허용한다. 공 snapshot 확보·reserved/deactivate·제거는 Integration S3-G5가 simulation 경계에서 수행한다.

### 확인

- Godot 4.7.1 CLI headless: S3-G4, S3-G3, S3-G2 verification scenes exit 0.
- Primary `godot` validate: SettlementService, Ledger, S3-G4 verification script/scene, S3-G3/G2 verification 6/6 valid.
- Primary runtime: Lv0+Lv1+Lv4 snapshot은 base total `100000101`, 기존 score 10 뒤 stage/run 각각 `100000111`, 두 번째 call `0`, lifecycle signal 각 1회였다. Main runtime error 0.

### 다음 작업 / 주의

- 다음 가능 Goal은 Integration S3-G5 Clear·Fail 상태 통합이다. StageManager/GameManager/Main이 StageRuntime·SettlementService·simulation snapshot을 연결해야 실제 플레이에 Stage Timer, Clear/Fail, settlement이 나타난다.
- Presentation S3-G6 Stage HUD는 S3-G2 signals를 소비해 병렬로 시작할 수 있다.

## 2026-08-12 — S4-G1 Spatial Grid

Owner: Core
Branch: `codex/s2-g5-merge-presentation`

### 변경

- global level별 Uniform Spatial Grid를 추가하고 Merge 후보 탐색의 active-ball 전수 pair 비교를 제거했다.
- 공 반지름과 같은 level의 최대 반지름으로 필요한 인접 cell 범위를 계산해 큰 공도 누락하지 않는다.
- 후보 pair는 마지막에 index 순으로 정렬해 S2의 결정적 tie-break를 유지한다.
- simulation은 read-only `candidate_count`와 `grid_cell_count` metric을 제공한다.

### 확인

- Primary `godot` validate 7/7.
- Main runtime에서 기존 S2 후보 결과, 다른 level 분리, radius 64 다중-cell overlap, sparse 200공 검증을 통과했다.
- 1,000공 단일 query에서 전수 499,500 pair 대신 candidate 2,760회, grid cell 440개, 2,942µs를 관찰했고 runtime error는 0이었다. 이 수치는 S4-G3 FPS 검증을 대신하지 않는다.
- CLI/headless는 기존 환경의 `user://logs` open failure 뒤 Godot signal 11로 종료되어 Evidence에서 제외했다.

### 다음 작업 / 주의

- 다음 Core Goal은 S4-G2 슬롯 재사용·allocation 점검이다. Grid Dictionary/Array buffer 재사용과 physics hot path allocation은 그 Goal에서 측정·개선한다.

## 2026-08-12 — S4-G2 슬롯 재사용·allocation 점검

Owner: Core
Branch: `codex/s2-g5-merge-presentation`

### 변경

- Spatial Grid의 level/cell bucket Array를 유지하고 매 rebuild에는 내용을 clear해 stable occupancy에서 재사용한다.
- simulation hot path의 Merge candidate/plan/consumed flag, Cashout index/position, render snapshot buffer를 persistent buffer로 교체했다.
- `simulation_metrics_updated(metrics)`와 read-only snapshot에 active/slot/free/grid candidate/cell/bucket 지표를 제공한다.
- logical ball은 기존 중앙 SoA slot만 사용하며 FX/Node 생성을 추가하지 않았다.

### 확인

- 256공 deactivate 후 256공 respawn에서 slot capacity가 256으로 유지됐다.
- 300공 stable occupancy를 120 physics step 반복한 뒤 grid bucket capacity가 증가하지 않았고 `grid_new_buckets=0`이었다.
- Main runtime에서 active 300, per-ball child Node 0, 기존 S2 후보 3개와 Merge 1회 결과 유지, runtime error 0을 확인했다.
- Primary `godot` validate 10/10. Godot 4.7.1 native headless에서 S4-G2/G1, S2-G2/G3, S1-G1/G3 회귀 6개 모두 exit 0.

### 다음 작업 / 주의

- 다음은 S4-G3 1,000공 stress다. FPS/physics time/allocation과 Desktop/Web 결과는 그 Goal에서 별도로 측정하며 이번 buffer 안정성 결과로 대신하지 않는다.

## 2026-08-12 — S4-G3 1,000공 stress

Owner: Core
Branch: `codex/s2-g5-merge-presentation`

### 변경

- 100/500/1,000공과 Merge OFF/ON 시나리오를 같은 조건으로 반복 측정하는 `stress_test_scene`을 추가했다.
- 결과 schema는 average/min FPS, average physics ms, candidate checks, merges, max active, memory delta, grid bucket growth다.
- stress 전용 `merge_enabled` switch와 per-step `merges` metric을 Core simulation에 추가했다. 일반 gameplay 기본값은 ON이다.
- Merge ON은 실제 Stage 밖 무한 global 성장으로 측정이 오염되지 않도록 Galactic `[10,11,12,13,14]` local radius 범위에서 측정했다.

### 결과

- Desktop: 100 OFF `60.0/60.0 FPS, 0.32ms`; 500 OFF `60.0/60.0, 1.70ms`; 1,000 OFF `58.7/55.0, 3.22ms`; 1,000 ON `35.8/34.0, 14.84ms`.
- Web actual browser: 100 OFF `60.0/60.0 FPS, 0.58ms`; 500 OFF `52.1/38.6, 2.18ms`; 1,000 OFF `27.4/20.9, 4.39ms`; 1,000 ON `19.9/15.3, 19.57ms`.
- Web Canvas 1280×720 focus 정상, console warning/error 0. Browser의 static memory monitor는 0을 반환해 allocation evidence는 Desktop delta와 S4-G2 bucket 안정성 기록을 사용한다.

### 판정 / 다음 작업

- Desktop 30 FPS 기준은 통과했지만 Web 1,000공이 기준 미달이라 S4-G3은 `IMPLEMENTED`로 유지한다.
- Merge OFF physics는 4.39ms인데 전체 평균 frame은 약 36.5ms이므로 주요 병목 후보는 `BallRenderer`의 공별 `draw_circle` 1,000회다.
- S5-G1을 시작하지 않는다. 현재 Goal 구조에는 renderer 최적화 Goal이 명시돼 있지 않으므로 계약 보완 또는 담당 범위 지시가 필요하다.

## 2026-08-12 — S4-G3 performance Gate 재기준화

Owner: Core
Branch: `codex/s2-g5-merge-presentation`

### 계약 변경과 판정

- 승인된 공 크기와 예상 동시 활성 규모를 반영해 필수 release Gate를 실제 Web 500개 최저 30 FPS 이상으로 재설정했다.
- 1,000개 측정은 삭제하지 않고 stretch/torture test로 유지하며, FPS·allocation·병목을 계속 기록한다.
- 기존 clean Web 실측에서 500공은 평균 `52.1`, 최저 `38.6 FPS`, physics `2.18ms`, console warning/error 0으로 새 필수 Gate를 통과했다.
- 1,000공 Web OFF `27.4/20.9 FPS`, ON `19.9/15.3 FPS`는 stretch 병목 evidence로 보존한다. 첫 후보는 공별 `draw_circle` 렌더 경로다.
- S4-G3과 Q-S4를 `VERIFIED`로 닫았고 S4 Exit Gate가 충족되어 S5-G1 dependency가 열렸다.

### 후속

- 일반 플레이 peak 약 300개는 초기 가정이다. 후반 Stage·FX·Black Hole 통합 후 active-ball telemetry로 다시 확인한다.
- 렌더 배치 등 추가 최적화 계약은 별도 기술 조사 결과가 들어오면 갱신하며 이번 재판정에서 runtime 구현은 변경하지 않았다.

## 2026-08-12 — S5-G2 Stage re-baselining runtime

Owner: Core
Branch: `codex/s5-g2-stage-rebaseline`

### 변경

- StageRuntime과 BallSimulationManager에 `apply_stage_definition(definition)` 및 read-only stage snapshot을 제공했다.
- Stage 적용 시 simulation 배열, Stage score/time, 종료 잠금을 초기화하고 run score만 보존한다.
- Merge 결과를 `global_level + 1` 대신 현재 Stage의 ordered `local_ball_levels` 다음 항목에서 구한다. 입력이 chain 밖이거나 top이면 Merge하지 않는다.
- S2-G3 catalog-top 회귀는 전체 catalog를 ordered chain으로 명시해 기존 contiguous baseline의 의미를 보존했다.

### 확인

- S5-G2 전용 검증에서 Planetary base/spawn `4/15`, `6→8→10`, local radius `16→32→64`, Galactic base/spawn `10/35`, Lv10 radius `64→4` 재기준화를 확인했다.
- Stage 변경 뒤 이전 active 배열 0, stage score 0, time 40, 종료 잠금 해제, run score 25 보존을 확인했다.
- Godot 4.7.1 native headless: S5-G2, S2-G3, S3-G2/G3/G4, S4-G1/G2 총 7개 verification scene 모두 exit 0.
- Primary Main runtime: Ground, base Lv0, spawn 6/s, runtime radius 4, PLAYING, active balls 정상 증가, runtime error 0.

### 제외 / 다음 작업

- StageManager/GameManager/Main 연결과 실제 Shift 상태 전이는 S5-G3 Integration 범위라 수정하지 않았다.
- Stage World, Shift animation, 완료 signal은 S5-G4 Presentation 범위다.

## 2026-08-12 — S4-G4 일반 Snowball MultiMesh renderer

Owner: Core

### 변경

- `BallSimulationManager` render snapshot에 read-only `global_levels`를 추가했다.
- `BallRenderer`는 일반 Lv0~13을 global-level별 reusable `MultiMeshInstance2D` batch로 묶고, runtime position/radius를 instance transform에 반영한다.
- Lv14 Black Hole은 기존 special fallback draw path로 남겼다. Item Ball/전환된 Black Hole runtime entity와 FX는 이 Goal 범위 밖이다.
- batch capacity는 필요할 때만 확장하고 reset 뒤 visible instance를 0으로 만든다. Stage re-baselining은 global catalog radius가 아니라 snapshot의 runtime radius를 사용한다.
- 기존 stress scene의 Merge ON 분기가 공을 생성하지 않던 문제를 고치고, Ground의 stage-local radius와 `80/12/5/2/1%` level 분포로 실제 Merge ON stress를 수행하게 했다.

### 확인

- Native headless `S4-G4` verification exit 0: 일반/특수 경로 분리, position/radius transform, reset stale-instance 제거, later-stage level 재사용을 확인했다.
- Native headless S1-G1, S2-G2/G3, S4-G1/G2 회귀 5개 모두 exit 0.
- Primary `godot` Main runtime에서 active 31개가 standard 31/fallback 0으로 batch에 들어가고 원형으로 표시되며 runtime error 0을 확인했다.
- MCP 종료 후 임시 복제본 clean Web release를 실제 in-app browser로 열었다. 500 Merge ON은 `60.0/60.0 FPS`, physics `1.44ms`, merges `0.95/frame`; 1,000 Merge ON은 `60.0/60.0 FPS`, physics `2.67ms`, merges `1.97/frame`; browser console warning/error 0이었다.

### 다음 작업 / 주의

- 이 수치는 현 개발 PC/in-app browser의 일반 공 렌더 기준이다. HUD·Stage World·대표 FX를 함께 켠 저사양 Web 결과는 S6/S9 telemetry에서 다시 확인한다.
- Presentation은 최종 global-level Texture2D/머티리얼을 batch binding으로 제공할 수 있다. 일반 공 본체를 개별 Node/Sprite로 되돌리지 않는다.

## 2026-08-14 — S8-G1 Black Hole force

Owner: Core

### 변경

- Galactic의 Lv14 Merge 결과는 일반 ball slot·Top Ball Clear 대신 최대 두 개의 SoA Black Hole runtime entity로 전환한다. entity는 Quasar(local Lv2) footprint, 위치·속도·반지름 snapshot을 제공하며 일반 Merge/Cashout/성장에서 제외된다.
- 첫 entity는 `black_hole_phase_requested`를 내고 StageRuntime은 `black_hole_phase_started(phase_id, from_rect, to_rect)` 및 `black_hole_run_end_requested` API를 제공한다. 실제 StageManager/Main 연결은 S8-G4 Integration 소유로 남겼다.
- 일반 공은 Black Hole source vector를 합산한 뒤 한 번만 `600 world units/s²` cap을 적용한다. source는 반경 240, 최대 300, `(1 - d / r)^2` falloff이고 final ball speed cap을 계속 적용한다.
- 두 Black Hole은 같은 tick의 snapshot에서 서로를 향해 최대 `450 world units/s²` mutual pull을 받는다. 하단은 전용 반사 경계다.
- local Lv0~2의 실제 접촉은 Cashout 대신 한 번 소비하고 score event를 낸다. StageRuntime은 Cashout 상당 값을 stage/run score에서 각각 0 clamp해 차감하고 run score 0에서 Run End request를 한 번 낸다.

### 확인

- Native headless `S8-G1` exit 0: 첫 Lv14 전환/Top Clear 제외/phase signal, 저등급 흡수·점수 차감·run-end request, 600 cap, 450 mutual pull, 하단 반사, 1,000공 force scenario를 확인했다. 1,000 active ball + Black Hole force 평균은 `4.190ms/tick`이었다.

## 2026-08-17 — Black Hole absorption penalty tuning correction

Owner: Core follow-up for S8-G1
Owned Files: `scripts/core/stage_runtime.gd`, `tests/simulation/s8_g1_black_hole_force_verification.gd`

### 변경 배경

- 기존 Cashout 가치 전액 차감은 Galactic 기본공 한 개만 흡수해도 직전 Stage에서 확보한 최소 Run Score를 소진할 수 있어, 첫 Black Hole 등장 직후 Game Over가 발생했다.
- 첫 Black Hole 등장 시점의 Run Score를 고정 baseline으로 한 번 저장한다.
- 흡수 패널티는 `min(absorbed_cashout_value × 0.125, phase_entry_run_score × 0.25)`로 계산한다. 두 비율은 최종 밸런스가 아닌 첫 플레이테스트 seed다.

### 회귀 계약

- 자금이 있는 Run에서 저등급 공 한 번 흡수는 즉시 Run End를 만들지 않는다.
- 고가 공 한 번의 손실은 phase-entry baseline의 25%를 넘지 않지만, 반복 손실은 Run Score를 0까지 소진하고 Run End를 정확히 한 번 요청할 수 있다.
- Stage Score와 Run Score는 같은 실제 penalty를 각각 차감하고 0에서 clamp한다. phase baseline은 이후 Cashout이나 흡수로 갱신하지 않는다.

### 확인

- Primary `godot` validate 7/7 통과.
- Primary runtime `S8-G1` verification scene exit 0: 12.5% 저등급 차감, 25% baseline cap, 반복 차감 Run End 1회와 기존 Black Hole force/하단 반사 회귀를 통과했다.
- 1,000 active ball + Black Hole force 평균은 `4.257ms/tick`이었다.

## 2026-08-17 — Black Hole pull feel tuning

Owner: Core follow-up for S8-G1

- 플레이테스트에서 Black Hole이 작은 공을 더 명확히 휘게 하도록 influence radius를 `240 → 300`, source 최대 가속도를 `300 → 450`, 두 Black Hole vector 합산 cap을 `600 → 900 world units/s²`로 조정했다.
- 기존 final Ball runtime speed cap과 Black Hole mutual pull `450`은 바꾸지 않았다.
- Primary `godot` validate 2/2 및 S8-G1 runtime verification exit 0. 1,000 active ball + force 평균은 `4.571ms/tick`이었다.
- Native headless S2-G3 Merge와 S3-G2 StageRuntime regression exit 0.
- Primary `godot` validate가 simulation, StageRuntime, S8-G1 test script/scene 4/4를 통과했고 Main runtime은 Ground/PLAYING/32 active ball, runtime error 0으로 확인했다.

### 제외 / 다음 작업

- 두 Black Hole의 terminal contact/finale lock은 S8-G2, L2→L3 frame/logical bounds activation 및 retry wiring은 S8-G4, Phase presentation은 S8-G5 범위다.

## 2026-08-14 — S8-G2 두 Black Hole 최종 충돌 runtime

Owner: Core

### 변경

- 두 Black Hole의 previous/current motion을 상대 sweep으로 검사해 earliest contact를 한 번만 확정한다. 접촉 뒤 Black Hole force와 일반 ball 이동·흡수·Merge·Cashout commit을 모두 중지한다.
- simulation은 `black_hole_finale_started(contact_snapshot)`을, StageRuntime은 한 번만 확정되는 `black_hole_finale_locked(result_snapshot)`을 제공한다. 결과에는 contact center, 두 entity의 position/velocity/radius, stage index/score, final run score가 들어간다.
- 첫·두 번째 Black Hole 생성은 terminal이 아니며, terminal은 일반 Top Ball Clear/Stage Shift를 요청하지 않는다.

### 확인

- Native headless S8-G2 verification exit 0: 두 Black Hole 생성 후 contact terminal 1회, snapshot, contact tick의 일반 Lv10 Merge 미commit, 반복 tick 중복 event 없음, regular Shift event 없음.
- Native headless S8-G1, S2-G3, S3-G2 회귀 exit 0. S8-G1 1,000 active ball force 평균 `4.135ms/tick`.
- Primary `godot` validate 4/4, Main runtime Ground/PLAYING/26 active ball/runtime error 0.

### 제외 / 다음 작업

- Result/Title/Main Menu UI는 S8-G3, Black Hole phase/finale visual은 S8-G5, Main signal wiring·logical L3 bounds·Retry reset은 S8-G4 Integration 범위다.

## 2026-08-19 — S8-G2 Result Run 통계 snapshot 확장

Owner: Core (교차 영역 변경 승인됨)

- `StageRuntime`에 Run 단위 성공 Merge 누적값과 `PLAYING` 시간 누적값을 추가했다.
- Stage 진입은 통계를 유지하고 Retry Run/Main Screen용 `reset_run_statistics()`만 초기화한다.
- Black Hole terminal snapshot의 `optional_stats`에 `merge_count`와 `run_time_seconds`를 deep-copy 가능한 값으로 고정했다.
- S8-G2 검증에서 Stage 재진입 보존, terminal snapshot 값, 기존 terminal-once/normal-commit 차단을 확인했고 Godot 4.7.1 headless exit 0이었다.

## 2026-08-20 — S3-G7 local Lv4 비종료 계약 마이그레이션

- `StageRuntime.process_tick()`에서 `TOP_BALL_CLEAR` 종료 분기를 제거했다. local Lv4와 Time Up이 같은 tick에 생성되면 Cashout 반영 뒤 `TIME_UP` 한 번으로 중재한다.
- Core verification은 Cashout 시간 회복, top-ball 비종료, same-tick Time Up, 종료 lock을 검사한다.
- Primary Godot validate와 headless verification exit 0을 확인했다.

## 2026-08-20 — 즉시 Score Clear 규칙 변경

- 사용자 최신 규칙에 따라 `StageRuntime.process_tick()`은 non-final `stage_score >= clear_score`를 Cashout 반영 뒤, Time Up보다 먼저 `SCORE_CLEAR`로 확정한다.
- local Lv4 생성은 계속 종료 사유가 아니다. clear score 미달인 경우에만 Time Up 경로를 사용한다.
- Primary validate와 S3-G3 verification scene exit 0을 확인했다. 이 환경의 직접 CLI/headless는 `user://logs` 접근 실패 뒤 Godot signal 11로 종료되어 도구 환경 문제로 분리했다.

## 2026-08-21 — S3-G9 FIRST_CONTACT producer 계약 준비

Owner: Core planning / Goal status `PENDING`

- S3-G7의 기존 증거를 local Lv4 비종료와 Score Clear 중재로 한정했다. 전용 discovery producer가 있었다고 소급하지 않는다.
- S3-G9는 승인된 여섯 `first_contact_id`, payload schema v1, process-lifetime monotonic `event_id`, Integration-issued `run_epoch`, Run seen set과 deterministic order만 소유한다.
- 기존 `ball_merged`/`top_ball_created`는 FIRST_CONTACT source가 아니며, 첫 Black Hole payload는 entity ordinal과 S8 handoff 의도만 전달한다.
- 이번 기록은 계약/Goal 준비이며 runtime 구현·테스트·Godot 검증 Evidence가 없다. 상태를 `PENDING`으로 유지한다.

## 2026-08-21 — S3-G3/G7 deadline-bounded gameplay commit

Owner: Core

- `StageRuntime.get_valid_play_delta()`로 callback 안의 실제 gameplay 구간을 `min(delta, max(stage_time_left, 0))`로 한정했다. StageManager가 그 구간만 Simulation/StageRuntime에 전달하므로 deadline을 지난 이동이나 하단 crossing은 Active Cashout과 Time Bonus가 될 수 없다.
- `0.03s`가 남은 `0.1s` callback의 pre-deadline Lv3 Cashout은 `+1.0s`로 계속 PLAYING이 되고, local Lv4는 여전히 종료 원인이 아니며 시간이 남지 않았을 때만 Time Up으로 중재된다.
- Godot 4.7.1 CLI headless S3-G2/G3/G4/G5와 S5-G3/G5/G6 회귀 exit 0, Primary `godot` validate 7/7 및 Main runtime error 0을 확인했다. MCP 종료 후 clean Web release export와 Browser gameplay/console warning·error 0도 확인했다.
