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

## 2026-08-13 — Pixabay 음원 확정본 및 개별 출처 기록

Owner: Content/Systems/Release
Branch: `codex/audio-pixabay-provenance`
Status: asset preparation only — S6-G3/S6-G4 status unchanged

### 변경

- 선택한 22개 OGG 후보를 사용자 제공 Pixabay 음원으로 교체했다.
- `assets/audio/ATTRIBUTION.md`에 Pixabay Content License와 파일별 개별 원본 URL을 기록했다.
- `merge_t1.ogg`만 원본 URL이 아직 제공되지 않아 `Not recorded yet`로 남겼다.

### 확인

- 문서 출처 표의 22개 파일 항목과 사용자 제공 URL을 대조했다.
- `git diff --check` 통과.

### 다음 작업 / 주의

- `merge_t1.ogg`의 원본 Pixabay URL, contributor, download date는 확보 시 추가 기록한다.
- runtime audio catalog, 이벤트 연결, 재생 검증은 여전히 후속 S6 작업 범위다.

## 2026-08-15 — S6-G1 이벤트 등급·FX budget

Owner: Content/Systems
Branch: `main` working tree
Status: `IMPLEMENTED`

### 작업

- `BallDefinition.fx_tier`를 단일 source로 사용하는 Merge/Cashout 공통 FX budget 경로를 구현했다.
- tier별 active 상한 `12/8/4/2/1`, 한 frame spawn 상한 `4/4/3/2/1`, 전체 gameplay FX 상한 `24`를 적용했다.
- 낮은 tier 포화 중 높은 tier를 보존하고, Stage Clear·Settlement·Scale Shift·Black Hole Phase·Fail/Run End·Finale가 일반 FX를 억제할 수 있는 Transition/Terminal 예약 API를 추가했다.
- Cashout 전용 chunky pixel effect를 추가했다. CUT-IN, Scale Shift, Black Hole presentation 자체는 후속 Goal 범위로 남겼다.

### 확인

- Primary Godot validation: S6-G1 script/scene 5종과 S2-G5/S4-G4 회귀 scene을 포함해 7/7 valid.
- Godot 4.7.1 HUD runtime: 같은 frame Tier 0 20건 중 4건 active/16건 throttle, Tier 3 Merge 1건과 Cashout 1건 보존.
- 같은 runtime에서 Stage Clear 예약 후 active gameplay FX `0`, phase `TRANSITION`; resume 뒤 Tier 3 재허용; Black Hole Finale 뒤 `TERMINAL` 유지.
- HUD 전용 runtime에서 Merge/Cashout tier 차이와 popup을 screenshot으로 확인했고 runtime error는 0건이었다.
- S6-G1 자동 verification scene은 process exit 0이었다. Scene이 bridge 초기화 전에 끝나 stdout은 회수하지 못했으며, 같은 assertion을 live runtime API로 재검증했다.

### 남은 확인 / 주의

- Main runtime은 기존 Stage World 이미지의 `.godot/imported/*.ctex` cache 누락으로 별도 오류가 발생했다. 원본 PNG는 존재하며 S6-G1 변경과 무관하므로 이 Goal에서 수정하지 않았다.
- Q-S6의 실제 Main/Web burst에서 패들·공 가독성, 후반 FX 성능은 S6-G2~G4 통합 뒤 확인한다. 이 때문에 현재 상태는 `IMPLEMENTED`이며 `VERIFIED`가 아니다.
- S6-G2는 `priority_event_reserved(event_key, priority)`를 CUT-IN/화면 연출 입력으로 사용할 수 있고, S6-G3/G4는 확정 tier/priority를 audio catalog와 polyphony 정책에 사용한다.

## 2026-08-15 — S6-G1 최종 검증

Owner: Content/Systems
Status: `VERIFIED`

### 추가 변경

- 실제 Main 화면 확인에서 어두웠던 Tier 3/4 FX 색을 흰색 방향으로 보정해 Play Field 대비를 높였다.
- 포화 시 공 실루엣을 가리던 Tier 0 Merge value label은 생략하고, Cashout 점수 정보는 유지했다.

### 최종 확인

- Godot 4.7.1 CLI S6-G1 자동 scene exit 0: `S6_G1_VERIFIED low_burst_throttled=true high_tier_preserved=true cashout_budgeted=true priority_reservations=true`.
- S2-G3 Merge commit과 S4-G4 MultiMesh 회귀 scene은 각각 exit 0. 관련 script/scene validation 7/7 valid.
- `.godot` import cache를 표준 headless import로 갱신한 뒤 Main headless 120 frames exit 0.
- 실제 Main Galactic 화면에서 active balls `395`, active gameplay FX `6`, 누적 throttle `647` 상태의 공·패들·Tier 3 Event Horizon·Cashout popup 동시 가독성을 확인했다. runtime error 0.
- 같은 background MCP 순간 FPS는 `21`이었다. 도구 호출과 장시간 debug 진행이 포함된 단일 관측이므로 release/Web 성능 근거로 사용하지 않는다.

### 알려진 별도 회귀

- 기존 S2-G5 Presentation verification은 현재 StageDefinition을 Simulation에 적용하지 않아 최초 Merge가 성립하지 않는 stale assertion 4건을 출력한다. S6-G1의 read-only Merge/Cashout 경로와 Core S2-G3 Merge commit은 별도 자동 검증에서 통과했으며, 다른 Owner test는 이 Goal에서 수정하지 않았다.
- S6 전체 Web burst smoke와 release FPS는 S6-G2~G4 통합 뒤 Slice Gate에서 측정한다.

## 2026-08-15 — S6-G1 구현 검토

Owner: Content/Systems
Status: `VERIFIED` 유지

### 검토·수정

- Black Hole Finale `100` 이후 Run End `95`처럼 낮거나 같은 Terminal 예약이 authoritative event를 덮던 우선순위 역전을 차단했다. Terminal 상태에서는 더 높은 예약만 승격할 수 있다.
- Stage source의 `current_state` 내부 필드 직접 접근을 제거하고 공개 `get_runtime_snapshot()`으로 초기 상태를 읽게 했다.
- 전체 active 24개를 Tier 0/1/2로 채운 뒤 Tier 3가 가장 오래된 하위 FX를 교체하는 경로를 자동 검증에 추가했다.
- `reset_runtime_fx()`가 EffectManager의 비-FX 자식까지 제거하지 않도록 S6 gameplay FX metadata가 있는 노드만 정리하고, Terminal lock·내부 sequence를 Retry 기준으로 초기화했다.

### 재검증

- Godot 4.7.1 CLI S6-G1 자동 scene exit 0: burst throttle, high-tier 보존, 전체 상한 eviction, Cashout budget, Terminal dominance, reset 안전성 통과.
- S2-G3 Merge commit, S4-G4 MultiMesh 회귀 scene exit 0.
- Main headless 120 frames exit 0. Windows root certificate store 경고 외 parse/runtime 오류는 없었다.
- 최초 CLI 시도는 기존 Godot 프로세스와 기본 `user://logs` 파일 경합 중 엔진 signal 11로 실패했다. 고유 `--log-file`로 재실행해 프로젝트와 무관한 tooling/log 경합으로 구분했고, 이후 모든 검증은 정상 종료했다.

## 2026-08-15 — S6-G1 2차 구현 검토

Owner: Content/Systems
Status: `VERIFIED` 유지

### 검토·수정

- 효과 수명이 끝나 `queue_free()`를 요청했지만 아직 frame-end 삭제 전인 노드를 active budget에서 제외했다. 삭제 대기 중인 Tier 4가 단일 slot을 점유해 다음 Tier 4 표현을 한 frame 불필요하게 막는 경계 조건을 제거했다.
- 자동 검증에 삭제 대기 FX의 즉시 slot 반환과 같은 Tier replacement 허용을 추가했다.
- `INTEGRATION_CONTRACTS.md`의 `S6 audio ownership` 제목을 실제 범위에 맞게 `S6 FX·audio ownership`으로 수정했다.
- STATUS의 `validation 7/7`을 resource parse·validation으로 명확히 표현해, 별도로 알려진 S2-G5 runtime stale assertion을 통과했다는 뜻으로 오해되지 않게 했다.

### Godot 충돌 기록 정정

- 최초 실패에서 확정된 사실은 기본 `user://logs` 파일 open 실패 직후 Godot engine이 signal 11로 종료됐다는 것이다. 당시 별도 Godot 프로세스가 함께 존재했지만 그것이 파일 open 실패의 직접 원인인지는 확정하지 않았다.
- 고유 `--log-file`을 지정한 모든 후속 실행이 정상 종료했으므로 프로젝트 코드 실패가 아닌 Godot tooling/logging 문제로 분류한다.

### 재검증

- Godot 4.7.1 CLI S6-G1 자동 scene exit 0: `queued_release=true`를 포함한 모든 budget·priority·reset assertion 통과.
- S2-G3 Merge commit과 S4-G4 MultiMesh 회귀 scene exit 0.
- Main headless 120 frames exit 0. Windows root certificate store 경고 외 parse/runtime 오류는 없었다.

## 2026-08-15 — S6-G1 3차 구현 검토

Owner: Content/Systems
Status: `VERIFIED` 유지

### 검토·수정

- Main의 실제 Retry 경로는 `StageManager`가 `FAILED` 뒤 `PLAYING`을 emit하지만 별도 `reset_runtime_fx()` 호출은 없었다. Terminal 상태에서 일반 resume을 거부하던 기존 동작 때문에 Retry 뒤 Merge/Cashout FX가 계속 억제되는 연결 누락을 확인했다.
- 연결된 Stage source의 권위 있는 `PLAYING` 재진입은 내부 `reset_runtime_fx()`로 처리해 Terminal lock을 해제하고 gameplay FX를 다시 허용했다. 외부의 일반 `resume_gameplay_fx()`는 계속 Terminal을 해제하지 못한다.
- Terminal 상태에서는 현재 목록뿐 아니라 향후 event 추가에도 안전하도록 비-Terminal 이벤트의 승격을 명시적으로 거부한다.
- 자동 검증에 Black Hole Finale 뒤 Scale Shift 거부, Stage `PLAYING` 재진입 reset, 이후 Tier 3 Merge 재허용을 추가했다.

### 재검증

- Godot 4.7.1 CLI S6-G1 자동 scene exit 0: `terminal_dominance=true`, `retry_reentry=true` 포함 전체 assertion 통과.
- S2-G3 Merge commit, S4-G4 MultiMesh 회귀 scene과 Main headless 120 frames 모두 exit 0.
- Primary MCP 실제 Main에서 EffectManager→StageManager binding `true`, Black Hole Finale 뒤 `TERMINAL`, Stage `PLAYING` emit 뒤 phase `PLAYING`·reserved priority `-1`, Tier 3 Merge FX `1`을 확인했다.
- 첫 MCP 검사용 임시 스크립트는 로컬 변수 type inference parse 오류가 있었고 타입을 명시한 재실행은 성공했다. 오류 경로가 `gdscript://...`와 `mcp_bridge.gd`였으므로 프로젝트 GDScript 오류와 구분했으며, 검증 뒤 Primary MCP 프로세스를 정상 종료했다.

## 2026-08-15 — S6-G1 반복 감사 1차

Owner: Content/Systems
Status: 검증 전 수정

### 발견·수정

- Cashout은 `ball_center.y - radius > field_bottom` 뒤 emit되므로 큰 공의 원본 위치가 viewport 아래일 수 있었다. gameplay event 위치와 판정은 바꾸지 않고 Cashout effect의 시각 Y anchor만 viewport 하단에서 64px 안쪽으로 제한했다.
- `get_active_effect_count_for_tier()`가 잘못된 Tier를 0/4로 clamp해 진단 값을 왜곡하던 동작을 제거하고 범위 밖 조회는 `0`을 반환하게 했다.
- 새 Cashout effect의 export lifetime을 `0.05~5.0s`로 제한하고 runtime 나눗셈에도 최소값을 적용했다.
- `03_TECHNICAL_DESIGN.md`의 오래된 4인자 Cashout 권장 신호를 실제 producer 계약인 `cashout_completed(score_amount, global_level, world_position)`으로 정정했다.

## 2026-08-15 — S6-G1 반복 감사 2차

Owner: Content/Systems
Status: 검증 전 수정

### 발견·수정

- Terminal 뒤 Stage `PLAYING` 재진입이 화면 lock과 effect만 초기화하고 이전 Run의 accepted/dropped/evicted/priority 누적 카운터를 남기고 있었다.
- Terminal→`PLAYING`은 Retry/새 Run이므로 `reset_runtime_fx(true)`를 사용해 Run 단위 진단 snapshot도 초기화했다. 일반 Stage Shift의 Transition→`PLAYING`은 기존처럼 카운터를 유지한다.
- 자동 검증에 Retry 직후 Merge/dropped/priority counter `0`, 첫 새 Run Merge counter `1`을 추가했다.

## 2026-08-15 — S6-G1 반복 감사 3차

Owner: Content/Systems
Status: 문서 정합성 수정

### 발견·수정

- `STATUS.md` 요약이 `S6-G1~G4` 전체를 Content/Systems 소유라고 표현하면서 같은 문장에서 G2를 Presentation 소유라고 적어 내부 모순이 있었다.
- 실제 Goal 표와 팀 계약에 맞춰 S6-G1·G3·G4는 Content/Systems, S6-G2는 Presentation으로 명확히 분리했다.

## 2026-08-15 — S6-G1 반복 감사 4차

Owner: Content/Systems
Status: 계약 명확화·검증 보강

### 발견·수정

- 숫자 우선도만 보면 `Stage Clear(80) → Final Settlement(70) → Scale Shift(85)`에서 Settlement가 거부돼야 하는 것으로 오해할 수 있었다. Transition 숫자는 동시 표현 충돌/일반 FX 억제용이며 권위 있는 Stage 상태 순서를 재정렬하지 않고, 단조 승격은 Terminal에만 적용한다고 계약을 명확히 했다.
- 자동 검증에 위 3단계 예약 순서, Scale Shift 뒤 gameplay resume, 같은 Run의 진단 counter 유지, Run End `95`에서 Black Hole Finale `100`으로의 Terminal 승격을 추가했다.

## 2026-08-15 — S6-G1 반복 감사 5차

Owner: Content/Systems
Status: 실제 화면 수정

### 발견·수정

- Primary MCP 실제 Main에 viewport 아래 Cashout을 주입한 결과 Y `836` popup이 화면 안에는 있었지만 하단 cabinet frame과 겹쳐 대비가 낮았다.
- visual anchor를 viewport 하단 `96px` 안쪽(Y `804`)으로 올려 어두운 Play Field 안에 유지하고, Cashout label에 2px dark outline을 추가했다.

## 2026-08-15 — S6-G1 반복 감사 6차

Owner: Content/Systems
Status: 디자인 문서 정합성 수정

### 발견·수정

- `docs/design/03_BALLS_FX_AND_MOTION.md`가 S6-G1에 별도 `FxBudgetProfile`, 위치 aggregation, reusable pool을 필수 산출물처럼 적어 최신 사용자 승인 구현과 충돌했다.
- 현재 단일 source of truth는 `EffectManager`의 bounded constants와 Integration Contract이며, profile 추출·aggregation·pooling은 복수 tuning/reduced-effects 요구가 생길 때의 후속 최적화로 명확히 분리했다.
- 같은 구표현이 남아 있던 Goal Roadmap, Technical Review Handoff, Pixel Design Guidelines도 동일한 계약으로 정리했다.

## 2026-08-15 — S6-G1 반복 감사 최종 무발견 회차

Owner: Content/Systems
Status: `VERIFIED` 유지

### 최종 검증

- Primary Godot validation: EffectManager, Cashout script/scene, Merge scene, S6 test script/scene, HUD, Main `8/8 valid`.
- Godot 4.7.1 CLI: S6-G1, S2-G3, S4-G4, S3-G5, S5-G3, S5-G5와 Main headless 120 frames 모두 exit 0. Windows root certificate store 경고 외 project parse/runtime 오류 없음.
- 최종 S6 sentinel: `invalid_tier_query=true`, `cashout_visible_anchor=true`, `transition_sequence=true`, `terminal_dominance=true`, `retry_reentry=true`, `retry_counter_reset=true`.
- Primary MCP 실제 Main: viewport 아래 Cashout source `(800, 1200)`가 `(800, 804)`에 표시되고 `EVENT HORIZON CASHOUT +123K` label과 dark outline이 하단 cabinet 위 Play Field에서 읽힘. runtime error 0, 프로세스 정상 종료.
- 최종 코드·Scene·신호·Goal/Owner/Integration Contract·상위 디자인 문서 재대조에서 새 오류나 어색한 부분 0건.

### 의도적으로 남은 후속 범위

- 기존 S2-G5 stale verification repair는 Presentation-owned 별도 작업이다.
- Q-S6 Web burst와 release frame-time은 S6-G2~G4 통합 뒤 Slice Gate에서 측정한다.
- `FxBudgetProfile`, 위치 aggregation, reusable Node pool은 복수 tuning/reduced-effects 요구가 생길 때 별도 Goal로 승인한다.

## 2026-08-15 — S6-G1 반복 감사 7차

Owner: Content/Systems
Status: 검증 전 수정

### 발견·수정

- 이전 Retry 수정은 Terminal 뒤 Retry만 초기화했다. Pause 메뉴에서 진행 중 Retry를 선택하면 StageManager가 같은 index의 Stage를 다시 시작하지만 EffectManager phase는 `PLAYING`이어서 기존 FX와 counter가 남는 경로를 확인했다.
- Stage source의 `stage_changed`를 read-only 구독하고 새 Stage index가 이전과 같거나 낮으면 Retry/Restart로 판정해 FX·counter를 초기화한다. index가 증가하는 일반 Shift는 유지하며, `stage_changed` 없이 같은 Galactic을 재개하는 Black Hole Phase도 오판하지 않는다.
- 자동 검증에 active Ground Pause Retry cleanup과 normal Shift counter 보존을 추가했다.

### 검증

- Godot 4.7.1 CLI S6-G1 자동 scene exit 0: `active_retry_reset=true`를 포함한 전체 assertion 통과.
- Primary MCP 실제 Main에서 Tier 3 Merge FX를 생성한 뒤 `GameManager._on_retry_requested()`를 호출했다. Retry 전 active FX/merge count `1/1`, Retry 후 `0/0`, dropped/priority count `0/0`, Stage `0/PLAYING`, retry count `1`을 확인했다.
- Primary MCP debug output에 runtime error가 없었고 spawned process를 정상 종료했다.

## 2026-08-15 — S6-G1 반복 감사 8차

Owner: Content/Systems
Status: `VERIFIED` 유지

### 최종 검증

- 코드의 tier 예산, 상태 이벤트 우선도, Terminal 단조 승격, Transition 작성 순서, 신호 연결·해제, Retry/Restart 판정을 계약 문서와 다시 대조했다.
- Primary Godot validation: EffectManager, Cashout script/scene, Merge scene, S6 test script/scene, HUD, Main `8/8 valid`.
- Godot 4.7.1 CLI: S6-G1 sentinel의 `active_retry_reset=true`를 포함한 전체 assertion, S2-G3, S4-G4, S3-G5, S5-G3, S5-G5 회귀, Main Scene 120 frames가 모두 exit 0이었다.
- 실제 Main Pause Retry MCP 검증은 Retry 전 active FX/merge count `1/1`, Retry 후 `0/0`, Stage `0/PLAYING`, runtime error 0이었다.
- `git diff --check`에서 whitespace 오류가 없고 실행 중인 Godot 프로세스도 남지 않았다. Windows root certificate store 경고는 모든 CLI 실행에서 동일한 환경 경고이며 project parse/runtime 오류와 분리했다.

### 남은 범위

- S6-G1 범위 안의 알려진 오류는 없다.
- 기존 S2-G5 stale verification repair와 Q-S6 Web burst/release 성능 측정은 앞서 기록한 별도 후속 범위를 유지한다.

### 문서 표현 수정

- Pause Retry 실런타임 검증이 추가됐는데도 `STATUS.md`가 예전 검증 횟수 표현인 `두 MCP`를 유지하고 있었다. 횟수에 종속되지 않는 `각 MCP runtime error 0`으로 바로잡았다.

## 2026-08-15 — S6-G1 반복 감사 9차·최종 무발견 회차

Owner: Content/Systems
Status: `VERIFIED` 유지

### 결과

- 8차에서 수정한 MCP 검증 표현과 Retry/Restart 계약 문장을 코드·자동 검증·`STATUS.md`에 다시 대조했다.
- S6-G1 자동 scene은 `active_retry_reset=true`를 포함한 전체 sentinel과 exit 0을 다시 확인했다.
- 오래된 문구, 누락된 sentinel, trailing whitespace, 남은 Godot 프로세스를 검사했으며 추가 오류나 어색한 부분을 발견하지 못했다.
- S6-G1 범위의 반복 감사를 이 무발견 회차로 종료한다.

## 2026-08-15 S6-G3 Audio 콘텐츠

Owner: Content/Systems/Release
Branch: `main` working tree
Status: `VERIFIED`

### 변경

- `resources/audio/audio_catalog.tres`에 파일명과 동일한 22개 event key와 OGG AudioStream을 단일 catalog로 등록했다.
- `AudioEventDefinition`은 event key, stream, loop intent만 소유하며, `AudioCatalog`는 read-only key lookup을 제공한다.
- `black_hole_loop`만 loop intent를 가지며, 실제 AudioPlayer 재생 정책은 구현하지 않았다.
- content verification scene은 키 누락/중복, null stream, key-to-filename 불일치, non-OGG source, loop 설정과 unknown-key rejection을 검증한다.

### 검증

- Godot 4.7.1 CLI headless S6-G3 verification exit 0: `S6_G3_VERIFIED audio_events=22 ogg_streams=22`.
- S6-G1 FX budget regression exit 0.
- Main headless 120 frames exit 0.
- `git diff --check` 통과.

### 다음 작업 / 범위 제외

- S6-G4에서 AudioManager가 기존 gameplay signal을 read-only로 구독하고 catalog key를 재생한다.
- priority/polyphony, volume, Web 첫 입력 audio unlock, 실제 Browser playback은 S6-G4/S6 Slice gate에서 검증한다.

## 2026-08-15 S6-G4 AudioManager 기반 구현

Owner: Content/Systems/Release
Status: `IN PROGRESS` — Content 소유 구현 완료, Integration/Web 검증 대기

### 변경

- `AudioManager`가 기존 공개 signal을 read-only로 구독하여 catalog key를 재생하도록 구현했다.
- Merge/Cashout tier, transition, terminal, Black Hole, Pause/Retry의 priority·polyphony·cooldown·volume 정책을 정의했다.
- Retry는 루프·cooldown·전환 억제를 초기화하고, terminal 사운드가 정리한 낮은 priority playback도 선점 진단값에 기록한다.
- 단일 `pause_requested`의 두 번째 호출은 resume으로 처리하며, 전용 resume event가 생길 때까지 `ui_resume`은 보류한다.

### 검증

- Primary Godot validation: AudioManager, S6-G4 verification script/scene `3/3 valid`.
- S6-G4 verification scene exit 0: input unlock, cooldown, shared-group polyphony, transition suppression, terminal preemption, loop stop, Retry reset, pause/resume toggle 검증.

### 남은 작업

- Integration이 Main mount와 보류 event forwarding을 연결해야 한다.
- 실제 Web 첫 입력 재생 및 late-density 청감 검증은 Integration 후 S6 Slice gate에서 수행한다.

## 2026-08-15 S6-G4 담당 표기 보정

- `STATUS.md`의 S6-G4 활성 lane과 Goal Owner를 개인명 또는 축약 lane이 아닌 `Content/Systems/Release 담당`으로 명시했다.
- 역할 담당자가 명확히 보이도록 한 문서 표기 보정이며, AudioManager 구현·재생 정책·Integration 범위는 변경하지 않았다.

## 2026-08-16 S6-G4 구현 정리

Owner: Content/Systems/Release 담당
Status: `IMPLEMENTED`

### 완료 및 검증

- AudioManager mount와 공식 정산 경로 `SettlementService → StageManager → GameManager → AudioManager`를 적용했다.
- Priority/polyphony/cooldown 정책, 정산 start/finish 순차 재생, 공유 Pause toggle, Retry reset을 자동 검증했다.
- 실제 Chrome Web Main에서 Canvas 렌더링, console error 0, 첫 입력 뒤 Pause 음 재생을 확인했다.
- 별도 Web 스트레스 Scene에서 500·1,000볼 렌더링과 console error 0을 확인했다.

### 보류

- `ui_start`, `ui_menu`, `ui_click`, `run_end`은 발생 신호가 제공된 뒤 catalog key 그대로 매핑한다.
- Main Web에서 고밀도 HUD와 음향을 동시에 보는 가독성 확인은 사용자 결정으로 보류한다.
- 보류 항목 때문에 S6-G4는 `VERIFIED`가 아닌 `IMPLEMENTED`로 기록한다.

## 2026-08-16 — S8-G3 Title·Main·Terminal UI

Owner: Content/Systems/Release 담당
Status: `IMPLEMENTED`

### 변경

- `TitleScreen`과 `ResultPanel`을 추가했다. Title은 `start_requested`만 발행하고, Result는 Core terminal snapshot의 deep copy에서 `run_score`만 읽어 `CLEAR SCORE`로 포맷해 표시한다.
- 기존 Pause UI를 gameplay 상태를 직접 바꾸지 않는 modal로 확장했다. 재개, 다시 시작, 설정, 메인 화면은 각각 `resume_requested`, `retry_requested`, `settings_requested`, `main_menu_requested`만 발행한다.
- 독립 검증에서 각 요청의 단일 발행, Result snapshot copy, score formatting, hide/reset, SceneTree pause 무변경을 확인했다. 기존 S1-G5 Pause 요청 검증도 modal 구조에 맞춰 회귀 검증했다.

### 검증

- Primary `godot` validate: Title/Result/Pause scripts·scenes, S8-G3 test, S1-G5 test, Main scene 모두 valid (10/10).
- Primary `godot` S8-G3 verification scene: exit 0.
- Primary `godot` S1-G5 regression scene: exit 0. 두 짧은 scene은 MCP bridge 준비 전 정상 종료됐으며 stderr에 project script/runtime error는 없었다.
- 이 환경에서 Godot CLI executable을 찾을 수 없어 CLI baseline은 실행하지 못했다.

### 다음 작업 / 범위 제외

- S8-G4 Integration이 UI scene mount, `terminal_result_available → ResultPanel.show_result`, Title/Pause/Result request signal과 GameManager wiring, HUD/Pause hide/show, Retry/Main Menu reset을 연결한다.
- S8-G3은 GameManager/StageManager/Core result 계산을 수정하지 않았다. 실제 finale 및 Web 결과 화면 검증은 Integration 뒤에 수행한다.

## 2026-08-16 — S8-G3 Pause UI 레이아웃 보정

Owner: Content/Systems/Release 담당

- `PanelContainer`의 직속 자식이 겹치던 구조를 중앙 패널 안의 단일 세로 컨테이너 구조로 교체했다.
- 게임 배경의 짙은 남색, 청록 CRT, 황동 프레임 색상을 기준으로 패널·구분선·버튼 상태 스타일을 적용했다.
- Primary `godot`에서 Pause scene/script와 S1-G5 검증 script가 모두 valid임을 확인하고, 실제 Project에서 Esc 입력 뒤 제목과 네 버튼이 분리되어 표시되는 스크린샷을 확인했다.
- GameManager의 pause/resume wiring은 S8-G4 Integration 범위로 변경하지 않았다.

## 2026-08-16 — S8-G3 Pause 제어 패널 시각 보정

Owner: Content/Systems/Release 담당

- 기존 평면 버튼을 직선형 황동 베젤과 CRT 유리색의 기계식 제어 패널 스타일로 교체했다.
- 게임 프레임에 쓰이는 `bolt_8.png`를 각 버튼의 대각 모서리에 배치해 캐비닛 그래픽 언어를 이어갔다.
- Primary `godot`에서 Pause scene/script validate를 통과했고, Main runtime의 Esc Pause 화면에서 4개 버튼의 분리된 표시와 볼트 텍스처를 확인했다.

## 2026-08-16 — S8-G3 Pause 버튼 프레임 모듈화

Owner: Content/Systems/Release 담당

- 평면 테두리만 남아 있던 버튼을 기존 `field_bezel_96.png`의 9-slice 프레임, CRT 유리 배경, 대각 픽셀 볼트로 구성된 기계식 모듈로 교체했다.
- Primary `godot` Pause scene validate를 통과했고, 실행 중인 Main의 Pause modal에서 네 버튼이 프레임형 제어 패널로 표시되는 것을 확인했다.

## 2026-08-16 — S8-G3 Pause 모달 황동 프레임 보정

Owner: Content/Systems/Release 담당

- 모달 외곽을 투명한 평면 패널 대신 `field_bezel_96.png` 기반 9-slice 황동 프레임과 어두운 CRT 챔버로 교체했다.
- 내측 여백을 확장해 프레임이 타이틀·버튼과 겹치지 않도록 했으며, Primary `godot` scene validate와 Main runtime Pause 화면에서 표시를 확인했다.

## 2026-08-16 — S8-G3 Pause 모달 Game Field 프레임 적용

Owner: Content/Systems/Release 담당

- 버튼의 기계식 베젤 버전은 유지하고, 모달 외곽만 실제 게임 중앙 필드의 `field_bezel_910x900.png` 황동 파이프 프레임으로 교체했다.
- Primary `godot` scene validate와 Main runtime Pause 화면에서 버튼과 외곽 프레임이 각각 의도한 그래픽으로 분리 표시됨을 확인했다.

## 2026-08-16 — S8-G3 Pause 모달 프레임 안정화

Owner: Content/Systems/Release 담당

- 전체 필드 이미지와 전용 베젤 조각의 확대·축소 사용을 제거했다. 모달 크기에 독립적인 황동 이중 프레임과 CRT 챔버로 외곽을 재구성했다.
- 버튼의 기계식 모듈 디자인은 유지했다. Primary `godot` scene validate와 Main runtime에서 프레임의 비율 깨짐 없이 표시됨을 확인했다.

## 2026-08-16 — S8-G3 Pause 모달 Presentation 9-slice 적용

Owner: Content/Systems/Release 담당

- Presentation `gameplay_frame.tscn`을 조사해 실제 FieldBezel이 `field_bezel_v2_910x900.png`를 `NinePatchRect`, `draw_center=false`, 50px patch margin으로 사용하는 방식을 확인했다.
- 동일한 v2 FieldBezel 9-slice를 Pause 모달 외곽에 적용했다. 전체 프레임 이미지 축소나 수동 조각 배치는 제거했으며, 버튼 모듈 디자인은 유지했다.
- 최초 Primary validate는 이전 MCP bridge port listen 오류로 실패했으나, 새 Primary runtime 세션에서 정상 기동했다. 실제 Pause 화면에서 모달 크기에 맞춰 황동 파이프·커넥터 프레임이 표시됨을 확인했다.

## 2026-08-16 — S8-G3 Pause 모달 내부 여백 조정

Owner: Content/Systems/Release 담당

- 모달 최소 크기를 `440×480`으로 늘리고, 프레임 안쪽 여백을 좌우 62px·상하 64px로 조정했다.
- Primary `godot` scene validate와 Main runtime Pause 화면에서 title·버튼이 황동 파이프 프레임 및 커넥터와 겹치지 않고 분리됨을 확인했다.

## 2026-08-16 — S8-G3 Pause 모달 크기·여백 재산정

Owner: Content/Systems/Release 담당

- Presentation FieldBezel의 50px protected edge와 1600×900 중앙 Field 가시 영역을 기준으로 모달을 `560×640`으로 조정했다.
- 좌우 82px·상하 80px 여백으로 콘텐츠 영역을 약 `396×480`으로 확보하고, 각 버튼의 최소 높이를 54px로 조정했다.
- Primary `godot` scene validate와 Main runtime Pause 화면에서 큰 모달의 9-slice 파이프 프레임, 콘텐츠 간격, 버튼 가독성을 확인했다.

## 2026-08-16 — S8-G3 Pause 모달 크기 복구·좌우 여백 확장

Owner: Content/Systems/Release 담당

- 모달과 버튼 크기를 이전 `440×480`, 48px 버튼 높이로 복구했다.
- 좌우 내부 여백은 이전 62px보다 넓은 72px으로 조정하고, 상하 여백은 64px로 유지했다.
- Primary `godot` scene validate와 Main runtime Pause 화면에서 버튼과 황동 파이프 프레임 사이 간격을 확인했다.

## 2026-08-18 — S6-G4 ui_start·ui_click 연결

Owner: Content/Systems/Release 담당

- 원격 Main에 mount된 `TitleScreen.start_requested`를 AudioManager의 `ui_start` catalog key에 직접 연결했다.
- 전용 사운드가 없는 `PauseMenu.settings_requested`를 일반 확정 조작음 `ui_click`에 연결했다.
- `AudioManager.configure_sources()`에 선택형 TitleScreen source를 추가하고, S8-G4 Integration의 GameManager가 해당 source를 전달하도록 연결했다. 기존 3-source 호출 호환성은 유지했다.
- S6-G4 자동 검증에 start signal 매핑과 source 재설정 시 중복 구독 방지를 포함했다.
- Primary `godot` validation 5/5, S6-G4 verification scene exit 0, 실제 Main runtime에서 `start_requested` 후 활성 key `ui_start` 1개와 runtime error 0을 확인했다.
- 실제 Main Web에 임시 검증 probe를 사용해 simulation tick을 유지한 500공을 구성했다. spatial candidates `2291`, grid cells `432`, 5초 시점 `60 FPS`였고 Paddle·공·HUD 경계를 시각 확인했다.
- 첫 Canvas 입력 뒤 6개 policy sound가 `dropped=0`으로 동시에 활성화됐으며, 이어진 `run_end`가 6개를 선점하고 terminal 단독 재생되는 것을 확인했다. Web console warning/error는 0건이었다.
- 임시 probe와 로컬 서버 파일을 제거한 뒤 clean Web build를 다시 export하고 정상 Main smoke를 확인했다. S6-G4의 남은 보류 항목이 없어 `VERIFIED`로 갱신했다.
- 최종 clean 저장소에서 Godot 4.7.1 CLI/headless S6-G4 verification scene과 Main 120-frame smoke가 모두 exit 0이었다.

## 2026-08-18 — S8-G3 Title Pixel UI 완성

Owner: Content/Systems/Release 담당
Status: `IMPLEMENTED`

- `docs/design/12_PIXEL_DESIGN_GUIDELINES.md`의 1600×900 authoring, 정수 좌표, 4px 간격 계열, 최소 2px 기능 경계, nearest filtering 원칙을 Title에 적용했다.
- Ground runtime background와 실제 Paper-8 v2 L0 `left/right wing`, `field_bezel`을 그대로 재사용해 플레이 화면과 Title 사이의 픽셀 밀도·팔레트·프레임 실루엣 차이를 제거했다.
- AI 생성 목업은 production asset으로 사용하지 않았다. 기능 텍스트는 Godot Label, `START RUN`과 `SETTINGS`는 실제 Button으로 유지했다.
- Title에 `settings_requested` 요청-only signal을 추가했고 기존 `start_requested`와 함께 독립 검증에서 각각 한 번만 발행됨을 확인했다. Integration-owned Main/GameManager는 수정하지 않았다.
- Primary `godot` validate에서 Title scene/script, S8-G3 test script/scene, Main scene 5/5 valid. S8-G3 verification scene은 bridge 초기화 전 exit 0으로 종료됐고, bridge shutdown warning은 짧은 test 종료에 따른 tooling 경고로 분류했다.
- Main runtime에서 Main Menu를 통해 Title을 표시하고 Start 기본 focus, Settings 실제 Button, 1600×900 화면을 확인했다. Screenshot: `.mcp/screenshots/screenshot_1787047440_964.png`.
- Start 버튼 입력 뒤 Title이 숨고 HUD가 표시되어 기존 Title→Ground Integration 흐름이 유지됨을 확인했다. 전체 finale와 Web 검증은 S8-G4/S8-G5 이후에 남는다.
- `ppt-master`는 필수 `attribution_guard.py`를 실행할 Python runtime이 없어 무결성 Gate를 통과하지 못했으므로 실행 파이프라인 사용을 중단했다. 문서 12와 기존 runtime 자산을 source of truth로 사용했다.

## 2026-08-19 — S8-G3 확정 Title UI 실제 버튼 전환

Owner: Content/Systems/Release 담당
Status: `IN PROGRESS`

- 사용자가 최종 승인한 Ground 기계실 Title 시안을 `title_mechanical_ground.webp` 런타임 배경으로 채택했다. `1600×900` viewport에서 nearest filtering과 정수 hit rect를 사용한다.
- 중앙 창의 눈, 좌우 독립 무작위 게이지, 각 게이지 값에 연동되는 전등을 `TitleMechanicalMotion` 장식 레이어로 분리했다. 눈은 중앙 창 Rect 안으로 제한하고 장식 레이어는 입력을 받지 않으며 Title이 숨으면 processing을 멈춘다.
- 이미지에 보이는 `START RUN`과 `SETTINGS` 면 위에 실제 Godot `Button`을 배치했다. 마우스 hit area, 키보드 focus 이동, hover/pressed/focus outline을 제공하면서 기존 `start_requested`와 `settings_requested` 신호 계약을 그대로 사용한다.
- `tests/content/s8_g3_terminal_ui_verification.gd`가 확정 아트·장식 레이어·실제 Button·pointer ownership을 확인하도록 갱신했다.
- Integration-owned `GameManager`, `Main`, `StageManager`는 수정하지 않았다. 기존 `StartButton → start_requested → GameManager._on_start_requested()` 연결은 유지된다. Settings는 기존 `settings_requested` 요청까지만 제공되며 설정 화면 consumer는 아직 구현되지 않았다.
- Godot 4.7.1 editor project load, 신규 WebP import, `TitleMechanicalMotion` GDScript class 등록이 성공했다. 샌드박스 내부 기존 Scene runner는 `user://logs` 접근 실패 뒤 signal 11로 종료되어 tooling 문제로 분류했다.
- workspace 외부가 아닌 임시 log 경로를 지정한 전용 runtime verification은 exit 0과 `S8_G3_TITLE_BUTTONS_VERIFIED actual_buttons=true start_request=1 settings_request=1`을 기록했으며 runtime script error는 0건이었다.
- 전체 S8-G3 UI verification도 exit 0과 `S8_G3_VERIFIED title=true pause_modal=true result_snapshot=read_only requests=once`를 기록했다. S8-G4 skeleton 회귀는 `phase_id=true terminal_once=true reset_safe=true`로 exit 0이었다.

## 2026-08-19 — S8-G3 Result Merge·Run Time 표시

Owner: Content/Systems/Release 담당

- Result Panel에 `TOTAL MERGES`와 `RUN TIME` 통계 행을 추가했다.
- `optional_stats.merge_count`는 음수 방어 뒤 정수로, `run_time_seconds`는 음수 방어와 내림 뒤 `MM:SS` 또는 1시간 이상 `H:MM:SS`로 표시한다.
- Result UI는 snapshot을 deep copy해 읽기만 하며 통계 값이 하나도 없는 fixture에서는 통계 행을 숨긴다.
- S8-G3 전체 UI 검증에서 `148`, `766.9s → 12:46`, 누락 통계 숨김, score·Pause·Title·Main Menu 요청 회귀를 확인했고 Godot 4.7.1 headless exit 0이었다.

## 2026-08-19 — S8-G3 Galactic Terminal Result UI

Owner: Content/Systems/Release 담당
Status: `IN PROGRESS`

- 사용자 승인 Result 시안을 동적 텍스트가 없는 `1600×900` pixel-art background plate로 정리해 프로젝트 자산으로 저장했다. 점수·통계·행동 텍스트는 이미지에 굽지 않고 Godot 노드가 표시한다.
- Result 전체가 `0.82s` 동안 화면 아래에서 위로 올라오는 entrance Tween을 추가했다.
- 좌우 실험관에 서로 다른 개수·속도·위상의 기포를 올리고, 양쪽 게이지 바늘은 최대치 부근에서 서로 다른 주기로 미세하게 떨리도록 별도 `ResultMechanicalMotion` 입력 무시 레이어를 구현했다. Result가 숨으면 processing을 중단한다.
- `RETRY RUN`과 `MAIN`을 실제 Godot `Button`으로 만들고 focus/hover/pressed 상태를 제공했다. 기존 `MAIN SCREEN` 표기는 사용자 지시에 따라 `MAIN`으로 변경했다.
- S8-G3 Content verification과 S8-G4 Integration verification이 Godot 4.7.1 headless에서 모두 exit 0이었다. Retry는 fresh Ground Run과 통계 reset, Main은 안전한 Run 종료와 Title 표시를 확인했다.
- 전체 Black Hole finale의 실제 화면 전환과 Web browser 검증은 S8-G5 및 최종 통합 뒤 남는다.

## 2026-08-19 — S8-G3 확정 Title·Result UI 자동 검증 갱신

Owner: Content/Systems/Release 담당
Status: `IN PROGRESS`

- S8-G3 자동 검증의 Result 기대값을 최종 UI의 값 전용 출력(`1.23M`, `148`, `12:46`)에 맞춰 갱신해 배경에 포함된 고정 라벨과의 중복 표시를 회귀 방지한다.
- Title의 `START RUN`/`SETTINGS`와 Result의 `RETRY RUN`/`MAIN`이 실제 Godot Button이고 빈 tooltip, 입력 소유 hit area, 투명한 normal/hover/pressed/focus StyleBox를 유지하는지 검증한다.
- 장식 motion layer가 pointer 입력을 무시하며, 각 버튼의 커스텀 면 내부 hover·press 상태가 진입·해제되는지 검증한다. Result의 승인된 Retry/Main hit rect 위치와 크기도 고정했다.
- Godot 4.7.1 CLI/headless에서 `tests/content/s8_g3_terminal_ui_verification.tscn`을 단독 실행해 exit 0과 `S8_G3_VERIFIED title=true pause_modal=true result_snapshot=read_only actual_buttons=true hover=face_only requests=once`를 확인했다.
- Windows root certificate store 읽기 오류가 한 번 출력됐으나 테스트 script/runtime error 없이 종료됐으므로 프로젝트 실패가 아닌 환경 경고로 분류한다.
- Integration-owned 파일은 변경하지 않았다. 전체 finale 관찰과 Web 검증은 후속 순차 단계로 남긴다.

## 2026-08-19 — S8-G3 최종 통합 검증 시도

Owner: Content/Systems/Release 담당
Status: `IN PROGRESS — final verification dependency missing`

- Godot 4.7.1 CLI/headless에서 S8-G2 Core, S8-G3 Content, S8-G4 Integration 검증 Scene을 순차 실행했다. 각각 exit 0과 `terminal=once`, `actual_buttons=true hover=face_only requests=once`, `S8_G4_SKELETON_VERIFIED phase_id=true terminal_once=true reset_safe=true`를 기록했다.
- Main을 180 frame headless smoke로 실행해 프로젝트 load/runtime script error 없이 exit 0을 확인했다.
- Web release export가 exit 0으로 완료됐고 로컬 HTTP에서 `index.html`, `index.js`, `index.wasm`, `index.pck`가 모두 200을 반환했다.
- Main의 Black Hole Phase는 아직 실제 Presentation producer가 아니라 `_complete_temporary_black_hole_phase()` 임시 adapter로 완료된다. `docs/goals/STATUS.md`의 S8-G5도 `PENDING`이므로 L2→L3 frame 전환, finale 회전·폭발, HUD 제거 후 Result 등장까지 이어지는 실제 최종 흐름은 검증 대상 자체가 완성되지 않았다.
- 브라우저 제어 초기화가 `Trusted RPC dependency must resolve within a configured trusted code path` tooling 오류로 실패해 Canvas와 console 검증을 수행하지 못했다. Export/HTTP 성공을 실제 Browser 검증으로 대체하지 않는다.
- 따라서 S8-G3는 `IN PROGRESS`를 유지한다. S8-G5 구현과 S8-G4의 임시 adapter 제거·실제 producer 연결 뒤 Desktop/Web 전체 finale를 다시 검증해야 한다.

## 2026-08-19 — S6-G5 BGM 상태 전환

Owner: Content/Systems/Release 담당
Status: `IMPLEMENTED` (Web QA 대기)

### 변경

- 사용자 제공 음악 6개를 `bgm_title`, `bgm_ground`, `bgm_planetary`, `bgm_galactic`, `bgm_pause`, `bgm_result` OGG 카탈로그 항목으로 등록했다.
- `AudioManager`에 SFX pool과 독립된 music player를 추가했다. Title/Start/Stage 변경/Retry/Main Menu, Pause·Resume 위치 복원, Black Hole loop 전환, Final Result BGM을 기존 read-only Signal consumer 경로로 연결했다.
- S6-G5 전용 자동 검증을 추가하고 기존 S6-G3 catalog 검증이 BGM 6개와 loop 정책을 함께 확인하도록 확장했다.

### 확인

- Godot 4.7.1 Primary validate: AudioManager, S6-G3/G4/G5 verification script와 S6-G5 scene 5/5 valid.
- S6-G3/G4/G5 자동 검증 scene은 모두 exit 0. 짧은 scene이 MCP bridge 준비 전에 종료되어 stdout을 수집하지 못한 것은 tooling timing으로 분류했다.
- 실제 Main runtime: first-input unlock 후 `bgm_planetary` 재생, Pause의 `bgm_pause` 전환·저장 위치 `19.97s`, Resume의 Planetary 재개, Black Hole Phase의 music stop+`black_hole_loop`, finale의 loop stop+`bgm_result` 재생을 관찰했다.
- Runtime 종료 로그의 parse warning 1건은 첫 diagnostic `run_script`의 Variant type-warning이며, 이후 수정된 diagnostic과 게임 runtime에는 오류가 없었다.

### 다음 작업 / 주의

- 새 BGM을 포함한 Web export와 실제 Browser 첫 입력 AudioContext/전환 확인은 S9-G2 Release QA에서 수행한다. 이 확인 전 S6-G5를 `VERIFIED`로 올리지 않는다.

### Web export 재확인

- Godot 4.7.1 CLI `--headless --export-release Web build/web/index.html`이 새 BGM import 6개를 포함해 성공했다.
- 로컬 HTTP에서 `index.html`(5,447 bytes), `index.js`(279,815), `index.wasm`(39,513,091), `index.pck`(31,128,012)가 모두 HTTP 200이었다.
- Codex Browser 연결은 `Trusted RPC dependency must resolve within a configured trusted code path` 환경 오류로 초기화되지 않았다. 따라서 실제 Browser Canvas, 첫 입력 AudioContext unlock, console error 관찰은 수행하지 못했으며 export/HTTP 결과로 대체하지 않는다.

## 2026-08-19 — S8-G3 Result 후속 조정·S6-G5 BGM 가독성

Owner: Content/Systems/Release 담당

### 변경

- Result Clear Score 전용 전체 십진수·3자리 쉼표 포맷을 추가했다. 초대형 float는 기존 과학 표기의 유효 3자리를 십진 확장해 의미 없는 부동소수점 오차 자릿수를 노출하지 않는다.
- 긴 Clear Score는 검은 패널 내부에서 3줄 균형 배치와 자동 글자 크기를 사용한다. Total Merges와 Run Time 값은 원본 픽셀 표시창의 광학 중심으로 재배치했다.
- Result 우측 시험관·게이지 장식 좌표를 원본 `1672×941` 기준 좌우 대칭 위치로 수정했다.
- BGM music channel 기본 음량을 `0 dB`에서 `-14 dB`로 낮추고 실제 player 적용값을 S6-G5 검증에 추가했다. SFX/UI 음량 정책은 유지했다.
- Main 초기화가 gameplay를 즉시 시작하지 않고 Title `READY` 상태에서 대기하도록 승인된 Integration 변경을 반영했다. Web 첫 사용자 입력 전 BGM 금지 계약 때문에 초기 Title BGM은 입력 unlock 전 재생되지 않으며, Main Menu 복귀 시에는 이미 unlock 상태라 즉시 재생된다.

### 확인

- Godot 4.7.1 headless: S2-G4 ScoreFormatter, S6-G4 AudioManager, S6-G5 BGM, S8-G3 terminal UI, S8-G4 Integration 검증 exit 0.
- Result 검증은 전체 점수 십진 확장, 3줄 배치, 글자 크기 축소, 값 표시창 좌표, 좌우 시험관·게이지 대칭을 고정한다.
- 최신 Web release export exit 0. Godot editor settings 저장 오류와 Windows root certificate store 오류는 프로젝트 외 sandbox/환경 오류이며 export 및 검증 exit code에는 영향을 주지 않았다.

## 2026-08-20 — S6-G4 Scale Shift 효과음 음량 조정

Owner: Content/Systems/Release 담당

### 변경

- 사용자 청감 피드백에 따라 `scale_shift` 효과음의 정책 음량을 `-1 dB`에서 `-7 dB`로 낮췄다.
- 전환 중요도 priority `85`, polyphony `1`, cooldown `0s`는 유지했다.
- S6-G4 자동 검증에 `scale_shift` priority와 `-7 dB` 정책 assertion을 추가했다.

### 확인

- Godot 4.7.1 CLI/headless S6-G4 verification scene exit 0.
- Primary `godot` validation: AudioManager, S6-G4 verification script/scene 3/3 valid.
- 실제 청감의 최종 선호도는 다음 플레이에서 확인하며, 이번 변경은 다른 SFX/UI/BGM 음량을 수정하지 않았다.

## 2026-08-20 — S6-G4 Scale Shift 음량 복원

Owner: Content/Systems/Release 담당

### 변경

- 사용자 요청에 따라 `scale_shift` 효과음 정책을 다시 `-1 dB`에서 `-7 dB`로 낮췄다.
- priority `85`, polyphony `1`, cooldown `0s`와 모든 다른 SFX/BGM 정책은 유지했다.

### 확인

- Godot 4.7.1 CLI/headless에서 `tests/content/s6_g4_audio_manager_verification.tscn` exit 0을 확인했다. sandbox 실행은 `user://logs` 쓰기 실패로 Godot 자체가 종료되어, 권한을 부여한 동일 CLI 실행에서 정상 통과 여부를 재확인했다.
- Godot 4.7.1 Web release export가 exit 0으로 완료됐다. MIME 타입을 명시하는 로컬 서버(`http://127.0.0.1:8081`)는 갱신된 export를 즉시 제공한다.

## 2026-08-20 — S6-G5 Pause BGM 신호 정정

Owner: Content/Systems/Release 담당

### 변경

- Pause UI가 실제로 제공하는 `pause_requested`와 `resume_requested`를 AudioManager가 각각 구독하도록 수정했다.
- 기존의 추정 토글 대신 Pause는 Stage BGM 저장 후 `bgm_pause` 전환, Resume는 저장 위치의 Stage BGM 재개를 명시적으로 수행한다.
- 시작 직후 Ground BGM 상태에서 Pause/Resume을 누르는 회귀 검증을 S6-G5 자동 검증에 추가했다.

### 확인

- Godot 4.7.1 CLI/headless S6-G5 BGM 및 S6-G4 AudioManager verification scene이 모두 exit 0이었다.
- Web release export가 exit 0으로 완료됐으며, MIME 타입을 명시하는 `http://127.0.0.1:8080` 로컬 서버가 최신 build를 제공한다.

## 2026-08-20 — Pause modal 챔버 inset

Owner: Content/Systems/Release 담당

- Pause modal의 검은 CRT chamber를 외곽 파이프 frame 전체가 아닌 안쪽 개구부에서만 그리도록 사방 50px inset wrapper로 옮겼다.
- 프레임의 파이프·곡선 모서리는 유지하고, 그 바깥으로 보이던 검은 사각형 테두리를 제거하는 범위의 UI 조정이다.
- Godot 4.7.1 CLI/headless S8-G3 terminal UI verification과 Web release export는 모두 exit 0이었다.

## 2026-08-20 — Pause modal chamfered corners

Owner: Content/Systems/Release 담당

- 사용자 피드백에 맞춰 Pause의 검은 CRT chamber를 직사각형 ColorRect에서 22px 대각 절삭 모서리를 가진 Polygon2D로 교체했다.
- 외곽 pipe frame은 유지하며, 내용 패널만 안쪽 개구부에서 사각형이 아닌 chamfer 형태가 된다.
- Godot 4.7.1 CLI/headless S8-G3 terminal UI verification과 Web release export는 모두 exit 0이었다.

## 2026-08-20 — Pause modal chamfer 확대

Owner: Content/Systems/Release 담당

- 초기 22px 절삭이 dim 배경과 대비가 낮아 체감되지 않아, 검은 챔버 네 모서리의 대각 절삭을 48px로 확대했다.
- Godot 4.7.1 CLI/headless S8-G3 terminal UI verification과 Web release export는 모두 exit 0이었다.

## 2026-08-20 — Pause modal 사각 컨테이너 제거

Owner: Content/Systems/Release 담당

- frame PNG 중앙이 투명함을 확인했고, 남던 사각형은 Pause `PanelContainer`의 배경 레이아웃 구조에서 비롯된 것으로 분리했다.
- `PanelContainer`를 배경을 생성하지 않는 `Control`로 교체하고, chamber/bezel/content에 명시적인 fill anchors를 부여했다. chamfered Polygon2D만이 내용 배경을 그린다.
- Godot 4.7.1 CLI/headless S8-G3 terminal UI verification과 Web release export는 모두 exit 0이었다.

## 2026-08-20 — S6-G5 Web Pause/Resume 청감 확인

Owner: Content/Systems/Release 담당

- Chrome Web에서 Pause가 Stage BGM을 `bgm_pause`로 교체하고 Resume가 이전 Stage BGM을 재개하는 것을 사용자가 실제 청감으로 확인했다.
- S6-G5는 Black Hole Phase→Final Result의 실제 Web 완주가 S8-G4/S8-G5 통합에 의존하므로 `IMPLEMENTED`를 유지한다.
## 2026-08-20 — S6-G5 BGM 상태 전환 Web 최종 검증

- Owner lane: Content/Systems/Release
- Goal: S6-G5
- Evidence: 사용자 Chrome Web 청감으로 Pause BGM 전환 및 Resume의 Stage BGM 위치 재개에 이어, 실제 최종 경로의 `bgm_galactic` → `black_hole_loop` → `bgm_result` 전환을 확인했다.
- Result: S6-G5를 `VERIFIED`로 갱신했다.
## 2026-08-20 — S6-G5 Result→Main BGM 회귀 수정

- Owner lane: Content/Systems/Release
- 증상: Result 화면에서 Main으로 복귀해도 `bgm_result`가 계속 재생됐다.
- 원인: ResultPanel의 Main 요청은 AudioManager의 직접 UI signal source가 아니었고, Main 복귀 후 StageManager가 발행하는 `READY` 상태에 음악 전환 정책이 없었다.
- 수정: AudioManager가 authoritative `READY` state에서 Pause 저장 상태와 Black Hole loop를 정리하고 `bgm_title`을 요청하도록 했다.
- Verification: Godot 4.7.1 CLI/headless `s6_g5_bgm_verification.tscn` exit 0. Result BGM→`READY`→Title BGM key 및 실제 music player 재생을 회귀 검증했다.

## 2026-08-20 — Global SFX attenuation

Owner: Content/Systems/Release
Goal: S6-G4 maintenance
Owned files: `scripts/presentation/audio_manager.gd`, `tests/content/s6_g4_audio_manager_verification.gd`

- 사용자의 청감 피드백에 따라 `AudioManager.sfx_volume_offset_db` 기본값을 `-6 dB`로 추가했다. 모든 one-shot, UI, terminal, Black Hole loop는 policy의 상대 volume에 같은 offset을 적용한다.
- BGM은 별도 `music_volume_db` channel을 유지하므로 기존 `-14 dB`와 Stage/Pause/Resume/Result 전환 정책은 변경하지 않았다.
- Godot 4.7.1 CLI/headless S6-G4 verification exit 0: Merge T0 실제 재생값 `-18 dB`, Black Hole finale `-6 dB`; S6-G5 BGM regression exit 0 (`music_transitions=10`). Primary validate 3/3 및 clean Web release export `[ DONE ] savepack` 통과.

## 2026-08-20 — S8-G3 Result 실험관 픽셀 물방울

Owner: Content/Systems/Release

- 사용자 선택 A안에 따라 Result 좌·우 실험관의 원형 윤곽 기포를 제거하고, 각 실험관에 독립적으로 상승하는 정사각 픽셀 물방울을 적용했다.
- 각 물방울은 2~4px의 정수 크기, 어두운 1px 그림자, 좌상단 1px 광택으로 구성해 nearest-scaled pixel-art 화면에서도 원형 벡터 윤곽이 나타나지 않게 했다.
- 기존 좌측 7개·우측 8개 독립 motion과 게이지 움직임, 입력 무시 레이어 계약은 유지했다.
- `S8-G3` content verification에 좌·우 각각의 입자 배열과 `pixel_size` 기반 표현 계약을 추가했다.

### 확인

- Godot 4.7.1 CLI/headless `tests/content/s8_g3_terminal_ui_verification.tscn` exit 0.
- Godot 4.7.1 Web release export `build/web/index.html` exit 0; `build/web/index.pck` 갱신을 확인했다.

## 2026-08-20 — S8-G3 Result 실험관 하단 게이지 재설계

Owner: Content/Systems/Release

- 사용자 요청에 따라 Result 좌·우 실험관 하단의 기존 흰 원형 다이얼을 배경 픽셀 자산에서 제거했다.
- Title UI의 압력계 문법을 축소 적용한 `녹색 → 황색 → 적색` 계단형 반원 눈금과 각진 허브·바늘을 새 Result plate에 그렸다.
- 각 새 바늘 허브는 해당 실험관 하단 캡으로부터 정확히 70px 아래의 대칭 좌표 `(194, 517)` / `(1478, 517)`로 재배치했다. 이전 원형 바늘/허브 드로잉은 Title과 같은 사각 픽셀 표현으로 교체했다.
- 기존 Result 점수·통계·Retry/Main hit area 및 장식 물방울 motion은 변경하지 않았다.

### 확인

- Godot 4.7.1 CLI/headless `tests/content/s8_g3_terminal_ui_verification.tscn` exit 0.
- 갱신된 artwork resource와 실험관→게이지 70px 위치 계약을 verification에 추가했다.
- Godot 4.7.1 Web release export `build/web/index.html` exit 0.

## 2026-08-20 — Ground Clear Score 400M 확정 반영

Owner: Content/Systems/Release
Goal: S3-G1 Stage data maintenance
Owned files: `resources/stages/stage_00_ground.tres`, `tests/content/s3_g1_stage_catalog_verification.gd`, Ground clear-score 문서

- 사용자 확정값에 따라 Ground `clear_score`를 `4e6`에서 `4e8`(400,000,000)으로 변경했다. Planetary `2e18`과 마지막 Galactic `0`은 유지했다.
- Stage HUD 게이지와 Score Clear는 모두 현재 StageDefinition의 같은 `clear_score`를 읽으므로 별도 점수 상수나 판정 코드를 추가하지 않았다.
- Primary `godot` validation 3/3, S3-G1 catalog verification scene exit 0을 확인했다. Main runtime에서 Ground에 `400,000,000` 점수를 반영하자 settlement 뒤 `stage_score=400,000,001`, 상태 `SHIFTING`, pending shift id 생성까지 확인했다.
- MCP runtime을 종료한 clean 상태에서 Godot 4.7.1 Web release export를 완료했다. 로컬 HTTP로 `index.html`, `index.pck`, `index.wasm`이 모두 HTTP 200을 반환했다.

## 2026-08-21 — 선택 1번 공압 램 패들 반영

Owner: Content/Systems/Release (S9-G1 release visual tuning)

- 팀 만장일치로 선택된 1번 시안을 `Paddle._draw()`의 정수 픽셀 드로잉으로 구현했다. 어두운 외곽선, 구리 바디/레일, 황동 캡·리벳, 중앙 녹색 CRT 상태창을 추가했다.
- 시각 요소는 기존 물리 OBB 안에만 그렸다. `paddle_width=240`, `paddle_thickness=16`, 충돌·입력·반사 계산은 변경하지 않았다.
- Primary `godot` validation에서 Paddle script/scene 및 mouse regression script 3/3 valid, `paddle_mouse_test.tscn` exit 0을 확인했다. Main runtime에서 240×16 값과 새 렌더링, runtime error 0을 확인했다.
- MCP runtime 종료 뒤 Godot 4.7.1 Web release export를 완료하고, 로컬 HTTP에서 `index.html`, `index.pck`, `index.wasm`의 HTTP 200을 확인했다.

## 2026-08-21 — S8-G3 Desktop/Web 최종 수동 검증

Owner: Content/Systems/Release
Goal: S8-G3 Title·Main·Terminal UI

- 사용자가 Godot Desktop과 Chrome Web 양쪽에서 실제 finale 이후 S8-G3 Result UI가 표시되는 것을 확인했다.
- Result의 `RETRY RUN`을 누르면 fresh Ground Run으로 재시작되고, `MAIN`을 누르면 Title UI로 복귀하는 것을 두 환경에서 확인했다.
- 기존 Godot 4.7.1 CLI/headless S8-G3 자동 검증의 `title=true`, `pause_modal=true`, `result_snapshot=read_only`, `actual_buttons=true`, `hover=face_only`, `requests=once` 증거와 합쳐 Desktop/Web 수동 검증 Gate를 충족했다.
- S8-G3을 `VERIFIED`로 닫는다. S8-G4 Integration과 S8-G5 Presentation의 별도 Goal 상태는 수정하지 않았다.

## 2026-08-21 — Planetary Clear Score 비율 조정

Owner: Content/Systems/Release
Goal: S3-G1 Stage data maintenance
Owned files: `resources/stages/stage_01_planetary.tres`, Stage data content verification 및 관련 설계 문서

- 사용자 승인에 따라 Planetary `clear_score`를 `2e18`에서 `4e25`로 조정했다. Ground의 `4e8 / Moon 1e8 = 4` 비율을 Planetary의 최고 기본 Run 공 Galaxy(`1e25`)에 동일 적용한 값이다.
- Stage HUD와 Score Clear runtime은 `StageDefinition.clear_score`를 read-only로 소비하므로, 물리·점수 판정·Presentation 구현은 바꾸지 않았다. Galactic의 `0`도 유지했다.
- Godot 4.7.1 CLI/headless `s3_g1_stage_catalog_verification.tscn`과 `s5_g5_three_stage_run_verification.tscn`이 통과했다. 후자는 Planetary의 현재 `clear_score`를 이용한 Score Clear→Shift 경로를 포함한다. Primary `godot` MCP의 두 scene validation도 통과했다.

## 2026-08-21 — S7-G1C Item Ball·Orb producer contract

Owner: Content/Systems/Release
Goal: S7-G1C
Owned files: `scripts/data/item_definition.gd`, `scripts/gameplay/item_*.gd`, `resources/items/**`, `tests/content/s7_g1c_*`, 관련 계약 문서

- `ItemManager`와 별도 Item Ball/Orb runtime state를 추가했다. Stage마다 한 번만 Item Ball을 예약·생성하고, 현재 Stage의 `local_level >= 2` 공 snapshot이 분리된 상태로 닿을 때만 damage를 한 번 commit한다.
- 5번째 유효 hit은 행성 파괴와 Orb 생성만 확정한다. Orb는 local Lv2 runtime radius와 수직 하강 velocity를 사용하며, Paddle pickup 또는 열린 하단 miss 중 하나만 signal한다. 효과 activation, CUT-IN, Core score/Settlement 변경은 의도적으로 구현하지 않았다.
- Item producer signal의 `item_type`은 세 data key(`blizzard`, `fire_core`, `magnet`)를 보존하는 `StringName`으로 확정했고 기술/Integration 계약을 동기화했다. Q-S7의 stale `local Lv3+` 표기는 현재 게임 규칙의 `local Lv2+`로 정정했다.
- Primary Godot validation 6/6 통과. Primary runtime에서 `S7_G1C_VERIFIED item_ball=once hits=5 orb=collect_or_miss`, exit 0을 확인했다. Godot CLI 실행 파일은 PATH와 표준 설치 경로에서 찾지 못해 CLI baseline은 tooling issue로 기록한다.

## 2026-08-21 — S9-G1 Release tuning·telemetry 시작

Owner: Content/Systems/Release 담당
Goal: S9-G1
Owned files: `tests/release/**`, `docs/current/SUBMISSION/07_RELEASE_TELEMETRY.md`, `docs/goals/STATUS.md`

- 실제 Stage 체류, Cashout, local level별 Time Bonus, simulation metric peak를 기록하는 release telemetry schema와 수동 표본 절차를 추가했다. Stage data에는 아직 실제 표본이 없으므로 `base_time`, `clear_score`, `spawn_rate` 또는 time cap을 변경하지 않았다.
- 자동 검증은 Ground global Lv2→local Lv2/+0.5초, Planetary global Lv8→local Lv3/+1.0초, PLAYING 전용 dwell, metric peak 및 chain 밖 global level 거부를 확인하도록 만들었다.
- Primary Godot validation에서 telemetry script/scene 및 기존 S3-G1 catalog script가 모두 valid였다. Primary runtime 실행은 test scene이 exit 0으로 bridge 초기화 전에 의도적으로 종료돼 runtime output을 수집하지 못했다. fallback debug launch도 즉시 종료되어 output을 보존하지 못했으므로, runtime sentinel은 미확인 상태로 남긴다.
- 다음: clean Desktop/Web 자연 플레이 표본 최소 2 Run을 기록하고, 필요할 때만 StageDefinition tuning 변경을 제안한다. S9-G1은 `IN PROGRESS`를 유지한다.

## 2026-08-21 — S9-G1 release-only telemetry runner

Owner: Content/Systems/Release 담당
Goal: S9-G1
Owned files: `tests/release/**`, `docs/current/SUBMISSION/07_RELEASE_TELEMETRY.md`, `docs/goals/STATUS.md`

- Result UI와 gameplay state를 바꾸지 않는 `s9_g1_release_telemetry_runner.tscn`을 추가했다. Main의 Stage/Cashout/metric signal만 관찰해 Stage 종료마다 `S9_G1_TELEMETRY_SAMPLE` JSON을 console에 출력한다.
- Primary Godot validation에서 runner·recorder·verification script와 두 scene이 모두 valid였다.
- Primary runtime에서 runner readiness log는 확인했으나 Main은 S7 Integration-owned `GameManager`의 `ItemEffectGateway` type 누락 parse error로 script load에 실패했다. runner와 무관한 기존 Main/Integration 오류이므로 Core/Integration 파일은 수정하지 않았다. runtime을 종료했으며 자연 플레이 표본은 S7 Integration 복구 뒤에 수집한다.

## 2026-08-21 — S9-G1 runner 최신 Main 재검증

Owner: Content/Systems/Release 담당
Goal: S9-G1

- 최신 Main commit `602ce25`의 gateway class-cache 의존성 수정 뒤 Primary Godot validation에서 `GameManager`, Main scene, telemetry runner script/scene, telemetry verification scene이 5/5 valid였다.
- Primary runtime에서 runner가 Main의 read-only signal을 실제 구독했다. `S9_G1_TELEMETRY_READY` 뒤 Ground Stage 시작, Ground sample JSON 출력, Planetary Stage 진입을 확인했고 runtime error는 없었다.
- 이 동작 검증에는 debug Score Clear를 사용했으므로 출력된 `10.8793s`/18 Cashout sample은 tuning evidence가 아니다. 자연 플레이 2 Run 이상의 Stage별 표본 수집과 tuning 결론은 계속 남아 있다.

## 2026-08-21 — S9-G1 dwell source 정정

Owner: Content/Systems/Release 담당
Goal: S9-G1

- 두 자연 플레이 run의 output을 검토해 runner가 renderer `_process(delta)`를 누적한 dwell과 Core physics timer가 불일치함을 발견했다. Ground timer가 45→40초인데 runner dwell은 약 60초인 표본은 tuning 근거로 사용하지 않는다.
- runner는 이제 renderer delta 대신 `StageManager.get_runtime_snapshot()["run_time_seconds"]`의 Stage 전후 차를 사용한다. 이 값은 Core가 `PLAYING` physics tick에서만 누적하므로 Pause/Shift/Result 및 renderer stall을 제외한다.
- 수정 뒤 syntax/runtime observer 재검증과 자연 플레이 표본 재수집이 필요하다.

## 2026-08-21 — S9-G1 Stage 종료 timer snapshot 정정

Owner: Content/Systems/Release 담당
Goal: S9-G1

- 수정 runner의 첫 자연 플레이 output에서 Ground `end_time=40`이 다음 Planetary의 base time과 같음을 발견했다. 원인은 `stage_changed`가 새 Stage를 초기화한 뒤 이전 표본을 flush해 이전 Stage 종료 timer를 읽지 못한 것이다.
- Clear/Time Up/Failed/Run End lock 시점의 `stage_time_left`를 한 번 고정해 표본 flush에는 그 값을 사용하도록 수정했다. 기존 자연 플레이 표본은 종료 timer가 오염돼 tuning 근거로 사용하지 않는다.
- 다음: syntax와 debug transition output을 재검증한 후 자연 플레이 표본을 다시 수집한다.

## 2026-08-21 — S9-G1 자연 플레이 telemetry 결론

Owner: Content/Systems/Release 담당
Goal: S9-G1

- 수정 runner로 Debug Clear 없이 Desktop Primary runtime 자연 플레이 2 Run, Stage 6개 표본을 수집했다. 각 sample의 `start_time + time_bonus_total_seconds - playing_dwell_seconds = end_time`이 Ground/Planetary/Galactic 전체에서 일치했다.
- Ground는 Time Up→Settlement Clear 1회와 즉시 Score Clear 1회로, Planetary는 즉시 Score Clear 2회로 Scale Shift했다. Ground 종료 잔여 시간은 `19.63s/17.12s`, Planetary는 `34.50s/28.22s`였고 Galactic은 두 Run 모두 Run End까지 도달했다.
- 최고 active ball `156`, candidate `115`, grid cell `154`을 기록했다. 현 일반 플레이 peak 가정 300 및 Web Gate 500 아래이며, 이번 Desktop data에서 성능 tuning 필요성은 관찰되지 않았다.
- Time Bonus로 Galactic timer가 약 50초까지 연장됐어도 actual PLAYING dwell은 약 32~35초이고 Black Hole finale로 Run이 닫혔다. time cap, base time, clear score, spawn rate를 변경하지 않는다.
- S9-G1 산출물과 독립 evidence는 완료됐지만 S6-G2 CUT-IN이 `PENDING`이라 Goal dependency에 따라 `IMPLEMENTED`로 유지한다. S6-G2가 검증되면 이 evidence를 재사용해 S9-G1을 `VERIFIED`로 전환할 수 있다.

## 2026-08-21 — RC-1 scope and S9-G2 start

Owner: Content/Systems/Release 담당
Goal: S9-G1, S9-G2

- 사용자 결정으로 S6-G2 CUT-IN과 S7 Optional Items를 현재 RC-1 범위에서 제외했다. 둘은 이후 presentation/item pass에서 합류하며, 그 시점에는 clean Web QA를 다시 수행한다.
- S9-G1의 자연 플레이 telemetry evidence를 `VERIFIED`로 전환하고 S9-G2를 시작했다.
- Godot 4.7.1 clean temporary Web export가 HTML/JS/WASM/PCK를 생성했다. in-app Browser와 Chrome automation은 Canvas/WebGL fallback만 제공해 실제 gameplay input·resize·audio·FPS·Retry 관찰은 검증하지 못했다. Godot headless Main은 `user://logs` 쓰기 실패 뒤 signal 11로 종료되어 tooling/environment issue로 분리한다.

## 2026-08-21 — S9-G2 RC-1 native runtime smoke

Owner: Content/Systems/Release 담당
Goal: S9-G2

- 사용자 지시에 따라 RC-1 기준을 HEAD `602ce25`와 당시 작업 트리로 고정했다. 범위는 S6-G2 CUT-IN과 S7 Optional Items를 제외한다.
- Primary `godot` background runtime에서 Title 화면 screenshot, `START RUN`, A/D 이동·← 기울기 입력, Pause modal, `R` keyboard Retry 뒤 fresh Ground 상태를 실제 화면으로 확인했다. runtime debug output은 error 0건이었고 MCP 종료도 정상 수행했다.
- modal 내부 Retry button의 MCP click은 tool success에도 화면 상태가 바뀌지 않아 반복하지 않았다. 독립 keyboard Retry는 정상 reset을 확인했다.
- 이 환경의 Chrome/in-app browser automation은 Canvas/WebGL을 지원하지 않아 S9-G2의 실제 Web focus·resize·audio·late-game FPS·Retry는 아직 검증하지 못했다. native smoke는 Web QA의 대체 증거가 아니다.

## 2026-08-21 — S9-G2 clean RC-1 export and baseline validation

Owner: Content/Systems/Release 담당
Goal: S9-G2

- Primary MCP runtime을 종료한 뒤 새 temporary output directory에 RC-1 Web export를 수행했다. `index.html`, `index.js`, `index.wasm`, `index.pck`가 모두 생성됐고 MCP bridge port/key 문자열은 exported HTML/JS에서 발견되지 않았다.
- Godot CLI/headless scene 실행은 user-data directory를 분리해도 전역 `user://logs` 접근 실패 뒤 signal 11로 종료됐다. 이는 이 환경의 Godot logging/tooling 문제로 기록하며 게임 오류로 취급하지 않는다.
- Primary `godot` validate는 `scenes/main/main.tscn`, S9 telemetry verification, 3-stage integration verification, Paddle script를 4/4 valid로 확인했다.

## 2026-08-21 — S9-G2 user Chrome Web QA

Owner: Content/Systems/Release 담당
Goal: S9-G2

- 사용자 Chrome의 `http://127.0.0.1:8080/`에서 RC-1 Web build가 실제 Canvas로 렌더링됨을 screenshot으로 확인했다. DOM의 canvas fallback 문구는 접근성 fallback일 뿐 화면 렌더링 실패가 아니었다.
- Resume 뒤 실제 플레이 화면에서 `A`, `←` 입력에 따른 패들 이동/기울기, Pause modal, modal `RETRY`로 `TIME 44.0`·`STAGE SCORE 0` fresh Ground reset을 확인했다. 각 단계의 browser console error/warn은 0건이었다.
- viewport를 1024×768으로 변경해 레이아웃이 유지되는 것을 screenshot으로 확인했고, 검증 뒤 기본 viewport로 되돌렸다.
- Audio 청취와 자연 3-Stage 완주에 따른 late-game FPS는 이 세션에서 아직 계측/관찰하지 않았다. RC-1 Web QA는 이 두 항목을 남긴 채 `IN PROGRESS`를 유지한다.

## 2026-08-21 — S9-G2 Web Audio 청취 확인

Owner: Content/Systems/Release 담당
Goal: S9-G2

- 사용자 Chrome 재생 환경에서 오디오가 실제로 들림을 사용자 관찰로 확인했다. Web Audio 청취 Gate를 충족했다.
- 남은 검증은 자연 3-Stage 완주 중 late-game FPS 관찰뿐이다.

## 2026-08-21 — S9-G2 late-game performance 관찰 완료

Owner: Content/Systems/Release 담당
Goal: S9-G2

- 사용자 실제 late-game 플레이에서 눈에 띄는 버벅임이 없음을 확인했다. Web export, input, resize, audio, Retry, console 및 체감 성능 Gate가 충족되어 S9-G2를 `VERIFIED`로 전환했다.
- RC-1은 S6-G2 CUT-IN과 S7 Optional Items를 의도적으로 제외한 기준본이다. 두 범위가 합류하면 Web QA를 다시 수행한다.
- 실제 Web Canvas·입력·resize·audio·late-game FPS·Retry는 현 자동화 browser의 Canvas/WebGL 부재로 계속 `UNVERIFIED`다.

## 2026-08-21 — S9-G3 public-hosting handoff

Owner: Content/Systems/Release 담당
Goal: S9-G3

- 검증된 `build/web` RC-1 산출물(HTML/JS/WASM/PCK)을 독립 `gh-pages` 배포 브랜치로 push했다. 원격 branch HEAD는 `50ac78888e1541cc344222c14d89d83921ea4d59`이다.
- GitHub CLI 계정은 `dlfjsld1/snowball-effect`에 push 권한은 있으나 admin 권한이 없었다. GitHub Pages REST 활성화 요청과 브라우저의 Pages Settings 접근이 모두 404로 거부되어, Pages 서비스 자체를 활성화하거나 공개 URL을 확정할 수 없었다.
- 따라서 S9-G3은 `PENDING`을 유지한다. 저장소 소유자/관리자가 `gh-pages` branch의 root(`/`)를 GitHub Pages source로 활성화하거나, 접근 승인 없는 다른 정적 호스팅 대상을 지정해야 한다. 공개 URL 생성 뒤 새 세션에서 Start·완주·Retry·console을 재검증하고 submission checklist/media/form을 마무리한다.

## 2026-08-21 — S9-G3 itch.io 공개 배포 검증 완료

Owner: Content/Systems/Release 담당
Goal: S9-G3

- itch.io 공개 URL `https://kosh1668.itch.io/snowball-effect`를 배포 대상으로 확정했다. 공개 페이지의 설명과 커버 이미지가 정상 표시됨을 사용자가 확인했다.
- 새 시크릿 창에서 URL을 직접 열어 캐시 없는 Canvas load 뒤 Start와 키보드 입력을 확인했다. 이어 실제 한 판을 완주해 Result 화면을 확인하고 Retry까지 수행했다.
- 기존 S9-G2의 실제 Chrome console error 0, Canvas·입력·audio·resize·Retry·late-game 성능 evidence와 결합해 Public Web Build Gate를 충족했다.
- Result: S9-G3을 `VERIFIED`로 전환한다.

## 2026-08-21 — S7-G2 Blizzard content runtime

Owner: Content/Systems/Release 담당
Goal: S7-G2
Owned files: `scripts/gameplay/item_blizzard.gd`, `tests/content/s7_g2_blizzard_verification.*`, `docs/team/INTEGRATION_CONTRACTS.md`, `docs/goals/STATUS.md`

- `ItemBlizzard`가 `item_blizzard.tres`의 duration `5s`, spawn multiplier `×3`을 source of truth로 사용하도록 구현했다. 재획득은 남은 시간을 full duration으로 갱신하지만 multiplier를 중첩하지 않는다.
- 만료와 run reset은 `spawn_multiplier_changed(1.0)`을 정확히 한 번 발행한다. 이 Content runtime은 GameManager·StageManager·simulation·score/settlement를 수정하지 않는다.
- Integration contract에 Content `activate/advance/reset_runtime`와 `spawn_multiplier_changed(multiplier)`를 추가했다. Integration spawn controller가 base Stage spawn rate에 한 번 적용하고 normal `1.0`으로 복구해야 한다.

### 확인

- Primary `godot` validate: `item_blizzard.gd`, S7-G2 verification script/scene 3/3 valid.
- Primary `godot` verification scene은 process exit 0으로 종료했다. 빠른 종료로 MCP bridge가 attach되기 전 닫혀 stdout sentinel을 수집하지 못했지만, Godot runtime error는 없었다.
- Godot CLI는 이 환경에서 PATH/standard install location에 없어 baseline 실행을 못 했다. 실제 Main wiring·CUT-IN activation·Web smoke는 Integration consumer가 추가된 뒤 재검증한다.

## 2026-08-21 — S7-G2 Blizzard graphics ownership

Owner: Content/Systems/Release 담당
Goal: S7-G2 documentation/ownership update

- 사용자 지정에 따라 Blizzard 전용 Item Ball·Orb styling, `BLIZZARD!` cue, active 동안의 장식 눈을 Content/Systems/Release 담당 범위로 확정했다.
- `scripts/presentation/item_blizzard_visual.gd`, `scenes/effects/item_blizzard_visual.tscn`, `assets/particles/items/blizzard/**`, `tests/content/s7_g2_**`를 해당 범위의 Owned Files로 기록했다.
- ItemManager producer event와 `ItemBlizzard.active_state_changed(snapshot)`은 read-only visual 입력이며, Integration이 Main mount/wiring만 담당하고 visual은 점수·타이머·spawn multiplier·simulation을 변경하지 않는 계약을 추가했다.
- 이번 변경은 문서/소유권만 다루며 런타임 파일은 수정하지 않았다. 기존 S7-G2 logic의 `IMPLEMENTED` 상태는 유지하고, graphics 완료 근거는 추가하지 않았다.

## 2026-08-21 — S7-G2 Blizzard graphics implementation

Owner: Content/Systems/Release 담당
Goal: S7-G2
Owned files: `scripts/gameplay/item_manager.gd`, `scripts/presentation/item_blizzard_visual.gd`, `scenes/effects/item_blizzard_visual.tscn`, `tests/content/s7_g2_**`, `tests/content/s7_g1c_item_producer_verification.gd`

- `ItemBlizzardVisual`을 추가했다. Blizzard Item Ball은 ice-core/5-hit crack 표시, Orb는 cyan snow-cross, 활성 Blizzard는 `BLIZZARD!` duration cue와 최대 48개의 절차적 장식 눈 픽셀로 표현한다.
- `ItemManager.item_planet_spawned(item_type, world_position, radius)`를 read-only producer signal로 추가해 Item Ball이 첫 damage 이전부터 표시될 수 있게 했다. 기존 producer verification도 Stage당 1회 spawn 및 display signal 1회를 함께 확인하도록 보강했다.
- visual은 ItemManager/ItemBlizzard의 read-only event/state만 소비하며 score, timer, spawn multiplier, simulation을 변경하지 않는다. Main mount와 signal 연결은 Integration 작업으로 남긴다.

### 확인

- Primary `godot` validate: ItemManager, Blizzard visual script, visual verification script/scene, producer regression scene 6/6 valid.
- Primary visual verification scene은 exit 0으로 종료했다. 빠른 test 종료로 MCP bridge가 attach되기 전 닫혀 stdout sentinel은 수집하지 못했고 runtime error는 없었다.
- Main wiring, 실제 Orb CUT-IN, Desktop/Web visual smoke는 아직 실행하지 않았다.

## 2026-08-21 — S7-G2 Blizzard snow-crystal pixel pass

Owner: Content/Systems/Release 담당
Goal: S7-G2
Owned files: `scripts/presentation/item_blizzard_visual.gd`, `assets/particles/items/blizzard/**`, `tests/content/s7_g2_blizzard_visual_runtime_preview.*`

- Presentation/UI의 기존 asset concept 제작 방식인 built-in ImageGen을 사용해 자연 눈결정의 육각 대칭·분기 motif를 탐색했다. 고해상도 생성 결과는 production에 import하지 않았다.
- `ItemBlizzardVisual`을 2px logical grid의 6방향 stepped branch, 진한 navy outline, cyan/white ice highlight, 5-hit crack overlay로 수작업 pixel-cleanup했다. 사용 tool, 원본 위치, cleanup 담당자, 최종 palette를 `assets/particles/items/blizzard/README.md`에 기록했다.
- 실제 `Main`을 임시 preview에서 읽기 전용으로 instantiate하고 PlayField에 visual을 놓아 활성 Blizzard·Item Ball·Orb의 화면 배치를 capture했다. Integration-owned Main scene은 수정하지 않았다.

### 확인

- Primary `godot` validate: Blizzard visual script/scene/verification scene 및 Main runtime preview script/scene 5/5 valid.
- Primary runtime preview: Main frame·HUD·Paddle 위에 `ICE CRYSTAL 2/5`, `BLIZZARD! 4.3s`, Orb, 48 snow pixels가 정상 표시됐고 runtime error 0이었다.
- Godot CLI baseline은 이 환경에서 executable을 찾지 못한 기존 tooling issue로 실행하지 못했다.

### 다음 작업 / 주의

- 실제 Main mount 및 ItemManager/ItemBlizzard signal 연결은 Integration-owned 작업이다. 해당 연결 전에는 actual Orb pickup→CUT-IN과 Browser/Web smoke를 완료로 표시하지 않는다.

## 2026-08-21 — S7-G2 Blizzard selected crystal in Main preview

Owner: Content/Systems/Release 담당
Goal: S7-G2
Owned files: `assets/particles/items/blizzard/blizzard_crystal.png`, `scripts/presentation/item_blizzard_visual.gd`, `tests/content/s7_g2_blizzard_visual_runtime_preview.*`

- 사용자가 선택한 built-in ImageGen 눈결정 PNG를 alpha 그대로 추가했다. `ItemBlizzardVisual`은 nearest filtering과 integer `96×96px` draw box로 해당 source의 도트 블록을 유지한다.
- Godot importer가 이 생성 PNG를 resource로 등록하지 않는 환경에서도 안정적으로 표시하도록 `Image.load_from_file` → `ImageTexture.create_from_image` 경로를 사용했다. PNG는 raw project asset으로 유지된다.
- Primary validation 3/3 뒤 실제 Main scene을 temporary read-only preview로 실행해 Blizzard Item Ball, `ICE CRYSTAL 2/5`, Orb, `BLIZZARD! 4.3s`, decorative snow가 함께 나오는 screenshot을 확보했다. runtime error는 0건이었다.

### 다음 작업 / 주의

- 이는 Main 기반의 temporary preview다. Integration이 visual scene을 mount하고 ItemManager/ItemBlizzard signal을 연결해야 live game event에도 자동 표시된다.

## 2026-08-21 — S7-G2 Blizzard crystal scale adjustment

- 사용자 피드백에 따라 Blizzard crystal display box를 `96×96px`에서 `64×64px`로 축소했다. nearest filtering과 투명 alpha 처리는 유지한다.
- Primary `godot` validate 2/2 및 Main-based runtime preview screenshot에서 축소 크기와 runtime error 0을 확인했다.

## 2026-08-22 — S7-G2 Blizzard Main·Web smoke

- Presentation/UI와 Core/Integration 승인 뒤 Main에 Blizzard visual mount, ItemManager producer signal, Blizzard active state, CUT-IN completion cue→Gateway activation을 연결했다.
- Primary `godot` validation에서 Blizzard visual, GameManager, Main scene 3/3 valid. 실제 Main runtime에서 5-hit Item Ball 파괴→Orb collect→CUT-IN→Gateway 1회 activation→Ground spawn `6→18`, 48 snow, 5초 active를 확인했다.
- 최신 Web release export를 생성해 `http://127.0.0.1:8080`에서 사용자가 Item Ball·Orb·CUT-IN·Blizzard 출현을 확인했다. Retry/Main reset과 browser console error는 별도 확인이 남아 있다.

### 추가 사용자 확인

- 사용자가 Web 빌드에서 Retry와 Main 복귀가 정상 동작함을 확인했다. Browser console error 확인만 남긴다.

### 완료 검증

- 사용자가 Browser console error 없음까지 확인했다. Primary runtime에서 실제 패들 조작 중 Blizzard Item Ball 생성과 2/5 damage를 재현했고, 12회 Stage 생성에서 Blizzard 2회와 전용 visual 표시를 확인했다.
- 앞서 확인한 5-hit→Orb collect→CUT-IN→spawn rate `6→18`, 48 snow, 5초 active 및 최신 Web 사용자 smoke와 합쳐 S7-G2를 `VERIFIED`로 전환했다.

## 2026-08-22 — S7-G3 Fire Core content runtime

Owner: Content/Systems/Release 담당
Goal: S7-G3
Owned files: `scripts/gameplay/item_fire_core.gd`, `tests/content/s7_g3_fire_core_verification.*`, `docs/team/INTEGRATION_CONTRACTS.md`, `docs/goals/STATUS.md`

### 작업

- `ItemFireCore`를 추가해 `item_fire_core.tres`의 duration `8s`, magnitude `×10`을 timed read-only state로 제공했다.
- 잘못된 ItemDefinition은 거부하고, 재획득은 열린 Fire window를 중첩하지 않고 full duration으로 갱신한다.
- `fire_window_changed(active)`와 `active_state_changed(snapshot)`를 제공하며, 만료와 Retry/Main reset은 neutral multiplier `1.0` 상태로 한 번 복구한다.
- Fire component는 ScoreLedger, SettlementService, StageManager, GameManager 또는 simulation을 직접 수정하지 않는다.

### 확인

- Primary `godot` validation: Fire Core runtime, verification script, verification scene 3/3 valid.
- 전용 verification scene은 Godot process exit `0`으로 종료했다. 단, short-lived scene이 MCP bridge 초기화 전에 종료돼 stdout sentinel을 회수하지 못했다. stderr에는 bridge teardown warning만 있었고 project parse/runtime error는 없었다.
- Godot CLI executable은 PATH와 standard install location에서 발견되지 않아 headless baseline을 실행하지 못했다. Primary 관찰 한계와 대조한 fallback debug run도 intentional exit 뒤 active process/output을 보존하지 못했다. 이는 local tooling/short-lived-scene 관찰 제약으로 분리한다.

### 다음 작업 / 주의

- Core/Integration은 Fire window를 소비해 Paddle contact 시 Fire flag를 중앙 simulation 배열에 부여하고, Merge OR 계승과 Fire ball Active Cashout ×10을 구현해야 한다.
- Time Bonus와 Final Settlement는 Fire multiplier를 읽지 않는다. 실제 Item CUT-IN, Main wiring, Desktop/Web Q-S7 검증은 아직 범위 밖이다.

## 2026-08-22 — S7-G4 Magnet content command

Owner: Content/Systems/Release 담당
Goal: S7-G4
Owned files: `scripts/gameplay/item_magnet.gd`, `scripts/data/item_definition.gd`, `resources/items/item_magnet.tres`, `tests/content/s7_g4_magnet_verification.*`, `docs/team/INTEGRATION_CONTRACTS.md`, `docs/goals/STATUS.md`

### 작업

- `ItemMagnet`을 추가해 ItemDefinition의 duration `7s`, influence range `96`, pair acceleration cap `120`, neighbour limit `2`를 read-only timed force command로 제공했다.
- 재획득은 force를 중첩하지 않고 남은 시간을 full duration으로 갱신하며, 만료·Retry/Main reset은 `active=false`, range/cap `0`, neighbour limit `0`의 neutral command를 발행한다.
- `ItemDefinition`에 Magnet 전용 tuning 필드를 추가했다. Content는 ball snapshot, Spatial Grid, position/velocity, simulation loop를 직접 수정하지 않는다.
- Integration/Core가 사용할 계약을 추가했다: Gateway의 matching activation을 ItemMagnet에 전달하고, Core가 기존 Spatial Grid에서 같은 level의 가까운 1~2개 이웃만 선택해 cap 안의 pair force를 적용한다.

### 확인

- Primary `godot` validation: ItemDefinition, ItemMagnet, verification script, verification scene 4/4 valid.
- Primary Godot background runtime: `S7_G4_IMPLEMENTED duration=7 range=96 acceleration_cap=120 neighbour_limit=2 reset=neutral simulation_unchanged=true`, process exit 0. Runtime script error 없음.
- Godot CLI executable은 PATH 및 표준 설치 경로에서 찾지 못해 CLI/headless baseline은 실행하지 못했다. 이는 기존 local tooling issue로 분리한다.

### 다음 작업 / 주의

- Integration은 ItemMagnet mount, matching Gateway activation, per-tick `advance(delta)`, Retry/Main `reset_runtime()`을 연결해야 한다.
- Core는 active command를 Spatial Grid consumer로 받아 같은 level의 최대 두 이웃만 처리하는 bounded attraction을 구현하고, 1,000-ball metric 회귀를 측정해야 한다.
- 그 wiring 이후 실제 Orb→CUT-IN→Magnet, 만료 복구, Desktop/Web Q-S7 smoke를 수행하기 전에는 `VERIFIED`로 올리지 않는다.

## 2026-08-23 — S10-G2 Settings v1 panel

Owner: Content/Systems/Release

### 작업

- `SettingsPanel` 단일 재사용 view와 scene을 추가했다. Master Volume `0..100`, Mute, Fullscreen의 snapshot을 draft로 표시하며, system API나 persistence에 접근하지 않는다.
- panel은 Integration adapter가 전달할 valid `(session_id, snapshot, return_view)`로만 열리고, `settings_apply_requested(session_id, draft)`와 `settings_close_requested(session_id)`만 발행한다. matching snapshot은 Apply 중복 잠금을 해제하고 matching closed return만 panel을 숨긴다.
- stale close·중복 Apply/Close를 거부하고, Title/Pause return view를 panel state에 보존한다. 최소 focus 진입점은 Volume slider로 두었고 이후 visual/focus polish는 S10-G3에 남긴다.

### 확인

- Primary `godot` validation: SettingsPanel script/scene 및 Content verification script/scene 4/4 valid.
- Primary background runtime: `S10_G2_SETTINGS_PANEL_VERIFIED shared_instance=true draft=true request_once=true return_views=true`, exit 0. MCP bridge shutdown-only warning 외 runtime script error는 없었다.

### 다음 작업 / 주의

- 현재 S10-G1 Main handoff에는 `SettingsPanel` mount와 Title/Pause request에서 panel session을 여는 relay가 없다. 이 Content Goal의 owned files 밖이므로 별도 Integration Goal에서 Main mount, GameManager/adapter signal relay, matching close return wiring을 추가해야 한다.
- 실제 Web fullscreen/persistence와 frozen Pause return은 S10-G4 acceptance에서 검증한다.

## 2026-08-23 — S10-G1 three-volume settings contract

Owner: Content/Systems/Release

### 작업

- 사용자 확정에 따라 Settings v1 snapshot을 `master_volume`, `bgm_volume`, `sfx_volume`의 0~100 정수 세 값으로 교체했다. Mute와 Fullscreen persistence·system call은 제거했다.
- SettingsAdapter는 Master bus gain만 직접 적용하고, GameManager가 read-only snapshot을 AudioManager로 넘긴다. AudioManager는 BGM과 SFX의 기존 base gain을 유지한 채 각각의 user gain을 합성한다.

### 확인

- Primary `godot` validation: SettingsAdapter, AudioManager, GameManager, adapter fixture, three-volume Main fixture와 Main scene 7/7 valid.
- Adapter fixture exit 0으로 session/stale rejection, persistence/corrupt fallback, Master gain을 확인했다. Main fixture exit 0(`S10_G1_THREE_VOLUME_VERIFIED persistence=true master=true bgm_sfx_relay=true`)으로 BGM/SFX channel relay를 확인했다.

### 다음 작업 / 주의

- 기존 Mute/Fullscreen `SettingsPanel`은 새 snapshot을 의도적으로 거부한다. 다음 S10-G2에서 Master/BGM/SFX 세 slider UI와 fixture를 새 contract로 교체해야 실제 Settings 진입을 다시 열 수 있다.

## 2026-08-23 — S10-G4 Settings Web acceptance·update

Owner: Content/Systems/Release

### 확인

- 최신 local Web build를 `http://127.0.0.1:8080`에서 실제 browser canvas `1280×720`로 열었다. Title 화면과 Settings modal의 정상 표시, console error 0건을 확인했다.
- Title Settings에서 Master Volume을 `48%`, Value Popups를 off로 Apply한 뒤 Close→page reload→Settings 재진입해 같은 값이 복원됨을 확인했다. 이어 Master/BGM/SFX를 각각 조절해 value label 반영을 확인했다.
- Run 진입 후 Escape Pause에서 Settings를 열고 Close했을 때 frozen Pause modal로 정확히 돌아오는 것을 확인했다. 테스트로 변경한 값은 Master/BGM/SFX `100%`, Value Popups on으로 Apply 복구했다.

### 범위

- itch.io upload/publish는 이번 요청의 범위에 포함하지 않았고, local Web build acceptance만 수행했다.

## 2026-08-23 — S10 Settings preview / Apply-close refinement

Owner: Content/Systems/Release with Integration handoff

- SettingsPanel은 각 slider/toggle change에 full draft를 담은 `settings_preview_requested(session_id, draft)`를 내보낸다. Preview는 저장 없이 현재 Master/BGM/SFX 및 Value Popups 출력에 즉시 반영된다.
- `APPLY`는 현재 preview draft를 저장한 뒤 matching Settings modal을 닫는다. `CLOSE`는 저장하지 않은 preview를 마지막 Apply snapshot으로 복원한 뒤 닫는다.
- Primary `godot` validate 6/6, panel fixture exit 0, adapter fixture exit 0을 통과했다. Main runtime probe는 preview `50` → Close restore `100`, preview `60` → Apply modal closed/persisted `60`을 확인했고 마지막으로 Master를 `100`으로 복구했다.
- Godot 4.7.1 Web release export를 `build/web/`에 다시 만들었다. local `http://127.0.0.1:8080` browser `1280×720`에서 Master preview `48%` 표시와 Apply 즉시 modal close, console error 0을 확인한 뒤 Master `100%`를 Apply 복구했다. export 중 Windows root certificate/editor settings write warning이 있었으나 savepack은 완료됐고 Web runtime 오류는 없었다.

## 2026-08-23 — S10 Settings mouse acceptance

Owner: Content/Systems/Release

- 원인은 Godot Button의 default release activation이었다. 마우스를 버튼 안에서 누른 뒤 바깥에서 놓으면 press가 취소되므로, drag-end 상황에서 클릭이 무시된 것처럼 보였다.
- Apply/Close를 `ACTION_MODE_BUTTON_PRESS`로 전환하고 pointer cursor를 추가했다. 첫 mouse press에서 한 번 수락하므로 drag-out 뒤에도 확정되며, double-click의 두 번째 press는 이미 닫힌 modal에 전달되지 않아 의도적으로 무시된다.
- Primary validate 3/3 및 panel fixture exit 0. clean Web export를 새로 만들고 browser에서 slider drag, Apply press-drag-out, Close double-click을 확인했으며 console error 0이었다. export 전 development `McpBridge` autoload를 일시 제외하고 원본 project setting은 복구했다.
