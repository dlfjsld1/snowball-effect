# Content / Systems Worklog

> Append-only. 실제 작업과 검증만 기록한다.

## 2026-08-09 — S1-G5 Pause·Restart 요청 UI

Owner: Content/Systems
Branch: `main` working tree

### 작업

- Pause와 Retry 의도만 Integration에 전달하는 요청 UI를 구현했다.

### 변경

- Esc/R 입력과 버튼을 `pause_requested`/`retry_requested` 신호로 변환.
- pause 상태에 따른 버튼 문구만 변경하고 SceneTree와 gameplay는 직접 수정하지 않음.

### 확인

- Primary `godot` MCP validate 4/4.
- Godot 4.7.1 headless: exit 0, `S1_G5_VERIFIED pause_requests=1 retry_requests=1 gameplay_mutation=none`.

### 다음 작업 / 주의

- 실제 pause/reset은 S1-G6 Integration의 GameManager가 처리한다.

## 2026-08-10 — S2-G1 공·점수 데이터

Owner: Content/Systems
Branch: `codex/s2-g1-ball-data`

### 작업

- `BallDefinition` Resource와 Lv0~6 BallDefinition `.tres`를 추가했다.
- Core가 읽기 전용으로 사용할 `BallCatalog.get_definition(global_level)` API를 제공했다.
- Lv1 collision radius는 Shared Skeleton에서 승인된 4 world units를 사용했다.
- Time Bonus는 StageDefinition 전용이므로 BallDefinition에 추가하지 않았다.

### 확인

- Godot 4.7.1 CLI headless: S2-G1 Catalog 검증과 S1-G1 배열 풀 회귀가 모두 exit 0.
- Primary `godot` MCP validate: `ball_definition.gd`, `ball_catalog.gd`, S2-G1 verification script/scene 모두 valid (4/4).

### 다음 작업 / 주의

- Core는 S2-G2에서 `BallCatalog.get_definition(global_level)`을 read-only로 소비해야 한다.
- Merge 결과 velocity 계약과 Catalog를 simulation에 연결하는 작업은 S2-G1 범위 밖이다.

## 2026-08-10 — S2-G1 구현 검토

### 수정

- Resource는 Godot에서 수정 가능한 객체이므로 `BallDefinition`의 부정확한 immutable 주석을 canonical source data로 바로잡았다.
- Catalog 검증을 실제 radius, mass, visual key 값 비교로 강화했다.
- `score_value`가 계획된 late-game `1e36`을 유지하는지 검증을 추가했다.

### 재확인

- Godot 4.7.1 CLI headless parse와 S2-G1 verification exit 0.
- Primary `godot` MCP validate: 수정한 definition/test/scene 3/3 valid.

## 2026-08-10 — S2-G4 Score formatter

Owner: Content/Systems
Branch: `main`

### 작업

- `ScoreFormatter.format_score(value: float)` pure API를 추가했다.
- 1,000 미만 정수, K/M/B/T 접미사, 단위 경계 반올림 승격, 접미사 초과 과학적 표기를 구현했다.
- `NaN`은 `0`, 양·음 Infinity는 `∞`/`-∞`로 안정적으로 표시한다.
- 점수 ledger와 HUD layout은 변경하지 않았다.

### 확인

- Godot 4.7.1 CLI headless: project parse, S2-G4 formatter 및 S2-G1 catalog verification 모두 exit 0.
- Primary `godot` MCP validate: formatter script, verification script/scene 3/3 valid.

### 다음 작업 / 주의

- S2-G5는 Core S2-G3의 `ball_merged(result_level, world_position)` 이벤트 계약이 완료된 뒤 Presentation이 통합한다.

## 2026-08-11 — S2-G1 initial 15-ball data seed completion

Owner: Content/Systems
Branch: `main` working tree

### 변경

- global level 7~14의 BallDefinition Resource를 추가해 initial catalog를 15종으로 완성했다.
- 임시 Stage-theme seed는 Supernova, Nebula, Galaxy, Black Hole, Big Bang, Universe, Multiverse, Omega Snowball이다.
- `BallCatalog`는 Resource를 읽는 instance API로 정리했으며, 명칭·수치·Stage 배분은 이후 Content/Systems 플레이테스트에서 교체 가능한 데이터다.

### 확인

- Primary `godot` MCP validate: definition/catalog/S2-G1 scene 3/3 valid.
- Primary Main runtime: catalog count `15`, first `Snowflake`, last `Omega Snowball`, last level `14`, undefined level `15=false`, runtime error 0.

### 다음 작업 / 주의

- StageDefinition의 실제 local level 배분은 S3-G1에서 연결한다.
- native headless는 이 환경의 `user://logs` open failure와 signal 11 때문에 이번 Evidence로 사용하지 않았다.

## 2026-08-11 — S2-G1 base-ball radius seed correction

Owner: Content/Systems
Branch: `main` working tree

### 변경

- Shared Skeleton의 승인된 base Spawn radius `4`와 BallCatalog global level 0의 반지름을 일치시켰다.
- initial 15-ball catalog radius를 `4 → 8 → 16 → … → 65,536`으로 재정렬했다. 따라서 어떤 동일 level Merge도 반드시 다음 level의 두 배 반지름 output을 만든다.
- Game Rules의 initial catalog 표에 현재 radius seed를 명시했다.

### 확인

- Primary `godot` MCP validate: catalog, S2-G1/S2-G3/S1-G1 test scene, Main 5/5 valid.
- Primary Main runtime: global level 0 radius 4 두 개가 global level 1 radius 8 하나로 Merge됨; runtime error 0.

## 2026-08-11 — 3-Stage content and stage-contract documentation alignment

Owner: Content/Systems
Branch: `main`

### Scope

- Aligned documentation to the three-stage Ground, Planetary, Galactic structure.
- Documented the Lv14 Black Hole Snowball and the moving Black Hole map gimmick as separate final-Galactic elements.
- Recorded Stage-data seeds: base time, clear score, local time bonuses, and render-only visual radius ownership.

### Verification

- `git diff --check` passed.
- Documentation-only change: no runtime code, Resource, or Goal status was changed.

## 2026-08-11 — S2-G1 catalog alignment to current ball contract

Owner: Content/Systems
Branch: `main` working tree

### Changes

- Updated all fifteen BallDefinition resources to Snowflake through Black Hole with the documented score, radius, mass, snake_case visual key, base color, and fx tier values.
- Raised the score-data range to `1e50` and removed the legacy BallDefinition `radius_scale`; StageDefinition owns render-only visual scaling.
- Extended Content catalog verification and repaired ScoreFormatter scientific notation for the `1e50` range.

### Verification

- Primary `godot` validate passed for 7 scripts/scenes.
- Primary `godot` Main runtime inspection: all 15 catalog entries passed; Lv14 is Black Hole with score `1e50`; no resource exposes `radius_scale`.
- Formatter runtime checks: `1.00e+15`, `1.00e+36`, and `1.00e+50`; runtime error 0 after restart.
- Godot CLI baseline was unavailable because the configured executable path was not present in this environment.

### Follow-up

- Core-owned S1-G1 and S2-G3 checks still expect the superseded radius sequence `4 → 8`; their owner must update and rerun those regression checks before treating the cross-lane merge path as reverified.

## 2026-08-12 — S3-G1 Stage 데이터

Owner: Content/Systems/Release
Branch: `main` working tree

### 작업

- Core·Presentation·Integration이 읽기 전용으로 소비할 `StageDefinition`과 `StageCatalog.get_stage(index)`를 추가했다.
- 사용자의 결정에 따라 초기 구간을 Ground `0–4`, Planetary `4–9`, Galactic `9–14`로 확정했고, 이전 Stage 최고 공이 다음 Stage 기본 공이 되도록 데이터로 연결했다.

### 변경

- `resources/stages/**`에 base time `45/40/35`, clear score `4e6/2e18/0`, spawn rate `6/15/35`, stage-local Time Bonus, local ball progression, background ID를 저장했다.
- 물리 반지름과 분리된 `visual_radius_scale`은 근거가 생길 때까지 세 Stage 모두 render-only neutral 값 `1.0`으로 뒀다.
- S3-G1 catalog verification으로 index 범위, 연속 level 경계, seed 값, Time Bonus, Galactic 전용 Black Hole map-gimmick flag를 확인한다.

### 확인

- Primary `godot` validate: StageDefinition, StageCatalog, S3-G1 test script/scene, S2-G1 regression scene 모두 valid (5/5).
- S3-G1 자동검증 Scene은 `quit(0)`으로 짧게 끝나 Primary MCP bridge가 준비되기 전 exit 0이 발생해 stdout을 회수하지 못했다. 이는 project/runtime error가 아닌 MCP short-lived-scene 관찰 제한으로 분류했다.
- Godot CLI executable은 현재 환경에서 신뢰성 있게 확인할 수 없어 headless baseline은 실행하지 못했다.

### 다음 작업 / 주의

- Core/Integration 담당은 read-only `StageCatalog.get_stage(index)`와 `StageDefinition`을 소비해 S3-G2 `enter_stage(definition)`을 구현할 수 있다.
- `visual_radius_scale`의 실제 tuning과 Stage World 연결은 S5-G1/S5-G4의 별도 범위다.
- 사용자 승인 seed: 초기 제한 시간은 Ground/Planetary/Galactic `45/40/35초`, clear score는 `4e6/2e18/0`을 유지한다. 실제 Stage 플레이가 가능해진 뒤 여러 차례 플레이테스트한 관측값으로만 조정한다.
