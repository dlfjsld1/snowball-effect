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

## 2026-08-12 — S2-G1 최신 카탈로그 계약 재정렬

Owner: Content/Systems/Release
Branch: `main` working tree

### 변경

- 15레벨 score/radius/mass/fx-tier progression을 유지하면서 drift가 있던 리소스를 최신 계약으로 정렬했다: Lv6 `Sun`, Lv7 `Red Giant`, Lv9 `Nebula`, Lv10 `Galaxy`, Lv11 `Galaxy Cluster`.
- canonical display name, visual key, 문서화된 base color를 Content 카탈로그 검증 기대값에 반영했다. Time Bonus는 계속 `BallDefinition`에 없다.
- 이동 Galactic Black Hole은 Lv14 `Black Hole` 공 정의와 별개의 Stage 맵 기믹으로 유지했다.

### 확인

- Primary `godot` validate: `ball_definition.gd`, `ball_catalog.gd`, S2-G1 verification script 및 scene 모두 valid (4/4).
- Primary `godot` Main runtime query가 15개 catalog definition을 모두 로드했다. Lv14 `Black Hole`까지 name/key가 canonical sequence와 일치하고, score range는 `1`부터 `1e50`까지 유지된다. runtime debug output error 0.
- 이 환경에서는 신뢰 가능한 Godot CLI executable path를 찾을 수 없어 MCP headless validator와 실행 중인 Main project의 data query를 baseline evidence로 기록한다.

### 다음 작업 / 주의

- Resource filename은 기존 path를 보존한다. Core/Presentation이 소비하는 계약은 runtime `display_name`과 `visual_key`다.
- S3-G1은 별도의 Stage당 5레벨 chain 재정렬이 필요한 다음 Content/Systems 작업이다.

## 2026-08-12 — S3-G1 기본 Run 제외 의도 명시

Owner: Content/Systems/Release

### 변경

- 최근 팀 검토 결과를 Stage Contract, Cashout/Stage Task, Goal Status에 기록했다.
- Lv7 `Red Giant`와 Lv9 `Nebula`는 15종 BallCatalog에 남지만 Ground/Planetary/Galactic 기본 Run chain에는 의도적으로 포함하지 않는다.
- 이 배치는 Resource drift나 누락이 아니라 각 Stage를 정확히 5종의 ordered genealogy로 유지하기 위한 확정 콘텐츠 계약이다.

### 확인

- 문서 정합성만 갱신했다. Stage Resource, Ball Resource, runtime code, Goal 구현 상태는 변경하지 않았다.

## 2026-08-12 — S3-G1 Stage당 5종 계약 재정렬

Owner: Content/Systems/Release
Branch: `main` working tree

### 변경

- Stage progression을 최신 계약에 맞췄다: Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`.
- Planetary/Galactic Resource의 base/top level, ordered local level, Time Bonus 표를 갱신했다. 세 Stage 모두 `[0,0.25,0.5,1,2]`를 사용하며 Lv7·Lv9는 catalog에만 남고 기본 Run에는 포함되지 않는다.
- `StageDefinition`에 ordered five-level schema의 목적을 명시하고, content verification이 정확한 chain·길이·catalog-only level 제외·Galactic 전용 Black Hole flag까지 검사하게 했다.

### 확인

- Primary `godot` validate: StageDefinition, StageCatalog, S3-G1 verification script/scene, S2-G1 regression script, Main scene 모두 valid (6/6).
- Primary `godot` Main runtime query: 세 Resource의 base/top/ordered levels/Time Bonus/Black Hole flag와 catalog size 3, invalid index rejection을 확인했다. runtime debug output error 0.
- 프로젝트 중지 시 MCP bridge cleanup warning 한 건이 있었으나, 실행 중 debug output에는 게임 runtime error가 없었고 data query는 성공했다. MCP 종료 도구의 관찰 경고로 분류한다.
- 신뢰 가능한 Godot CLI executable path는 이 환경에서 확인하지 못해 MCP headless validator와 Main runtime data query를 baseline evidence로 기록한다.

### 다음 작업 / 주의

- Core는 이제 read-only `StageCatalog.get_stage(index)`를 소비해 S3-G2 `enter_stage(definition)`와 stage-local Cashout/Time Bonus 처리를 구현할 수 있다.
- 비연속 Planetary merge progression은 Stage runtime/Core가 `local_ball_levels` lookup으로 처리하는 후속 범위이며, 이 Goal에서는 StageManager나 runtime을 수정하지 않았다.

## 2026-08-12 — S5-G1 Stage 콘텐츠 매핑

Owner: Content/Systems/Release
Branch: `codex/s2-g5-merge-presentation`

### 변경

- 기존 Stage/Ball Resource가 최신 S5 계약을 이미 충족하므로 balance 값이나 runtime 코드는 변경하지 않았다.
- S5 전용 content verification을 추가해 세 Stage의 ordered 5종 chain, 이전 top/다음 base, spawn rate, neutral presentation scale, background key를 한 번에 검사한다.
- Lv7 `Red Giant`와 Lv9 `Nebula`가 BallCatalog에는 남지만 기본 Run chain에는 없고, Lv14가 `Black Hole`/`black_hole`인지 함께 검사한다.

### 확인

- Godot 4.7.1 native headless S5-G1 verification scene exit 0.
- Primary `godot` validate: S5-G1 script/scene과 S3-G1/S2-G1 regression scene 4/4 valid.
- Primary Main runtime data query: Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`; spawn `6/15/35`; background `ground/planetary/galactic`; scale `1`; Lv7/Lv9 catalog 존재; Lv14 Black Hole을 확인했다. runtime error 0.

### 다음 작업

- 다음 순차 Core Goal은 S5-G2 Stage re-baselining runtime이다. Planetary 비연속 progression `6→8→10`, Stage별 base spawn, reset 누출 방지는 그 Goal에서 구현·검증한다.
- Presentation S5-G4는 S5-G1 background key와 기존 Shift signal 계약을 소비해 병렬 진행할 수 있다.

## 2026-08-12 — S6 audio 담당 통합 계약

Owner: Content/Systems/Release
Branch: `main`

### 변경

- 팀 결정에 따라 S6-G3 Audio 콘텐츠와 S6-G4 사운드 계층·가독성을 Content/Systems가 함께 소유하도록 문서 계약을 재배정했다.
- `assets/audio/**`, `resources/audio/**`, `scripts/presentation/audio_manager.gd`, `tests/content/**`를 S6 audio 범위로 명시했다.
- Presentation은 S6-G1의 시각 FX event tier만 확정하고, Content가 audio catalog, 재생 priority/polyphony, Web 첫 입력 audio 활성화를 담당하도록 소유권과 read-only event 소비 계약을 정리했다.

### 확인

- 문서 전용 변경이며 runtime 파일은 수정하지 않았다.
- `git diff --check` 통과.

### 다음 작업 / 주의

- S6-G1 event tier가 아직 PENDING이므로 S6-G3/G4는 PENDING으로 유지한다.
- S6-G1의 확정 event tier를 받은 뒤에만 필수 audio key와 실제 asset catalog를 확정한다.

## 2026-08-13 — S6-G3 Audio 후보 에셋 사전 준비

Owner: Content/Systems/Release
Branch: `main`
Status: preparatory only — S6-G3 remains `PENDING`

### 변경

- 프로젝트 전용으로 생성한 Ogg Vorbis 후보 음원 22개와 `assets/audio/ATTRIBUTION.md`를 Git 보관 대상으로 준비했다.
- 후보를 S6 gameplay 10개, UI 6개, 향후 S8 6개로 구분하고, 외부 음원·샘플 팩을 사용하지 않았다는 제작 출처와 라이선스 정보를 기록했다.
- S6-G1의 최종 event key/tier가 확정되기 전이므로 audio catalog, key 매핑, runtime 재생 정책, Web 첫 입력 활성화는 구현하지 않았다.

### 확인

- Godot `4.7.1.stable.official.a13da4feb` CLI의 `--import`가 22개 파일을 모두 `AudioStreamOggVorbis`로 import했다.
- CLI load verification은 writable `--log-file`을 지정한 상태에서 exit code 0과 `S6_AUDIO_CANDIDATES_LOADED count=22 type=AudioStreamOggVorbis`를 확인했다.
- Primary `godot` runtime에서도 22/22 파일이 모두 `AudioStreamOggVorbis`로 로드됐고, failure index와 final runtime error는 0건이었다.
- 최초 CLI 검증에서 기본 `user://logs` 경로 쓰기 권한 때문에 프로세스가 종료됐으나, 저장소 내부 log 경로를 지정한 재검증은 통과했다. 이는 음원 또는 프로젝트 오류가 아닌 실행 환경 문제로 분리했다.
- CLI import 중 Windows root certificate store와 Godot editor settings 저장 경고가 있었으나, import·load 결과와 무관한 환경 경고로 확인했다.

### 다음 작업 / 주의

- S6-G3의 Goal 상태는 `PENDING`으로 유지한다.
- Presentation S6-G1이 최종 event key/tier를 확정한 뒤 audio catalog와 content test를 작성한다.
- 우선순위·polyphony·Web 첫 입력 audio 활성화와 실제 Browser 재생 검증은 후속 S6-G4 범위다.
