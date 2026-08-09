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
