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

## 2026-08-16 — S8-G4 선행 Integration 골격 계약

Owner: Integration
Locked files: `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s8_g4_*`

### 결정

- S8-G2의 phase/finale/result schema가 확정됐으므로 S8-G3/G5 완료를 기다리지 않고 Integration-owned 골격을 먼저 진행한다.
- matching `phase_id` 완료 API, terminal snapshot 전달, Retry/Main Menu handler와 Core reset을 먼저 제공한다.
- Presentation producer가 없는 동안에는 실제 완료 API를 deferred 한 번 호출하는 임시 adapter를 허용하되, 실제 S8-G5 연결 시 제거한다.

### 병렬 작업 보호

- `scripts/presentation/**`, `scripts/ui/**`, `scenes/backgrounds/**`, `scenes/effects/**`는 잠그거나 수정하지 않는다.
- 임시 adapter는 연출·Result UI를 구현한 것으로 취급하지 않으며 S8-G4 최종 상태를 올리는 Evidence로 사용하지 않는다.
- S8-G3와 S8-G5는 Integration 골격의 공개 signal/API를 기준으로 각 Owner lane에서 병렬 개발할 수 있다.

## 2026-08-16 — S8-G4 Black Hole Finale·Retry Integration 골격

Owner: Integration
Locked files: `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `tests/integration/s8_g4_*`

### 구현

- 첫 Black Hole phase request를 `StageManager`가 `BLACK_HOLE_PHASE_LOCKED`로 잠그고, `phase_id`와 from/to logical Rect를 공개하도록 연결했다.
- matching `phase_id`만 L3 logical Rect와 gameplay를 재개하며 stale·duplicate completion은 무시한다. 실제 S8-G5 전에는 `GameManager`의 deferred adapter가 같은 public completion API를 한 번 호출한다.
- 두 Black Hole finale snapshot은 `RUN_ENDED` 상태와 `terminal_result_available`으로 정확히 한 번 전달한다. 이 상태에서는 simulation commit이 다시 진행되지 않는다.
- Retry는 Ground 재시작과 terminal snapshot 제거를, Main Menu는 simulation·ledger·settlement를 정리하고 `READY` 상태로 돌아가는 골격을 제공한다.

### 검증

- Godot 4.7.1 CLI project load와 S8-G4/S8-G2/S5-G5 headless scenes가 exit 0으로 완료됐다. S8-G4 test는 첫 Lv14 merge가 Time Up과 같은 tick에 발생해도 `BLACK_HOLE_PHASE_LOCKED`가 우선하고 뒤늦은 종료 중재가 실행되지 않음을 포함한다.
- Primary `godot` validate 5/5: GameManager, StageManager, Main, S8-G4 test script/scene이 모두 valid다.
- Primary Main runtime script에서 stale phase 거부, matching phase 수락, logical width `880→1040`, terminal snapshot 1회, `RUN_ENDED`, Retry `PLAYING`, Main Menu `READY`를 확인했다.

### 제외

- S8-G3 Result/Title UI와 S8-G5 실제 phase/finale presentation은 각 Owner 범위다.
- 임시 adapter를 포함한 이 골격은 최종 `IMPLEMENTED`/`VERIFIED` 증거가 아니다. 실제 producer 연결 및 전체 reset·Desktop/Web 완주가 남아 있다.
- 사용자가 Presentation Frame 기준을 우선하도록 결정했다. 따라서 Core logical target도 현재 `GameplayFrame.FIELD_WIDTHS`의 L2/L3 `880/1040`과 일치시키고, 관련 current rules/S8 Goal 계약을 같은 값으로 정정했다.

## 2026-08-17 — S8-G3 Terminal UI Main handoff

Owner: Integration
Locked files: `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s8_g4_*`

### 구현

- Main에 Content-owned `TitleScreen`과 `ResultPanel`을 mount했다.
- Black Hole finale의 read-only result snapshot은 `ResultPanel.show_result()`로 전달하고, gameplay HUD/Pause control은 숨긴다.
- Result/Pause의 `main_menu_requested`는 Core runtime을 `READY`로 정리한 뒤 Title을 표시한다. Title의 `start_requested`는 Ground fresh run으로 돌아간다. Pause `resume_requested`도 기존 pause toggle과 분리해 연결했다.

### 검증

- Primary validate에서 GameManager, Main, S8-G4 test, S8-G3 test가 모두 valid다.
- Godot 4.7.1 headless S8-G4, S8-G3, S5-G5 verification scene이 exit 0으로 완료됐다.
- Primary Main runtime에서 finale Result Panel의 `SNOWBALL EFFECT`/`CLEAR SCORE`/`MAIN MENU`, Main Menu→Title, Title Start→`PLAYING`을 확인했고 final runtime error는 0이다.

### 제외

- S8-G5의 실제 Black Hole Phase/Finale presentation producer는 아직 연결되지 않았다. 임시 phase adapter와 S8-G4 `IN PROGRESS` 상태를 유지한다.

## 2026-08-17 — S8 UI handoff·Paddle field-boundary follow-up

Owner: Integration
Locked files: `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `scripts/gameplay/paddle.gd`, `tests/integration/s8_g4_*`, `tests/integration/s5_g4_*`

### 변경

- Main에 Title/Result UI를 연결하고 terminal result snapshot, Main Menu, Title Start 경로를 통합했다.
- Stage frame 또는 Black Hole field 경계가 바뀔 때 Paddle 중심이 field 끝을 넘지 않도록, 회전한 Paddle의 실제 가로 점유 폭 기준 clamp와 motion-history reset을 적용했다.
- 자동 Merge 뒤 갑작스러운 최고 공 Clear/Scale Shift는 현재 규칙을 유지한 채 향후 balancing observation으로 기록했다.

### 검증

- Primary runtime에서 Result→Title→fresh Ground run을 확인했다.
- Galactic field 경계에서 회전 Paddle의 중심이 실제 right limit 안에 남고 linear velocity가 0으로 reset됨을 확인했다.

## 2026-08-17 — Ground Moon Clear tick ownership regression

Owner: Integration
Locked files: `scripts/core/stage_manager.gd`, `tests/integration/s5_g5_*`

### 수정

- Main에서 BallSimulationManager의 자체 physics callback이 StageManager tick 뒤에도 실행되어, 두 번째 simulation step에서 발생한 Top Ball event가 다음 tick에 유실될 수 있음을 재현했다.
- deferred lifecycle 시점에 callback을 다시 비활성화해 StageManager만 authoritative simulation tick을 실행하도록 고정했다.

### 검증

- Primary runtime에서 simulation 자체 physics는 `false`이며 Giant Snowball pair→Moon 뒤 `SHIFTING`, active ball `0`, 0.9초 shift 뒤 Planetary `PLAYING`을 확인했다.
- S5-G5 integration verification에 single simulation tick owner assertion을 추가했다.

## 2026-08-17 — Black Hole visibility and Frame-safe Paddle bounds

Owner: Integration emergency follow-up
Locked files: `scripts/simulation/ball_renderer.gd`, `scripts/gameplay/paddle.gd`, `scripts/presentation/gameplay_frame.gd`, corresponding S4/S5 verification scripts

### 변경

- 일반 ball slot 밖으로 전환된 Black Hole runtime entity의 read-only snapshot을 renderer가 별도로 읽어, 최소 dark core/ring fallback을 표시하도록 했다. S8-G5의 완성형 ring·particle·finale presentation은 여전히 Presentation 범위다.
- visual frame 하단과 실제 logical play field 사이에 `32 logical units` safety/cashout strip을 두고, Paddle이 회전한 전체 X/Y 외곽을 logical field 안에 clamp하도록 했다.

### 확인

- Primary runtime에서 Galactic Black Hole entity 1개가 position `(800, 300)`, radius `16`으로 생성된 뒤 renderer metric `black_hole_count=1` 및 동일 render position을 확인했다.
- L2 field는 `Rect2(360, 50, 880, 768)`로 적용됐고, 45도 Paddle은 y=`727.49`로 보정되어 하단 logical boundary 안에 남았다.
- Primary validate 5/5 통과. Native CLI는 기존 `user://logs` 접근 오류 후 signal 11로 테스트 실행 전 종료되어 환경 문제로 분리했다.

## 2026-08-17 — L3 Frame/UI synchronization correction

Owner: Integration follow-up for S8-G4
Locked files: `scripts/core/game_manager.gd`, `scripts/presentation/gameplay_frame.gd`, `tests/integration/s8_g4_black_hole_integration_verification.gd`

### 원인과 수정

- Black Hole Phase 재개 시 simulation과 Paddle만 L3 `1040` logical rect로 바꾸고 GameplayFrame은 L2 profile에 남아 있었다. 그래서 확장된 Paddle이 L2 우측 UI와 시각적으로 겹칠 수 있었다.
- L3의 logical rect를 GameplayFrame profile data에서 직접 가져오고, Phase 재개 시 Frame profile·backdrop·HUD·Pause layout과 simulation/Paddle을 같은 L3 rect로 함께 갱신한다.

### 확인

- Primary validate 3/3 통과.
- Primary Main runtime에서 L3 profile과 simulation/Paddle logical rect가 모두 `Rect2(280, 50, 1040, 768)`이고, 우측 하단 UI panel은 `Rect2(1406, 796, 152, 104)`로 field 바깥에 남는 것을 확인했다. runtime error 0.

## 2026-08-19 — S8-G4 Result Run 통계 연결

Owner: Integration (잠금 담당 승인됨)

- `StageManager`가 기존 `ball_merged(result_level, world_position)`를 구독해 성공 Merge를 한 건씩 누적한다. tick용 `simulation_metrics.merges`는 총합으로 사용하지 않는다.
- `StageManager._physics_process()`의 `PLAYING` tick에서만 Run Time을 누적한다. Black Hole Phase lock과 terminal 상태에서는 증가하지 않는다.
- Start/Retry와 Main Screen 종료에서 통계를 초기화하고 Stage 진입에서는 유지한다.
- S8-G4 검증에서 첫 Black Hole 생성 Merge 1회, `0.1s` PLAYING 시간, phase lock 중 `2.0s` 미증가, terminal snapshot 전달, Retry 0 초기화를 확인했고 Godot 4.7.1 headless exit 0이었다.

## 2026-08-19 — S8-G4 Result Retry Button wiring

Owner: Integration (잠금 담당 승인됨)

- ResultPanel의 실제 `retry_requested` 신호를 기존 authoritative `_on_retry_requested()` handler에 연결했다.
- Integration verification이 Result의 실제 Retry Button을 눌러 Ground `PLAYING`, stage index 0, terminal snapshot clear, Merge/Run Time 0 reset을 확인한다.
- Result의 실제 Main Button도 active Run을 안전하게 종료하고 Title을 표시하는 기존 handler를 계속 사용한다.

## 2026-08-20 — Play Field Backdrop chamfer

Owner: Integration (사용자 명시 요청)
Locked files: `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s5_g4_frame_playable_verification.gd`

- Pause 중에도 보이던 검은 사각형의 실제 producer가 Pause UI가 아니라 GameManager가 생성하는 PlayField `Backdrop` 4점 Polygon임을 확인했다.
- 충돌·Paddle·Cashout에 쓰는 logical field는 변경하지 않고, visual backdrop만 48px 모서리 절삭의 8점 Polygon으로 변경했다.
- S5-G4 frame playable verification과 S8-G3 terminal UI verification, Godot 4.7.1 Web release export가 모두 exit 0이었다.
## 2026-08-20 — S8-G4 Black Hole finale·Retry 실제 wiring

- Owner lane: Integration
- Goal: S8-G4
- Locked files: `scripts/core/game_manager.gd`, `tests/integration/s8_g4_black_hole_integration_verification.gd`; lock released after implementation verification.
- 구현: 임시 Black Hole phase auto-complete adapter를 제거했다. Stage phase 시작을 S8-G5 `play_black_hole_phase()`로 전달하고, matching Presentation 완료만 StageManager에 수락시켜 L3 logical field/gameplay를 재개한다. terminal snapshot은 S8-G5 finale overlay가 끝난 뒤에만 S8-G3 Result UI로 전달한다. Retry/Main은 terminal snapshot과 Presentation phase/finale lock을 함께 초기화한다.
- Verification: Godot 4.7.1 CLI/headless S8-G4 integration verification exit 0 (`phase_presentation=true`, `finale_handoff=true`, `reset_safe=true`); S8-G2 Core regression exit 0; Web release export 성공.
- 상태: `IMPLEMENTED`. 실제 Desktop/Web에서 Galactic 첫 Black Hole→L3 재개→두 번째 Black Hole finale→Result→Retry/Main 완주 관찰 전에는 `VERIFIED`가 아니다.
## 2026-08-20 — Play Field Backdrop chamfer 되돌림

- 사용자 확인 결과, 48px chamfer는 Pause modal이 아니라 Play Field `Backdrop`에 잘못 적용된 변경이었다.
- `GameManager`의 chamfer polygon 생성과 `main.tscn`의 8점 Backdrop을 기존 사각형으로 복원하고, S5-G4 playable verification도 원래 Cashout corridor assertion으로 되돌렸다.
- S8-G4 Black Hole phase/finale integration 변경은 이 되돌림 범위에 포함하지 않고 유지했다.

## 2026-08-20 — Play Field Frame Aperture 정렬

- 사용자 화면 검토에서 사각형 Backdrop이 프레임 PNG의 대각형 안쪽 개구부를 덮어 금속 모서리와 시각적으로 충돌함을 확인했다.
- `GameManager`는 물리 `play_field_rect`·Paddle·Cashout 영역을 변경하지 않고, 장식용 Backdrop만 프레임과 같은 50px 8점 개구 윤곽으로 만든다.
- Godot 4.7.1 headless S5-G4 검증은 새 스크립트를 정상 로드했으나 기존 Paddle 경계 assertion에서 배경 assertion 전에 실패했다. Web release export는 `[ DONE ] savepack`으로 완료했다.

## 2026-08-20 — Frame Aperture 배경 절삭 철회

- 사용자 화면 확인에서 절삭된 Backdrop 뒤로 Stage World가 대각형으로 드러나며 오히려 프레임 모서리를 훼손함을 확인했다.
- 8점 시각 Backdrop 로직과 그 전용 assertion을 제거하고, Backdrop을 원래 4점 직사각형으로 복원했다. 물리 영역은 전후 모두 변경하지 않았다.
- Godot 4.7.1 Web release export는 `[ DONE ] savepack`으로 완료했다.

## 2026-08-20 — Play Field Backdrop frame clearance

- 황동 파이프 PNG의 투명 픽셀 아래로 사각형 Backdrop이 비치던 화면 결함을 수정했다.
- Backdrop은 사각형을 유지하되 `get_field_visual_rect()`보다 전 방향 8px 안쪽에서만 그린다. Simulation·Paddle·Cashout의 logical rect는 변경하지 않았다.
- Godot 4.7.1 Web release export는 `[ DONE ] savepack`으로 완료했다.

## 2026-08-20 — Play Field Backdrop bezel aperture tracing

- 8px inset은 파이프 침범을 막았지만 원치 않는 여백을 만들었고, 단순 대각 절삭은 Stage World를 넓게 노출했다.
- Backdrop은 이제 `field_bezel_v2_910x900`의 중앙 투명 개구부를 추출한 정적 pixel-art contour(128 points)를 NinePatch 좌표계로 변환해 그린다. 따라서 개구부에는 여백 없이 닿고, 황동 파이프 영역·외부 투명 canvas는 채우지 않는다.
- 매 Stage마다 이미지 전체를 스캔하던 초기 구현은 제거하여 runtime 비용을 남기지 않았다. Godot 4.7.1 headless scene load에서 Backdrop contour assertion은 통과했으며, 기존 Paddle boundary assertion 두 건은 독립적으로 계속 실패한다. Web release export는 `[ DONE ] savepack`으로 완료했다.

## 2026-08-20 — Backdrop/Frame layering correction

- 사용자 피드백에 따라 Backdrop 윤곽을 프레임에 맞추려는 접근을 철회했다. Backdrop은 원래의 직사각형 gameplay backing으로 복원했다.
- `GameplayFrame`에 같은 bezel texture를 사용하는 `FieldPipeMatte` NinePatch를 원본 `FieldBezel` 바로 아래에 추가했다. matte shader는 중앙 개구부에서 멀어지는 방향으로만 최대 8px의 불투명 pipe edge를 보강하므로, 검은 Backdrop은 파이프 투명 디테일 아래에 비치지 않고 중앙 Play Field에는 여백을 만들지 않는다.
- Godot 4.7.1 headless에서 shader/scene load 및 matte-bezel 정렬 assertions는 통과했다. 기존 Paddle boundary assertion 두 건은 이 변경과 별개로 계속 실패한다. Web release export는 `[ DONE ] savepack`으로 완료했다.

## 2026-08-20 — Field bezel 9-slice margin correction

- 실제 runtime screenshot으로 원인을 확정했다. `FieldBezel.draw_center=false`인데 patch margin이 50px라서, source texture의 50~90px 구간에 남아 있던 황동 파이프/내부 림이 중앙 미그림 영역으로 빠지고 있었다.
- Backdrop은 4점 직사각형으로 유지한다. 임시 aperture contour와 pipe-matte shader를 제거하고, `FieldBezel`의 네 patch margin을 90px로 넓혀 파이프 전체가 프레임 레이어에서 렌더되게 했다.
- Primary Godot MCP 실제 runtime에서 Ground, Stage profile L2, Black Hole L3 profile을 캡처했다. L3에서도 황동/내부 림 다음 픽셀부터 Backdrop이 시작하고 Stage World 배경색 사이 여백은 없었다. CLI headless에서 new 9-slice margin assertion은 통과했으며 기존 Paddle boundary assertion 두 건만 독립적으로 실패했다. MCP bridge를 중지한 뒤 clean Web release export `[ DONE ] savepack`을 다시 생성했다.

## 2026-08-20 — Scale Shift visual Backdrop sync

Owner: Integration (사용자 명시 요청)
Locked files: `scripts/core/game_manager.gd`, `scripts/presentation/gameplay_frame.gd`, `scripts/presentation/presentation_manager.gd`, `tests/integration/s5_g4_shift_presentation_wiring_verification.gd`, `docs/team/INTEGRATION_CONTRACTS.md`

- `GameplayFrame`가 두 profile 사이의 visual field `Rect2`를 순수 계산하고, `PresentationManager`가 Frame 보간과 같은 tween progress마다 `visual_field_rect_changed(Rect2)`를 발행한다.
- `GameManager`는 이 신호를 받아 장식용 PlayField `Backdrop` 사각형만 갱신한다. Simulation, Paddle, Cashout logical field는 기존처럼 Presentation 완료 뒤 StageManager의 stage change에서만 바뀐다.
- 같은 signal을 Black Hole L2→L3 Frame 보간에도 사용해 중앙 화면이 frame보다 늦게 또는 먼저 움직이지 않게 했다.
- Godot 4.7.1 CLI/headless `s5_g4_shift_presentation_wiring_verification.tscn` exit 0 (`backdrop_lerp=true`, `logical_bounds_deferred=true`), `s8_g5_black_hole_presentation_verification.tscn` exit 0. Primary Godot runtime에서 active tween의 Backdrop/Frame inner width가 각각 `719.776`으로 일치하고 logical width는 `560`으로 유지됨을 확인했다. Main/관련 script Primary validate 6/6 및 MCP bridge 종료 뒤 clean Web release export `[ DONE ] savepack` 통과.

## 2026-08-20 — S5-G6I Score Clear 확인 뒤 Scale Shift

- `StageManager`는 non-final Time Up Settlement가 score cut을 넘었을 때 `CLEARED`와 단일 `clear_id` snapshot을 공개하고, matching `request_next_stage(clear_id)` 전에는 Shift하지 않도록 변경했다.
- Galactic Time Up은 `clear_score = 0`을 Clear로 해석하지 않고 `RUN_ENDED`로 종료한다. Retry/Main Menu는 pending clear lock을 초기화한다.
- GameManager가 request-only `NEXT STAGE`를 중재해 matching request 뒤에만 기존 Shift presentation 계약으로 연결했다.
- Primary Godot validate와 S3-G5/S5-G3/S5-G6I verification scenes가 exit 0이었다.

## 2026-08-20 — 즉시 Score Clear → Scale Shift

Owner: Integration (사용자 최신 규칙)

- `StageManager`는 `SCORE_CLEAR`를 `CLEAR_LOCKED→SETTLING→CLEARED→SHIFTING`으로 한 번 연결하고, 사용자 `Next Stage` 확인 없이 기존 presentation `shift_id` handoff를 시작한다.
- 제거된 확인 대기 API와 `StageClearPanel` mount를 Main/GameManager에서 함께 제거했다. Time Up 중 Settlement가 score cut을 넘는 경우도 같은 자동 Shift 경로를 사용한다.
- Primary validate 9/9, S3-G5/S5-G3/S5-G5/S5-G6I verification scene exit 0을 확인했다. Main runtime에서 Ground clear score를 직접 반영한 직후 time `45`, state `SHIFTING`, shift id `1`, Clear panel 없음, runtime error 0이었다.

## 2026-08-21 — S8-G4 final player-path verification

Owner: Integration

- 사용자 실제 플레이로 첫 Black Hole phase 진입·기믹 생성, 두 번째 Black Hole 충돌, finale 뒤 Result 표시를 확인했다.
- L2→L3 뒤 Galactic 재개과 Result `RETRY RUN`의 fresh Ground reset, `MAIN`의 Title 복귀까지 확인해 terminal snapshot handoff와 reset mediation의 최종 경로를 닫았다.
- 기존 S8-G4/S8-G2 CLI integration regressions 및 Web export evidence와 함께 S8-G4를 `VERIFIED`로 갱신했다.

## 2026-08-21 — S7-G1 Item gateway integration

Owner: Integration

- `ItemManager`와 `ItemEffectGateway`를 Main에 mount했다. Stage 진입마다 ItemManager가 현재 logical Play Field와 local Lv2 runtime radius로 reset되고, 활성 Item Ball 동안 중앙 simulation의 read-only ball collision snapshot을 소비한다. Orb pickup은 회전된 Paddle OBB와 Orb 원의 현재 접촉으로만 producer에 전달한다.
- Gateway는 `item_collected` 이후에만 monotonic `event_id` CUT-IN request를 발행한다. matching activation cue 또는 explicit skip이 도착할 때만 effect activation request를 한 번 emit하며, duplicate/stale cue 및 Retry/Main reset 뒤의 이전 event를 거부한다. Item Ball 파괴와 Orb miss는 activation 경로에 연결하지 않았다.
- Verification: Godot 4.7.1 CLI Gateway scene exit 0 (`collection=cue_only`, `activation=once`, `skip_fallback=once`, `reset_stale_rejected=true`); S7-G1C producer regression exit 0; Primary `godot` validate에서 Gateway/GameManager/Simulation/Main/test 5/5 valid; Primary Main runtime에서 ItemManager/Gateway mount, Title start 뒤 `PLAYING`, runtime errors 0을 확인했다.
- 상태: `IMPLEMENTED`. S6-G2 CUT-IN producer와 S7-G2~G4 effect consumer가 없어 실제 cue→effect 결과와 Web 관찰은 이후 Integration close에서 검증한다.

## 2026-08-21 — fx-design/latest Main Integration 계약 병합 해소

Owner: Integration / senior integration

- latest Main의 `visual_field_rect_changed(Rect2)` Backdrop 동기화, S3-G7 non-final local-Lv4/즉시 Score Clear, S5-G6I automatic `Clear→Settlement→Shift`, S8-G4 direct GameManager producer와 no-argument finale completion API를 authoritative contract로 유지했다. obsolete Next Stage 확인 계약과 released lock은 복원하지 않았다.
- Presentation의 S6-G6 완료는 automatic Shift를 막지 않는 read-only visual completion으로 정리했고, S8-G5의 phase ID·run-generation·stale callback 방어는 latest Main public API 위에서 동작하도록 조정했다. Core/Integration 자동 병합 파일은 변경하지 않았다.
- Godot 4.7.1 CLI/headless에서 S3-G7 Core/Integration, S5-G5 three-stage, S5-G6I automatic clear, S8-G4 Integration 및 S8-G5 두 Presentation 회귀가 모두 exit 0이었다. Main headless·Native smoke와 Web release export도 exit 0이었다.
- 기존 latest Main fixture의 stale assertion 세 건과 shutdown-only leak warning은 merge-induced failure가 아니므로 수정하지 않았다. 브라우저 smoke는 `browse` Windows 서버 번들 부재로 미검증이며, Primary Godot MCP도 현재 세션에 제공되지 않았다.
- Integration lock은 `released` 상태이며 새 lock을 잡지 않았다. Time CRT 디자인 파일은 편집·스테이징 대상에서 제외했다.

## 2026-08-21 — S7-G1 clean class-load repair

- `GameManager`가 ItemManager와 ItemEffectGateway를 global `class_name`으로 annotation/cast하던 의존을 제거하고 두 mounted node를 `Node`로 참조하게 했다.
- 이는 다른 workspace/MCP가 새 global script class cache를 만들기 전에 `game_manager.gd`를 단독 파싱해 실패하던 load-order 결함을 막는다. Gateway/Manager의 class declaration, signal API, scene mount와 gameplay contract는 변경하지 않았다.

## 2026-08-21 — S6-G2I FIRST_CONTACT pause·S8 handoff 계약 준비

Owner: Integration planning / Goal status `PENDING`

- Integration이 current `run_epoch`, end-of-tick arbitration, visible CUT-IN 전 timer/spawn/simulation/Paddle lock과 event-id FIFO를 소유하도록 경계를 확정했다.
- normal matching finish는 같은 `PLAYING`을 재개하고, 첫 Black Hole matching finish는 gameplay를 중간 재개하지 않은 채 기존 S8-G4 `begin_black_hole_phase → phase_id` downstream으로 넘긴다.
- Retry/Main/fresh Run은 old epoch·queue·pause lock·Panel callback을 함께 무효화한다. wrong/stale/duplicate finish와 Result/Failure/Shift state는 수락하지 않는다.
- 기존 S8-G4의 phase 이후/finale/Retry Evidence는 보존하지만 CUT-IN 이전 gate 증거로 소급하지 않는다. 이번 기록은 계약 준비이며 Integration lock, runtime 변경, 자동/수동 검증 Evidence가 없다.

## 2026-08-21 — S3-G5 deadline-bounded StageManager integration

Owner: Integration

- StageManager가 full callback `delta`가 아니라 deadline 전 유효 구간만 Simulation에 step하고, 그 구간에서 발생한 Cashout만 StageRuntime으로 중재하도록 연결했다.
- 통합 verification은 deadline 전 Lv3 Cashout이 시간을 연장하는 경우와, deadline 뒤 하단 crossing은 Time Bonus 없이 Final Settlement base score만 반영하고 Fail lock으로 가는 경우를 분리해 확인했다.
- Godot 4.7.1 CLI headless S3-G2/G3/G4/G5와 S5-G3/G5/G6 회귀 exit 0, Primary validate 7/7, Main runtime error 0, clean Web Browser gameplay/console warning·error 0을 확인했다.

## 2026-08-21 — S5-G6I Next Stage confirmation and failed-run Result handoff

Owner: Integration

- Non-final Score Clear는 이제 `CLEARED`에서 monotonic `clear_id`와 copied display snapshot을 한 번 발행하고, `StageClearPanel`의 matching `NEXT STAGE` request가 올 때까지 gameplay/Paddle을 잠근다. 잘못된·중복 request는 StageManager와 Panel 양쪽에서 수락하지 않는다.
- 수락된 request만 기존 Scale Shift `shift_id` flow를 시작한다. Retry/Main reset은 pending confirmation을 지우지만, old delayed callback과 충돌하지 않도록 clear ID high-water mark는 유지한다.
- 같은 terminal handoff 누락을 함께 복구했다. non-final Time Up failure 및 Black Hole score-depletion failure도 `stage_run_ended` snapshot을 통해 ResultPanel로 간다. 따라서 gameplay가 멈춘 채 검은 화면으로 남지 않는다.
- Verification: Godot 4.7.1 CLI editor/headless project load exit 0, S3-G5 headless integration verification exit 0. Primary `godot` runtime에서 Ground Score Clear panel, real NEXT STAGE click 뒤 Planetary `PLAYING`, Planetary Time Up 뒤 visible ResultPanel, score 0 Black Hole run-end 뒤 visible ResultPanel을 확인했다. MCP 종료 뒤 clean Web release export를 localhost browser에서 로드해 `1280×720` Canvas, focus 뒤 F7 입력 전달, browser console warning/error 0을 확인했다.

## 2026-08-21 — S6-G2I FIRST_CONTACT CUT-IN pause and Black Hole handoff

Owner: Integration

- `GameManager`가 run-scoped epoch와 schema/roster-valid FIRST_CONTACT payload FIFO를 중재한다. CUT-IN은 end-of-tick deferred arbitration 뒤 head event만 Presentation consumer에 요청하며, 수락 전에 Stage timer/simulation/spawn 및 Paddle physics를 lock한다.
- 정상 CUT-IN의 matching `(event_id, run_epoch)` finish만 같은 `PLAYING`으로 복귀한다. wrong/stale/duplicate finish와 terminal state는 거부되고, Retry/Main/fresh Run은 queue·active payload·pause lock과 old epoch를 함께 무효화한다.
- 첫 Black Hole request는 readiness로만 저장한다. matching CUT-IN finish 전에는 phase ID를 만들지 않으며, 완료 때만 기존 `begin_black_hole_phase → Presentation → matching phase finish` path를 시작한다. 이에 따라 S8-G4 regression fixture도 새 upstream gate를 통과한 뒤 downstream phase/finale를 검증하도록 갱신했다.
- Verification: Godot 4.7.1 CLI/headless project load exit 0. Primary `godot` S6-G2I fixture exit 0 (`fifo=true pause=true stale_rejected=true black_hole_gate=true reset=true`) 및 updated S8-G4 integration regression exit 0. MCP bridge shutdown-only warning은 test process 종료 시 발생한 tooling warning이며 game error는 없었다.
- Presentation `S6-G2` controller는 아직 미구현이다. 따라서 실제 Main은 producer API가 연결되기 전까지 FIRST_CONTACT를 visible CUT-IN/lock으로 소비하지 않으며, 다음 Presentation Goal에서 `play_first_contact_cutin(payload)`와 `first_contact_cutin_finished(event_id, run_epoch)`를 제공해야 한다.

## 2026-08-21 — S7-G1 Blizzard spawn consumer wiring

Owner: Integration

- Main에 Content-owned `ItemBlizzard` runtime을 mount하고, Gateway의 authoritative `item_effect_activation_requested`에서 matching `blizzard`만 `item_blizzard.tres`로 activate하도록 연결했다. 다른 item type은 spawn rate를 바꾸지 않는다.
- GameManager는 Stage base spawn rate와 effect multiplier를 별도 상태로 유지한다. `spawn_multiplier_changed(3.0/1.0)`은 effective spawn rate만 바꾸며, active Blizzard 중 Stage 변경은 새 base rate에 같은 multiplier를 적용한다. expiry, Retry, Main은 `1.0`으로 정확히 복구한다.
- Verification: Godot 4.7.1 CLI/headless project load exit 0. Primary `godot` integration fixture exit 0 (`activation=once spawn_x3=true stage_rebase=true expiry_retry_main_reset=true`)에서 Ground `6→18`, spawn loop의 실제 3배 commit, Planetary `15→45`, expiry `45→15`, Retry/Main `→6`을 확인했다. Primary Main Start Run runtime error 0.
- Presentation S6-G2의 actual item CUT-IN producer가 아직 없으므로 Orb 획득→visible CUT-IN→cue의 사용자 경로와 Web smoke는 미검증으로 남긴다. Gateway skip fallback 경로는 검증됐다.
