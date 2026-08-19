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
