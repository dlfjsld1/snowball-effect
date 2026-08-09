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
