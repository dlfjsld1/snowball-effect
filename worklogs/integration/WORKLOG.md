# Integration Worklog

> Append-only. 실제 통합 작업, lock, 검증만 기록한다.

## Entry format

```text
## YYYY-MM-DD — Integration Goal
Owner: Integration
Branch:
Locked files:
연결한 API/Signal:
변경:
확인:
Codex:
다음 작업 / 주의:
```

## 2026-08-09 — Team lanes and Goal ownership contract

Owner: Integration
Branch: `main` working tree
Locked files: 없음 — 문서 체계 변경만 수행

### 연결한 API/Signal

- Core, Presentation, Content/Systems, Integration의 네 lane 정의
- `stage_time_changed`, `score_changed`, `cashout_completed`, Settlement, Stage Shift, Retry 요청의 초기 계약 정의

### 변경

- `docs/team/`에 역할, 소유권, Integration 계약 추가
- 43개 Goal에 Owner/Owned Files/Integration Point/Dependencies/Verification 추가
- lane별 최대 1개 `IN PROGRESS`와 Integration lock 규칙 반영
- lane별 append-only Worklog 생성

### 확인

- 43개 Goal 필수 필드 검사: 누락 0
- Goal/STATUS ID 대조: 43/43, 누락·고아 0
- Godot runtime 검증은 이 문서 작업 범위에 포함하지 않음

### Codex

- 팀 역할 초안을 현재 Slice 구조에 매핑하고 공동 접점을 Integration-owned 파일과 별도 Integration Goal로 구체화

### 다음 작업 / 주의

- S0-G1 Godot 실행 검증 전 S0-G2를 시작하지 않는다.
- S0-G2 시작 시 `project.godot`과 `scenes/main/main.tscn`을 Integration lock에 등록한다.

## 2026-08-09 — S0-G1 프로젝트 부트 검증

Owner: Integration
Branch: `main` working tree
Locked files: 없음 — S0-G1 검증 완료 후 S0-G2 lock으로 전환

### 변경

- `project.godot`과 `scenes/main/main.tscn`의 기존 부트 산출물을 Godot 4.7.1에서 실행 검증했다.

### 확인

- Godot CLI headless run: exit 0.
- Primary `godot` MCP: strict mode의 elicitation을 현재 클라이언트가 지원하지 않아 runtime launch가 거부됨.
- CLI baseline 성공 뒤 fallback `godot_fallback` debug run 성공; Godot 4.7.1 Compatibility renderer 초기화와 Main 실행을 확인했다.
- WASAPI 출력 장치 초기화 실패 후 dummy audio fallback이 있었으나 게임 runtime 오류는 없었다.

### 다음 작업 / 주의

- S0-G2가 `project.godot`과 `scenes/main/main.tscn`을 lock하고 Input Map 및 mount 계약만 변경한다.

## 2026-08-09 — S0-G2 입력과 공유 씬 골격

Owner: Integration
Branch: `main` working tree
Locked files: `project.godot`, `scenes/main/main.tscn` — verification pending

### 연결한 API/Signal

- Core 계약: `paddle_move_left`, `paddle_move_right`, `paddle_rotate_left`, `paddle_rotate_right` Input Map과 `PlayField/SimulationMount`, `PlayField/PaddleMount`.
- Presentation 계약: `UI/HUDMount`.

### 변경

- 여섯 Input Map action(`A`, `D`, `←`, `→`, `Esc`, `R`)을 프로젝트 설정에 등록했다.
- Main에 `StageWorld`, `PlayField`, Simulation/Paddle mount, UI/HUD mount를 추가했다.

### 확인

- Godot 4.7.1 CLI editor load와 Main headless run이 모두 exit 0.
- Primary `godot` MCP `get_scene_tree`로 mount tree를 확인했다.
- Primary runtime launch는 strict mode가 지원되지 않는 elicitation을 요구해 실패했다. 따라서 동시 입력 event log는 `UNVERIFIED — MCP/tooling issue`로 남긴다.

### 다음 작업 / 주의

- strict elicitation을 지원하는 MCP client에서 Primary runtime launch와 A/D+방향키 동시 입력을 한 번 확인한 뒤 S0-G2를 `VERIFIED`로 전환한다.
- 검증 전에는 S0-G3 또는 S1 Goal을 시작하지 않는다.

## 2026-08-09 — MCP elicitation 정책과 S0-G2 검증 계약 정리

Owner: Integration
Branch: `main` working tree
Locked files: 없음 — 문서/로컬 MCP 설정 작업

### 변경

- Erodenn 공식 README와 Security Model에 맞춰 Codex Primary 환경변수를 `GODOT_MCP_STRICT=true`에서 `GODOT_MCP_DISABLE_ELICITATION=true`로 변경했다.
- 특정 MCP 제품이 아니라 관찰 가능한 결과를 Verification 기준으로 삼는 공통 Gate를 추가했다.
- S0-G2는 Input Map 정의, mount tree, 프로젝트 load/run을 검증하고, 실제 이동+회전 동시 입력은 입력 소비자가 구현되는 S1-G2에서 검증하도록 시점을 이동했다.

### 확인

- S0-G2의 기존 Evidence가 수정된 계약을 충족해 `VERIFIED`로 전환하고 Integration lock을 해제했다.
- 게임 Source, Scene, `project.godot`은 변경하지 않았다.
- 로컬 MCP 환경변수 변경은 새 MCP 프로세스가 시작되는 Codex 재시작 후 적용된다.

### 다음 작업 / 주의

- 재시작 전 현재 세션에서 Primary runtime을 우회 검증하지 않는다.
- 재시작 후 Primary `godot` runtime 연결을 별도 확인한다.
- 다음 구현 Goal은 S0-G3이지만 이번 작업에서는 시작하지 않는다.

## 2026-08-09 — S1-G6 Pause와 Restart 통합 / Shared Skeleton

Owner: Integration
Branch: `main` working tree
Locked files: `project.godot`, `scenes/main/main.tscn`, `scripts/core/game_manager.gd` — 검증 완료 후 해제

### 연결한 API/Signal

- `BallSimulationManager.set_paddle_collision_provider(Paddle)`
- `cashout_completed` → `ScoreLedger.apply_score_event`
- `score_changed`/`ball_count_changed` → `Hud`
- `PauseMenu.pause_requested/retry_requested` → `GameManager`
- `reset_runtime()`과 `reset_view()`를 Retry 한 경로에서 조정

### 변경

- Main에 Simulation, Renderer, Paddle, ScoreLedger, HUD, PauseMenu를 실제 조립했다.
- GameManager가 6/s 기본 공 생성과 공개 API wiring, Pause, Retry를 담당하는 얇은 coordinator가 됐다.
- 통합 중 발견한 deferred-ready 순서, Paddle 초기 transform, S1-G1 Cashout 회귀를 각 Owner 경계에서 국소 수정했다.

### 확인

- Godot 4.7.1 clean process: S1-G1~G5와 Main 300 physics frame 모두 exit 0, stderr 0.
- Primary MCP actual runtime: 동시 입력, Paddle 반사, Cashout/HUD, Pause 정지, Retry 2회 clean reset 확인.
- 100 active balls desktop runtime: 165 FPS, capacity 100, runtime error 0.
- Web release export exit 0. 실제 브라우저에서 Canvas 1280×720/focus, D+→, Esc Pause, R Retry, console warning/error 0.

### Codex

- Merge, Stage Timer/Clear, Settlement, Scale Shift, Item, FX를 구현하지 않았다.
- Integration lock을 해제하고 Shared Skeleton 기준선에서 구현을 중단했다.

### 다음 작업 / 주의

- 다음 기존 Goal은 S2-G1이다. 완료 뒤 S2-G2와 S2-G4를 병렬화한다.
- 기존 Web preset `all_resources`가 `build/`를 재패킹하는 알려진 문제는 유지된다. 팀 공유 전 별도 Content/Systems 유지보수 후보지만 현재 Goal 범위에서는 수정하지 않았다.

## 2026-08-09 — S1-G6 arcade physics Shared Skeleton 재검증

Owner: Integration
Branch: `main` working tree
Locked files: `project.godot`, `scenes/main/main.tscn`, `scripts/core/game_manager.gd` — verification 완료 후 해제

### 연결한 API/Signal

- 기존 `GameManager`의 아래 방향 initial velocity spawn과 `BallSimulationManager`의 중앙 SoA simulation 연결을 그대로 사용했다.
- `cashout_completed` → `ScoreLedger`, HUD, Pause/Retry reset 연결을 회귀 검증했다.

### 변경

- Integration-owned runtime 파일은 변경하지 않았다. Core가 복구한 gravity 0·상단 반사·속도 보존 계약이 기존 Main 조립에서 정상 소비되는지 검증만 수행했다.

### 확인

- Godot 4.7.1 CLI headless Main 300-frame smoke: exit 0.
- Primary `godot` validate: GameManager, simulation, Paddle, Main scene 4/4 valid.
- Primary 실제 runtime: 83개 active ball에서 initial velocity `(-26.39, 99.04)` 확인, D+Right 250ms 후 Paddle x `800→915`, rotation `0→0.6545`; Cashout/HUD, Pause 정지, Retry reset, runtime error 0.
- clean Web release export: exit 0. Chrome local HTTP runtime에서 Canvas 렌더, Canvas focus와 D/Right key 전달, browser console warning/error 0.

### 다음 작업 / 주의

- Primary MCP가 실행 중인 상태의 첫 Web export는 bridge가 all-resources export에 포함되어 browser console에 TCP listen error를 냈다. MCP 종료 뒤 다시 export한 clean build에서는 재현되지 않았다. 기존 `all_resources` export 범위 이슈는 여전히 별도 유지보수 항목이다.
- Shared Skeleton은 팀 공유 가능한 상태이며 다음 기존 Goal은 S2-G1이다. 이 작업에서는 S2를 시작하지 않았다.

## 2026-08-09 — S1-G6 Lv1 Spawn tuning 통합

Owner: Integration
Branch: `main` working tree
Locked files: `project.godot`, `scenes/main/main.tscn`, `scripts/core/game_manager.gd` — verification 완료 후 해제

### 변경

- 잘못된 전역 meter-to-world-unit 중간 문서 계약을 제거했다. `1.0 m/s`는 Lv1 눈발 움직임의 design reference이고, runtime은 logical world units/s로만 tuning한다.
- `GameManager`에 Lv1 radius 2, Spawn speed 160 world units/s, 아래쪽 반구 angle 20°를 한 곳의 export tuning으로 추가했다.
- 기존 component velocity range, Spawn rate, 중앙 SoA simulation, Paddle/Cashout/HUD/Pause wiring은 유지했다.

### 확인

- Godot 4.7.1 CLI headless Main 300-frame smoke: exit 0.
- Primary `godot` validate: GameManager, simulation, Main scene 3/3 valid.
- Primary runtime: Spawn sample radius 2, speed 160, positive Y 확인; D+Right 후 Paddle 이동/회전, runtime speed 160~327.93 관찰; Pause 정지와 Retry reset 확인. MCP 임시 관찰 스크립트 1건의 type inference parse error는 게임 runtime 오류와 분리했다.
- MCP 종료 뒤 clean Web release export: exit 0. Chrome local HTTP에서 작은 Lv1 Canvas 렌더, Canvas focus와 D/Right input, console warning/error 0.

### 다음 작업 / 주의

- `maximum_reflection_speed = 900`은 이번에도 유지한 playtest cap이며 최종 밸런스가 아니다.
- Shared Skeleton은 팀 공유 가능하다. 다음 기존 Goal은 S2-G1이지만 이 작업에서는 시작하지 않았다.

## 2026-08-09 — S1-G6 keyboard rotation Input Map 복구

Owner: Integration
Branch: `main` working tree
Locked files: `project.godot` — Web browser verification 완료 전 유지

### 변경

- Main runtime의 `←/→` 불능 원인은 Paddle 소비/transform이 아니라 Input Map의 잘못된 keycode였다.
- `paddle_rotate_left/right`를 Godot 4.7.1의 `KEY_LEFT = 4194319`, `KEY_RIGHT = 4194321`로 바로잡았다.

### 확인

- Primary Main runtime에서 `←` 단독 rotation `0 → -0.5236`, A+→ 동시 입력에서 x `800 → 715.67`, rotation `0 → 0.47997`을 관찰했다.
- Clean Web release export는 생성됐고 local browser console warning/error는 0이었다. 다만 현재 Chrome automation의 Canvas/WebGL 미지원으로 Canvas와 Mouse/Wheel 실제 입력 증명은 남아 있다.

### 다음 작업 / 주의

- `S1-G6` Integration lock은 Web Canvas interaction 확인 전까지 유지한다. S2는 시작하지 않는다.

## 2026-08-09 — S1-G6 최신 Web 수동 검증 완료

Owner: Integration
Branch: `main` working tree
Locked files: 없음 — 검증 완료 후 unlocked

### 변경

- 구현·Scene·설정 변경 없이 최신 clean Web release export의 사용자 수동 Chrome 검증 증거를 기록했다.

### 확인

- Canvas 정상 렌더.
- Mouse X direct Paddle 이동, Mouse Wheel 자유회전, A/D Keyboard 이동 정상.
- A/D release 뒤 Paddle은 현재 위치를 유지하고, 이후 실제 MouseMotion에서만 Mouse control로 복귀.
- Paddle 이동/회전 충돌, Pause/Retry 정상.
- Browser console game error 0.

### 다음 작업 / 주의

- S1-G6과 S1 Shared Skeleton은 `VERIFIED`다.
- 다음 기존 Goal은 S2-G1 공·점수 데이터다. 이 검증 작업에서는 S2를 시작하지 않았다.

## 2026-08-09 — Shared Skeleton baseline handoff

Owner: Integration
Branch: `main` working tree
Locked files: 없음 — S1 종료 상태 유지

### 변경

- S1-G1~G6의 최종 `VERIFIED` 상태, Owner Worklog, 최신 Chrome Web 수동 검증 증거를 감사했다.
- 루트 README를 현재 Shared Skeleton의 실제 플레이 범위와 조작으로 갱신했다.
- baseline에는 source, scenes/config, tests, docs, README, Worklog만 포함하도록 Git hygiene를 확인했다.

### 확인

- `.godot/`, `.mcp/`, `build/`는 `.gitignore`로 제외된다.
- S2/Merge나 future idea 구현은 baseline에 포함하지 않는다.
- 현재 `project.godot` renderer 설정은 `gl_compatibility`이며 README도 그 실제 설정을 따른다.

### 다음 작업 / 주의

- baseline commit/push 뒤 팀원은 이 기준선에서 S2-G1을 시작할 수 있다.

## 2026-08-10 — Lv1 base-ball size tuning integration

Owner: Integration
Branch: `main` working tree
Locked files: `scripts/core/game_manager.gd` — tuning 반영 후 해제

### 변경

- Integration-owned GameManager의 Lv1 Spawn radius를 `4 logical units`로 변경했다. 따라서 visual/collision diameter는 약 `8 logical pixels`다.
- Spawn 위치 계산은 동일 tuning 값을 소비하므로 필드 경계 안에서 기존과 같은 방식으로 생성된다.

### 확인

- Core S1-G1/G3 회귀와 Main runtime 관찰 후 STATUS evidence를 갱신한다.

### 결과

- Godot 4.7.1 CLI headless S1-G1/G3 회귀가 각각 exit 0으로 완료됐다.
- Primary `godot` Main runtime에서 Lv1 Spawn radius `4`, diameter `8`, runtime error 0을 확인했다.

## 2026-08-10 — Lv1 8px base size approved

Owner: Integration
Branch: `main` working tree
Locked files: 없음

### 변경

- 팀 플레이테스트 결정을 반영해 Lv1 visual/collision diameter `8 logical pixels`를 현재 Shared Skeleton의 승인된 기본 크기로 문서화했다.

### 확인

- 구현값은 `GameManager.lv1_ball_radius = 4`와 일치한다.
- 별도 gameplay 기능이나 Goal 상태는 변경하지 않았다.

## 2026-08-11 — Meeting design contract update

Owner: Integration
Branch: `main` working tree
Locked files: 없음

### 변경

- HUD 기본 정보를 점수, 시간, 현재 활성 아이템, 일시정지, 현재 Stage 공 족보로 정리했다.
- Pause modal의 재개·다시 시작·설정·메인 화면과 S8 Title/Main UI 연결을 문서화했다.
- 초기 global 공 15종과 Stage별 local 공 4~5종 방향을 S2 데이터 계약에 반영했다.
- Item Ball은 현재 Stage의 3단계 이상(`local_level >= 2`) Snowball hit을 누적해 파괴하며, 최종 파괴 뒤 CUT-IN과 1회 아이템 activation으로 이어지는 계약으로 갱신했다.
- Scale Shift 때 Stage별 공 족보도 새 목록으로 교체하도록 S5 Presentation 계약에 반영했다.

### 확인

- 게임 코드, Scene, 테스트, Goal 상태를 변경하지 않았다.
- 문서 diff check를 통과했다.

## 2026-08-12 — Galactic Black Hole terminal loop contract

Owner: Integration
Branch: `codex/docs-black-hole-terminal-loop`
Locked files: 없음

### 변경

- 첫 Lv14 Black Hole Ball을 이동 Black Hole runtime 기믹으로 전환하고 L2→L3 Play Field 확장 뒤 Galactic gameplay를 계속하는 계약으로 정리했다.
- Black Hole의 하단 반사, 비성장·일반 Merge 제외, `local_level <= 2` 공 흡수와 Cashout 상당 점수 차감, run score 0 Game Over를 확정했다.
- 일반 공 대상 source별 pull `300`, 합산 cap `600`, Black Hole 상호 pull `450 world units/s²`를 초기 tuning seed로 기록했다.
- 두 Black Hole 접촉 뒤 mutual orbit·폭발·HUD 제거·`SNOWBALL EFFECT`·Clear Score·Main Menu로 이어지는 terminal flow를 S8 Goal/Quality Gate/Presentation 문서와 동기화했다.

### 확인

- 게임 코드, Scene, Resource, 테스트와 Goal 상태는 변경하지 않았다.
- `git diff --check`를 통과했다.

## 2026-08-12 — S3-G5 Stage clear/fail integration

Owner: Integration
Branch: `codex/s3-g5-clear-fail-integration`
Locked files: `scripts/core/stage_manager.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `tests/integration/**`

### 변경

- Main에 `StageManager`를 연결했다. StageManager가 simulation의 독립 physics process를 멈추고 Stage time decrement → simulation step → pending Cashout/Top Ball arbitration 순서로 한 tick을 소유한다.
- 종료 요청은 Top Ball의 `CLEAR_LOCKED→SETTLING→CLEARED`, Time Up의 `TIME_UP_LOCKED→SETTLING→CLEARED/FAILED`로 즉시 중재한다. Settlement snapshot은 public simulation state에서 한 번 만들고, 정산 뒤 해당 active slots만 제거한다.
- GameManager는 임시 ScoreLedger 직접 연결 대신 StageManager의 shared ledger를 HUD에 전달한다. Retry는 StageManager를 통해 Ground, score, timer, simulation slot을 함께 초기화한다.
- Stage data의 Ground spawn rate를 GameManager가 Stage change signal로 읽는다. Stage shift/다음 Stage 진입, HUD stage/time label, settlement presentation은 이후 S5/S3-G6 범위로 남겼다.

### 확인

- Godot 4.7.1 CLI headless: S3-G5 integration/S3-G4 settlement, S1-G1, S1-G3, Paddle reflection verification scene exit 0.
- Primary `godot` validate: StageManager, GameManager, Main scene, S3-G5 integration script/scene 5/5 valid.
- Primary Main runtime: Ground PLAYING에서 time/score 누적, keyboard Retry 후 `retry_count=1`·score 초기화·Ground timer 재시작을 확인했다. Manual Main probes는 Lv3 pair→Lv4 Top Ball Settlement `100000000`/CLEARED/active 0, time `0.03→-0.07` without Cashout→FAILED를 확인했고 runtime error 0이다.

### 다음 작업 / 주의

- S3-G6 Presentation이 Stage name, time, clear target, stage/run labels와 genealogy를 HUD에 표시해야 현재 임시 `STAGE {score}` 표기가 완전히 교체된다.
- S5-G3 이후에만 다음 Stage/Scale Shift를 자동 진행한다. S3-G5는 Clear/Fail settlement state까지만 통합한다.

## 2026-08-12 — S5-G3 temporary Scale Shift integration

Owner: Integration
Branch: `main` working tree
Locked files: `scripts/core/stage_manager.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `tests/integration/**`

### 변경

- `StageManager`에 `CLEARED→SHIFTING` 전이와 `stage_shift_started(next_definition, shift_id)`를 추가했다. 정산이 끝난 뒤 다음 Stage가 있을 때만 shift를 시작한다.
- Presentation 완료는 `accept_stage_shift_presentation_finished(shift_id)` API로 수용한다. matching id 하나만 다음 catalog Stage로 진입하고 stale/duplicate id는 무시한다.
- S5-G4 Presentation이 아직 없으므로 Main Scene에서만 `auto_complete_shift_presentation`을 켰다. 이 임시 adapter는 deferred 한 번 같은 완료 API를 호출하며 gameplay/animation을 만들지 않는다.
- S3-G5 기존 clear 검증은 확장된 상태 흐름에 맞게 settlement 이후 `SHIFTING` lock을 기대하도록 갱신했다.

### 확인

- Godot 4.7.1 CLI project load exit 0. 이 환경의 direct headless scene은 `user://logs` 권한 문제로 signal 11이 나므로 test-run evidence에는 사용하지 않았다.
- Primary `godot` validate로 StageManager, Main, S5-G3 test script/scene 4/4 valid.
- S5-G3 verification scene과 S3-G5 regression scene은 각각 exit 0으로 완료됐다. 종료형 test scene이라 MCP bridge가 준비되기 전에 정상 종료했다.
- Primary Main runtime에서 Ground top ball을 만들어 `SHIFTING`, active balls `0`, pending shift id `1`을 확인하고 deferred adapter 뒤 Planetary `PLAYING`, index `1`, pending `-1`을 확인했다. runtime error `0`.

### 다음 작업 / 주의

- Presentation S5-G4가 `stage_shift_started`를 구독하고 화면 전환 뒤 `stage_shift_presentation_finished(shift_id)`를 Integration API에 연결하면 Main의 임시 adapter를 제거한다.

## 2026-08-12 — S5-G4 presentation handoff documented

Owner: Integration
Branch: `codex/s5-g4-presentation-handoff`
Locked files: 없음

### 변경

- S5-G3의 임시 자동 완료 adapter가 S5-G4 Presentation 구현을 전제로 한 stopgap임을 S5 Slice와 Integration Contract에 명시했다.
- Presentation이 시작/완료에 사용할 `shift_id`와 state 변경 금지 경계를 적고, 실제 Presentation 연결 시 Integration이 adapter를 제거하는 책임을 기록했다.

### 확인

- 문서 변경만 수행했고 runtime 파일·Goal 상태는 바꾸지 않았다.

## 2026-08-13 — S5-G4-I Frame playable wiring

Owner: Integration
Branch: `ui-design`
Locked files: `scenes/main/main.tscn`, `scripts/core/game_manager.gd`, `scenes/ui/pause_menu.tscn`, `scripts/ui/pause_menu.gd`, `tests/integration/s5_g4_frame_playable_verification.*`

### 변경

- Main UI에 승인된 `GameplayFrame`을 실제 instance로 배치했다.
- Stage index 0/1/2를 L0/L1/L2 profile에 연결하고 frame opening Rect를 Simulation 경계, Paddle clamp, Play Field Backdrop의 단일 적용값으로 사용했다.
- Stage/Time/세로 공 족보와 현재 Stage Score를 좌우 CRT에 배치하고, Pause/Retry를 하단 우측 CRT 안으로 이동했다.
- L3 profile은 일반 Stage에 연결하지 않고 Galactic 내부 Black Hole 국면용으로 보존했다.
- 기존 S3-G6 검증의 동적 Node 이름 누락으로 발생하던 거짓 양성을 두 줄 수정했다.

### 확인

- Godot 4.7.1 CLI: S1-G4 HUD, S1-G5 Pause, S3-G6 Stage HUD, S5-G3 Shift, S5-G4 frame kit, S5-G4 playable wiring 검증 모두 exit 0 / `SCRIPT ERROR`·`ERROR:` 0건.
- Desktop Main을 실제 실행해 공이 L0 frame opening 안에서 생성·반사·Merge/Cashout되고 CRT HUD와 Pause/Retry가 표시되는 화면을 확인했다.
- 성능 수치는 이번 연결 작업에서 별도 측정하지 않았다. S5 Stage World·FX 통합 뒤 S9 telemetry에서 재측정한다.
- Stage별 배경과 실제 Shift animation, 임시 auto-complete adapter 제거는 이번 wiring에서 제외했다.

## 2026-08-13 — S5-G4-I Cashout corridor / 하단 CRT 정렬

- `GameManager`가 물리 Play Field Rect와 프레임 내부의 시각적 Cashout Rect를 각각 적용하도록 연결했다.
- HUD는 좌우 wing rect를 유지하고 PauseMenu는 별도의 bottom-panel rect를 받아 중앙 베젤 하단과 정렬되도록 했다.
- Integration lock은 기존 S5-G4-I 범위(`scenes/main/main.tscn`, `scripts/core/game_manager.gd`, Pause UI 및 playable verification)에 유지했다.
- Godot CLI playable verification과 Pause/HUD/Scale Shift 회귀 검증이 모두 통과했다.

## 2026-08-14 — S5-G4I Shift presentation handoff wiring

- Locked only `scripts/core/game_manager.gd` and `scenes/main/main.tscn` for the handoff.
- Replaced the temporary `auto_complete_shift_presentation` path with explicit `stage_shift_started` → Presentation → `stage_shift_presentation_finished(shift_id)` → `accept_stage_shift_presentation_finished(shift_id)` wiring.
- Added the Presentation-owned Stage World scene to the existing `StageWorld` mount and passed read-only layout dependencies to PresentationManager.
- Verification: completion does not advance the Stage early; matching completion advances Ground→Planetary once; stale completion is rejected; S5-G3 state mediation, S5-G4 frame integration, S3-G6 HUD, and S1-G5 Pause regressions pass under Godot 4.7.1 CLI.
- Integration lock released. Full Ground→Planetary→Galactic Desktop/Web completion is intentionally left to S5-G5.

## 2026-08-14 — S5-G5 3-Stage integration

Owner: Integration
Locked files: `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s5_g5_*`, `.gitignore`

### 변경

- Stage 진입 시 Simulation의 레벨 목록만 바꾸던 연결을 기존 `apply_stage_definition()` API로 교체해 stage index/base/top/spawn snapshot과 배열 reset을 함께 적용했다.
- HUD source binding에 StageManager를 명시적으로 전달해 Main tree 지연 탐색 의존을 제거했다.
- Debug build에서만 `F6` Top Ball Clear와 `F7` Time Up Score Clear를 제공했다.
- Ground Top Ball→Planetary, Planetary Score Clear→Galactic, Retry→Ground를 한 번에 검증하는 S5-G5 integration scene을 추가했다.
- 로컬 Godot 4.7.1 CLI와 export template은 `.tools/`, `.godot-user/`에 두고 Git/export 대상에서 제외했다.

### 검증

- Godot 4.7.1 CLI: `S5_G5_THREE_STAGE_VERIFIED route=top_ball+score_clear shifts=2 retry=ground ground_stage_time=44.77 planetary_cashout_time_gain=4.00`.
- S5-G2/G3/G4 handoff, S3-G6 HUD, S5-G4 frame 회귀를 포함한 6개 scene이 exit 0이다.
- Native Main smoke는 OpenGL 3.3 / Intel Arc 130V에서 exit 0이다.
- Web Debug/Release export는 각각 성공했다. PCK `4,842,624 bytes`, WASM Debug `37,900,721 bytes`, Release `39,513,091 bytes`다.
- 로컬 HTTP에서 Debug HTML/JS/WASM/PCK와 Release HTML/JS가 200을 반환했다.
- 인앱/확장 Browser 연결 목록이 비어 실제 Canvas, F6/F7 입력, console error는 확인하지 못했다. 따라서 S5-G5는 `IMPLEMENTED`, Q-S5 Web Gate는 `UNVERIFIED — browser tooling unavailable`로 남긴다.
- 실제 FPS와 플레이 밸런스 체류 시간은 측정하지 않았다. `44.77s`는 자동 강제 경로의 Ground 잔여 Stage 시간이다.

### 제외

- Galactic 첫 Lv14 Black Hole 전환과 finale는 S8 범위이며 구현하지 않았다.
- Browser 검증 완료 전 S5-G5를 `VERIFIED`로 올리지 않았다.

Integration lock released.

## 2026-08-14 — S5-G5 user Chrome Web evidence

Owner: Integration
Locked files: 없음

### 확인

- 사용자가 `build/web` Debug build를 Chrome의 local HTTP server로 실행했다.
- Canvas focus 뒤 `F6`/`F7` Clear와 Stage 전환이 실제로 동작함을 수동 확인했다.
- Console에는 red error가 없었다. `WebGL INVALID_OPERATION` 경고와 user gesture 전 `AudioContext was not allowed to start` 경고가 보였으나 Clear/Shift 경로를 막지 않았다.

### 결과

- Q-S5 Web Gate를 충족해 S5-G5를 `VERIFIED`로 갱신했다.
- 경고의 원인 개선과 audio 첫 입력 정책은 S6/S9 범위에서 다시 점검한다.

## 2026-08-15 — S6-G4 audio handoff

Owner: Integration
Locked files: `scripts/core/stage_manager.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s6_g4_audio_wiring_verification.*`

### 변경

- `SettlementService`의 `final_settlement_started(amount)`와 `final_settlement_finished(amount)`를 `StageManager` public signal로 한 번씩 forwarding했다.
- Main에 Content-owned `AudioManager`를 mount하고 Simulation, StageManager, PauseMenu를 read-only source로 연결했다.
- `GameManager`는 전달된 Settlement 신호를 `settlement_start`와 `settlement_finish` event로만 매핑한다. 점수·상태·settlement timing은 변경하지 않는다.

### 검증

- 전용 integration scene에서 start/finish forwarding 각 1회, Main AudioManager mount와 source binding, `settlement_start` 전달을 확인했다.
- 기존 AudioManager foundation 및 S3-G5/S5-G3 integration regression scene이 통과했다.
- Primary `godot` Main runtime은 bridge ready, screenshot 생성, captured runtime error 0으로 확인했다.

### 제외

- Black Hole terminal `run_end` forwarding은 S8-G4 Integration 범위다.
- 실제 브라우저 audio playback과 late-density 가독성은 S6-G4 Content verification에 남긴다.
