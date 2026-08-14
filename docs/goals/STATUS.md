# Goal Status

상태와 검증 Evidence의 유일한 기록 장소다. `VERIFIED`는 실제 실행 결과가 있을 때만 사용한다. 역할과 lane은 초기안이며 변경 시 [`../team/`](../team/) 문서와 함께 갱신한다.

## Active lanes

| Lane | Active Goal | Owner | 상태 |
|---|---|---|---|
| Core | 없음 | 본인/팀 리드 | available |
| Presentation | 없음 | 팀원 A | available |
| Content/Systems | 없음 | 팀원 B | available |
| Integration | 없음 | 본인/팀 리드 | available |

각 lane은 `IN PROGRESS`를 최대 하나만 가진다. 서로 다른 lane은 Dependencies와 Integration Point가 충족되면 병렬 진행할 수 있다.

## Integration lock

| Integration Goal | Locked Files | 상태 |
|---|---|---|
| 없음 | 없음 | unlocked |

## Goal matrix

| Goal | Owner | 상태 | Evidence / 남은 검증 |
|---|---|---|---|
| S0-G1 프로젝트 부트 | Integration | VERIFIED | 2026-08-09 Godot 4.7.1 CLI headless run exit 0. Primary `godot` MCP runtime launch은 strict elicitation 미지원으로 차단; baseline 통과 후 fallback `godot_fallback` debug run 성공(치명 runtime error 없음). WASAPI 출력 장치 실패로 dummy audio fallback만 기록됨. |
| S0-G2 입력·공유 씬 골격 | Integration | VERIFIED | Input Map 6개 action과 공유 mount tree 확인. Godot 4.7.1 CLI editor load/Main run exit 0, `godot` MCP scene tree 조회 성공. 실제 A/D+회전 동시 동작 검증은 입력 소비자가 존재하는 S1-G2로 이동. |
| S0-G3 Web smoke | Content/Systems | VERIFIED | Godot 4.7.1 single-threaded Web release export exit 0. 로컬 HTTP에서 HTML/JS/WASM/PCK 모두 200. 새 브라우저 탭에서 Godot 4.7.1 WebGL2 기동, Canvas 1280×720→1024×768 resize, Canvas focus 유지 및 A/← 입력 전달, console warning/error 0건. |
| S1-G1 배열 풀 낙하 | Core | VERIFIED | 2026-08-10 팀 플레이테스트로 승인된 Lv1 radius 4 logical units(visual/collision diameter 8)와 160 world units/s Spawn tuning을 gravity 0 free-flight 경계에서 재검증. 100공/slot reuse/좌·우·상단 반사·열린 하단 구조 유지, Godot 4.7.1 headless exit 0 및 Primary `godot` runtime 확인. |
| S1-G2 패들 조작·반사 | Core | VERIFIED | 2026-08-11 direct Mouse sweep 중 큰 공이 깊게 겹칠 때, sweep entry normal을 유지한 채 최종 Paddle transform 기준으로 surface 밖 보정하도록 회귀 수정했다. Primary `godot` reflection test exit 0(양면·translation·rotation·large overlap), mouse test exit 0, S1-G1 verification exit 0, S1-G3 verification exit 0, Main runtime에서 좌/우 large-ball overlap이 각각 올바른 normal과 분리 상태를 확인했고 runtime error 0. Web은 기존 사용자 Chrome 수동 검증을 유지한다. |
| S1-G3 Active Cashout 논리 | Core | VERIFIED | 2026-08-10 Lv1 radius 4에서도 열린 하단 Cashout, slot reuse, stage/run ledger 1회 반영과 reset을 재검증. Godot 4.7.1 headless exit 0 및 Primary `godot` runtime 확인. |
| S1-G4 최소 HUD | Presentation | VERIFIED | `score_changed`/`ball_count_changed` read-only 구독과 `reset_view()` 구현. Godot 4.7.1 자동검증 exit 0: stage/run 1회 표시, balls 1 표시, HUD reset 후 Core state 불변. Primary `godot` validate 4/4. |
| S1-G5 Pause·Restart 요청 UI | Content/Systems | VERIFIED | `pause_requested`/`retry_requested` request-only UI와 paused label 상태 구현. Godot 4.7.1 자동검증 exit 0: input pause 1회, button retry 1회, SceneTree/gameplay 직접 변경 없음. Primary `godot` validate 4/4. |
| S1-G6 Pause·Restart 통합 | Integration | VERIFIED | 2026-08-09 최신 clean Web release export를 사용자의 실제 Chrome 수동 플레이로 검증. Canvas, Mouse X direct 이동, Mouse Wheel 자유회전, A/D 이동, A/D release 뒤 위치 유지, 다음 실제 MouseMotion에서만 Mouse control 복귀, Paddle 이동/회전 충돌, Pause/Retry가 정상이며 browser console game error 0. |
| S2-G1 공·점수 데이터 | Content/Systems | VERIFIED | 2026-08-12 catalog resource와 content verification을 최신 계약으로 재정렬했다: Lv6 Sun, Lv7 Red Giant, Lv9 Nebula, Lv10 Galaxy, Lv14 `Black Hole`/`black_hole`. 15종의 score/radius/mass/fx tier와 Time Bonus 부재를 유지했다. Primary `godot` validate로 definition/catalog/test script/test scene 4/4 valid, Main runtime에서 15개 전부의 name/key/score를 직접 조회했고 runtime error 0. 이동 Black Hole 맵 기믹은 BallDefinition과 별도다. Runtime visual/collision 크기는 현재 Stage local level 계약을 따른다. |
| S2-G2 같은 레벨 후보 탐색 | Core | VERIFIED | 2026-08-11 중앙 SoA의 `global_levels`와 read-only `BallCatalog` instance API를 사용한다. Primary `godot` Main runtime에서 같은 Lv0 overlap 후보 `(0,1),(0,3),(1,3)`, 다른 Lv1 제외, 반복 query 동일, index 1 deactivate 뒤 `(0,3)`만 남음을 확인했고 validate 3/3 통과. 실제 Merge commit은 S2-G3 범위. |
| S2-G3 결정적 Merge commit | Core | VERIFIED | 2026-08-12 runtime 크기를 Stage local level 기준으로 정정했다. 각 Stage는 visual/collision 반지름 `4→8→16→32→64`를 사용하며 Ground Lv0 pair가 반지름 8의 Lv1 하나로 합쳐짐을 확인했다. 기존 mass-weighted velocity와 `maximum_ball_runtime_speed=900`, midpoint, 다음 tick 재합체, Lv14 top-ball signal 계약은 유지한다. 관련 script/scene validate 7/7 및 clean Main runtime error 0. |
| S2-G4 Score formatter | Content/Systems | VERIFIED | 2026-08-10 `format_score(value)` pure API로 0, K/M/B/T 경계, 반올림 승격, `1e36` 과학 표기와 NaN/Infinity 방어를 자동 검증. Godot 4.7.1 headless exit 0, Primary `godot` MCP validate 3/3. |
| S2-G5 Merge 표시 통합 | Presentation | VERIFIED | `ball_merged(result_level, world_position)` 1회당 read-only pixel debris/value FX 1회를 HUD 내부 EffectManager가 생성한다. Primary `godot` validate 7/7, Desktop Main runtime에서 Lv0 pair→Lv1 active ball 1개·FX 1개·score state 불변과 큰 값 format을 확인했다. 2026-08-12 MCP 종료 후 clean Web release export를 실제 in-app browser에서 로드해 1280×720 Canvas 활성/focus, Merge 진행에 따른 genealogy 공개, console warning/error 0을 확인했다. |
| S3-G1 Stage 데이터 | Content/Systems | VERIFIED | 2026-08-12 Stage resource와 content verification을 Stage당 5종 계약으로 재정렬했다: Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`. 세 Stage의 Time Bonus는 `[0,0.25,0.5,1,2]`, Galactic만 `black_hole_enabled=true`다. 최근 팀 검토로 Lv7 `Red Giant`와 Lv9 `Nebula`를 15종 catalog에는 보존하되 기본 Run에서 제외하는 배치가 의도된 계약임을 재확인했다. Primary `godot` validate로 schema/catalog/S3 test script/test scene/S2 regression/Main scene 6/6 valid, Main runtime에서 세 resource를 직접 조회했고 runtime error 0. 이 환경에는 CLI executable을 신뢰성 있게 찾을 수 없어 MCP headless validation을 baseline으로 기록한다. |
| S3-G2 Stage 진입·Cashout 점수/시간 | Core | VERIFIED | 2026-08-12 `StageRuntime.enter_stage()`가 stage score/time만 data-defined 값으로 초기화하고 run score는 보존한다. `apply_active_cashout(amount, global_level)`는 current Stage의 `local_ball_levels`에서 비연속 global ID를 조회해 Time Bonus를 한 번 반영한다. Godot 4.7.1 CLI headless scene exit 0, Primary `godot` validate 5/5, runtime 호출에서 Ground Lv2 `+0.5s`, Planetary Lv8(local Lv3) `+1.0s`, stage/run `25/35`, score/time signal 각 5회를 확인했고 Main runtime error 0. |
| S3-G3 Tick 종료 중재 | Core | VERIFIED | 2026-08-12 `StageRuntime.process_tick()`은 time decrement → pending Active Cashout 반영 → Top Ball 우선 → Time Up 순으로 한 번만 `end_decision_requested(reason)`를 보낸다. 같은 tick `0.03s - 0.1s + Lv3 1.0s`는 PLAYING 유지, Top Ball은 Time Up보다 우선, fresh Stage entry 전에는 후속 결정을 막는다. Simulation Cashout은 실제 BallDefinition base score와 global level을 전달하며 Lv3은 `1,000,000`/`3`을 runtime에서 확인했다. Godot 4.7.1 CLI headless regression scenes exit 0, Primary `godot` validate 6/6, Main runtime error 0. |
| S3-G4 Snapshot Settlement | Core | VERIFIED | 2026-08-12 `SettlementService.settle(snapshot)`은 snapshot의 `global_level`만 사용해 BallCatalog base score를 합산하고, cashout modifier·전달된 score는 무시한다. `settlement_applied`가 재호출과 signal 중복을 막고 stage reset에서만 풀린다. Godot 4.7.1 CLI headless S3-G4/G3/G2 exit 0, Primary `godot` validate 6/6, runtime에서 Lv0+Lv1+Lv4 = `100000101`, stage/run `100000111`, duplicate `0`, lifecycle signal 각 1회를 확인했고 Main runtime error 0. |
| S3-G5 Clear·Fail 상태 통합 | Integration | VERIFIED | 2026-08-12 `StageManager`가 Main simulation tick을 소유해 time decrement → simulation Merge/Cashout → StageRuntime arbitration을 순서대로 실행한다. Top Ball은 `CLEAR_LOCKED→SETTLING→CLEARED`, Time Up은 `TIME_UP_LOCKED→SETTLING→CLEARED/FAILED`로 한 번 전이하며 active snapshot을 Settlement 뒤 제거한다. Godot 4.7.1 CLI integration/S3/S1 regressions exit 0, Primary Main runtime에서 Ground PLAYING·time/score 누적, Retry reset, Top Ball settlement `100000000`/CLEARED, Time Up FAILED와 runtime error 0을 확인했다. |
| S3-G6 Stage HUD | Presentation | VERIFIED | 2026-08-12 Stage name/time/stage score/run score/clear target과 현재 Stage의 고정 5칸 세로 genealogy를 HUD에 연결했다. Stage entry는 base ball만 공개하고, `ball_merged(result_level, world_position)`의 새 local level만 한 번 공개한다. HUD는 score/time/state를 변경하지 않는다. Godot 4.7.1 CLI headless S3-G6/S1-G4 verification exit 0, Primary `godot` validate 5/5와 Main runtime에서 Ground readout·Snowflake/Snowball/Big Snowball reveal·runtime error 0을 확인했다. MCP 종료 뒤 clean Web release export를 In-app Browser에서 열어 Canvas, live HUD/genealogy, console warning/error 0을 확인했다. |
| S4-G1 Spatial Grid | Core | VERIFIED | 2026-08-12 global level별 Uniform Spatial Grid로 Merge 후보 탐색의 전수 O(N²) 경로를 교체했다. 반지름에 따라 조회 cell 범위를 확장해 radius 64 공의 다중-cell overlap도 검출하고, 최종 pair를 index 순으로 정렬해 기존 결정성을 유지한다. read-only metric은 `candidate_count/grid_cell_count`를 제공한다. Primary `godot` validate 7/7, Main runtime에서 기존 S2 후보 3개 동일·다른 level 제외·large-radius pair 검출·sparse 200공 candidate 0/cell 200을 확인했다. 1,000공 단일 query는 candidate check `2,760`/전수 pair `499,500`, `2,942µs`, runtime error 0. CLI headless는 기존 `user://logs` 실패 뒤 Godot signal 11 환경 문제로 Evidence에서 제외했다. |
| S4-G2 슬롯 재사용·할당 점검 | Core | VERIFIED | 2026-08-12 SoA free slot 우선 재사용을 256공 deactivate→respawn에서 capacity 256 유지로 확인했다. Spatial Grid는 level/cell bucket 배열을 pool로 유지하고 stable occupancy 반복 120회에서 `grid_new_buckets=0`·bucket capacity 불변을 확인했다. Merge pair, consumed flag, cashout, render snapshot buffer를 hot path에서 재사용하며 `simulation_metrics_updated(metrics)` read-only signal을 제공한다. Primary `godot` validate 10/10, Main runtime에서 active 300·per-ball child Node 0·기존 S2 후보/merge 동일·runtime error 0. Godot 4.7.1 native headless S4-G2/G1 및 S2-G2/G3·S1-G1/G3 회귀 6개 모두 exit 0. |
| S4-G3 Web release·1,000공 stretch 스트레스 | Core | VERIFIED | 2026-08-12 필수 Gate를 실제 Web 500개 최저 30 FPS 이상으로 재설정하고, 1,000개는 stretch/torture로 유지했다. 당시 clean Web 500 Merge OFF는 평균 `52.1`/최저 `38.6 FPS`, physics `2.18ms`, console warning/error 0으로 필수 Gate를 통과했다. S4-G4 구현 전 audit에서 기존 stress scene의 Merge ON 분기가 공을 생성하지 않는 문제가 발견돼, 기존 Merge ON stretch 수치는 현행 비교 근거로 사용하지 않는다. Merge ON을 실제 생성하도록 고친 최신 측정은 S4-G4 Evidence에 기록한다. |
| S4-G4 일반 Snowball MultiMesh renderer | Core | VERIFIED | 2026-08-12 일반 Lv0~13을 global-level별 reusable `MultiMeshInstance2D` batch로 전환했다. simulation snapshot은 `positions/radii/global_levels`만 read-only로 제공하며 runtime radius를 그대로 scale로 사용한다. Lv14 Black Hole은 special fallback을 유지하고 Item Ball/runtime Black Hole 구현은 범위 밖이다. Native headless 전용 test exit 0: level batch 분리, runtime transform/radius, reset 뒤 stale instance 없음, later-stage level 재사용 확인. S1-G1, S2-G2/G3, S4-G1/G2 회귀 5개 exit 0. Primary `godot` Main runtime에서 31 active/31 standard/fallback 0과 원형 표시, runtime error 0을 확인했다. MCP 종료 뒤 clean temporary Web release의 실제 browser stress에서 `100 OFF 60/60`, `500 OFF 60/60`, `500 Merge ON 60/60 (physics 1.44ms, merges 0.95/frame)`, `1000 OFF 60/60`, `1000 Merge ON 60/60 (physics 2.67ms, merges 1.97/frame)`를 확인했고 console warning/error 0이었다. 이는 현 개발 PC/in-app browser evidence이며 저사양 보장은 아니다. |
| S5-G1 Stage 콘텐츠 매핑 | Content/Systems | VERIFIED | 2026-08-12 기존 Resource가 최신 S5 계약과 이미 일치해 값은 변경하지 않고 독립 검증을 추가했다. Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`는 각 5종이며 이전 top이 다음 base다. spawn `6/15/35`, neutral `visual_radius_scale=1`, background `ground/planetary/galactic`가 Resource 데이터로 제공된다. Lv7·Lv9는 15종 BallCatalog에 존재하지만 기본 chain에서 비활성이고 Lv14는 `Black Hole`/`black_hole`이다. Godot 4.7.1 native headless verification exit 0, Primary `godot` validate 4/4와 Main runtime data query 성공, runtime error 0. |
| S5-G2 Stage re-baselining runtime | Core | VERIFIED | 2026-08-12 `apply_stage_definition(definition)`과 read-only stage snapshot을 StageRuntime/Simulation에 제공한다. 적용 시 simulation 배열과 Stage score/time/end lock을 초기화하고 run score는 보존한다. Merge 결과는 current ordered chain의 다음 ID를 사용해 Planetary `6→8→10`을 생성하며 top/out-of-chain 입력은 거부한다. Planetary base/spawn `4/15`, Galactic `10/35`, Lv10 local radius `64→4` 재기준화를 확인했다. Godot 4.7.1 native headless S5-G2 및 S2-G3/S3-G2~G4/S4-G1~G2 회귀 7개 exit 0. Primary Main runtime Ground base `0`, spawn `6`, radius `4`, PLAYING, runtime error 0. |
| S5-G3 Scale Shift 상태 통합 | Integration | VERIFIED | 2026-08-12 `StageManager`가 settlement 뒤 `CLEARED→SHIFTING`만 허용하고 `stage_shift_started(next_definition, shift_id)`를 발행한다. matching `shift_id`의 완료 API만 Planetary 진입을 허용하며 wrong/duplicate 완료는 무시한다. S5-G4 전 Main의 `auto_complete_shift_presentation` adapter가 deferred 한 번 같은 API를 호출한다. Godot 4.7.1 CLI project load exit 0, Primary validate StageManager/Main/S5-G3 test 4/4, S5-G3·S3-G5 integration scene은 각각 exit 0, Primary Main runtime에서 Ground top-ball→`SHIFTING`/active 0/pending id 1→Planetary `PLAYING`/pending -1과 runtime error 0을 확인했다. |
| S5-G4 Stage World·Shift presentation | Presentation | VERIFIED | 2026-08-14 v2 Paper-8 프레임과 Ground/Planetary/Galactic Stage World 3종을 연결했다. 배경은 `1600×900`, 승인 palette, opaque, 2×2 grid 검증 3/3 통과; Ground 48 snow, Planetary 28 twinkle, Galactic 44 twinkle overlay를 사용한다. 0.9s Shift에서 배경 crossfade와 중앙 베젤·200px 양쪽 wing·HUD/Pause가 함께 이동하고 completion ID를 한 번 반환한다. Godot 4.7.1 CLI Stage World/Shift, frame bounds, HUD/Pause 회귀와 Native OpenGL Ground/Shift 캡처가 통과했다. Cashout 방향 cue와 CRT emission/static은 향후 개선으로 문서화했다. |
| S5-G4I Shift presentation handoff wiring | Integration | VERIFIED | 2026-08-14 Main 임시 auto-complete adapter를 끄고 `stage_shift_started(next_definition, shift_id)`→Presentation→`stage_shift_presentation_finished(shift_id)`→StageManager accept를 연결했다. CLI에서 완료 전 Ground/SHIFTING 유지, 완료 뒤 Planetary/PLAYING 1회 진입, stale 완료 거부와 S5-G3 회귀를 확인했다. lock 해제. |
| S5-G5 3-Stage 통합 완주 | Integration | IMPLEMENTED | 2026-08-14 Main 연속 경로에서 Ground Top Ball→Planetary, Planetary Supernova 4회 Cashout(`+4.00s`)→Time Up Score Clear→Galactic, Stage score reset/run score preserve, 2회 Shift, Retry→Ground를 CLI로 확인했다. Stage 진입이 `Simulation.apply_stage_definition()`을 사용하도록 연결하고 HUD에 StageManager를 명시적으로 주입했다. Debug build 강제 검증은 `F6` Top Ball Clear, `F7` Time Up Score Clear다. Godot 4.7.1 CLI 회귀 6종과 Native OpenGL Main smoke exit 0, Web Debug/Release export 및 로컬 HTTP 주요 파일 200 통과. 실제 Browser 연결 목록이 비어 Canvas·F6/F7·console 확인을 수행하지 못했으므로 Q-S5 Web Gate는 `UNVERIFIED — browser tooling unavailable`; lock 해제. |
| S6-G1 이벤트 등급·FX budget | Presentation | PENDING | S5 완료 필요 |
| S6-G2 CUT-IN·화면 연출 | Presentation | PENDING | S6-G1/S5 상태 계약 필요 |
| S6-G3 Audio 콘텐츠 | Content/Systems | PENDING | S6-G1 event tier 필요 |
| S6-G4 사운드 계층·가독성 | Content/Systems | PENDING | S6-G1/G3 필요 |
| S7-G1 Item gateway 통합 | Integration | PENDING | S5 완료와 Core/Content API 필요; 선택 |
| S7-G2 Blizzard | Content/Systems | PENDING | S7-G1 필요; 선택 |
| S7-G3 Fire Core | Content/Systems | PENDING | S7-G1/S3 회귀 필요; 선택 |
| S7-G4 Magnet | Content/Systems | PENDING | S7-G1/S4 metric 필요; 선택 |
| S8-G1 Black Hole force | Core | PENDING | S5/S4 baseline 필요 |
| S8-G2 두 Black Hole 최종 충돌 runtime | Core | PENDING | S8-G1/S3 필요 |
| S8-G3 Title·Main·Terminal UI | Content/Systems | PENDING | S8-G2 terminal snapshot schema 필요 |
| S8-G4 Black Hole Finale·Retry 통합 | Integration | PENDING | S8-G2/G3와 모든 reset API 필요 |
| S8-G5 Black Hole Phase presentation | Presentation | PENDING | S5-G4 Frame/Field 계약과 S8-G1 phase signal 필요 |
| S9-G1 Release tuning·telemetry | Content/Systems | PENDING | S6/S8 완료; S7 선택 |
| S9-G2 Web export·browser QA | Content/Systems | PENDING | S9-G1과 통합 RC 필요 |
| S9-G3 Public link·submission | Content/Systems | PENDING | S9-G2와 hosting 필요 |

## 현재 다음 행동

- S0 Bootstrap의 세 Goal이 모두 `VERIFIED`됐다.
- S1-G1/G3/G4/G5는 기존 `VERIFIED`를 유지한다.
- S1-G2는 Mouse/Keyboard arbitration과 large-ball direct-sweep overlap 회귀까지 `VERIFIED`다.
- S1-G6은 최신 clean Web export의 사용자 Chrome 수동 검증까지 완료해 `VERIFIED`다. S1 Shared Skeleton이 닫혔다.
- S2-G1은 최신 catalog 계약에 맞춰 재정렬·재검증되어 `VERIFIED`다. Lv6 Sun/Lv7 Red Giant/Lv9 Nebula/Lv10 Galaxy와 Lv14 Black Hole Resource를 유지한다.
- S2-G2와 S2-G3의 동일 레벨 후보/결정적 commit 증거는 유지한다. `ball_merged(result_level, world_position)`는 2인자 계약이다. 비연속 Stage progression(`6→8→10`)은 S5-G2에서 현재 `StageDefinition.local_ball_levels` lookup으로 추가 검증한다.
- S2-G5는 clean Web release의 실제 브라우저 smoke까지 통과해 S2 전체가 `VERIFIED`다.
- S3-G1~G6은 최신 Stage data, runtime, settlement, Main flow와 HUD까지 모두 `VERIFIED`다.
- S4-G1~G4는 모두 `VERIFIED`다. S4-G4는 일반 Lv0~13의 level별 MultiMesh batch로 공별 `draw_circle` 경로를 대체했고, 최신 clean Web stress의 500/1,000 Merge ON도 실제 공 생성 상태에서 60/60 FPS를 기록했다. 기존 S4-G3의 Merge ON scenario는 audit에서 공 생성 누락이 확인되어 현행 성능 근거로 사용하지 않는다. 최신 수치는 현 개발 PC/browser 기준이며 HUD·Stage World·대표 FX 통합 뒤 저사양 Web telemetry를 다시 측정한다. S5-G1 dependency는 유지한다.
- S5-G1은 기존 Stage/Ball Resource mapping을 전용 검증으로 재확인해 `VERIFIED`다. 다음 순차 Core Goal은 S5-G2 Stage re-baselining runtime이며, Presentation S5-G4도 S5-G1 background key와 기존 Shift signal 계약을 바탕으로 작업 가능하다.
- S5-G2/G3/G4와 S5-G4I는 `VERIFIED`다. S5-G5 구현과 Desktop/CLI 연속 완주도 통과했으며, 실제 Browser에서 Debug `F6`→Planetary, `F7`→Galactic 화면·Canvas focus·console error를 확인하면 Q-S5 Web Gate를 닫고 S5-G5를 `VERIFIED`로 올릴 수 있다.
- S6의 audio asset·catalog·재생/priority/polyphony·Web 첫 입력 검증은 Content/Systems가 S6-G3과 S6-G4에서 함께 소유한다. Presentation은 S6-G1의 시각 FX event tier를 확정해 전달한다.
- 알려진 별도 문제: 기존 Web preset의 `export_filter="all_resources"`가 `build/` 산출물까지 다시 패킹한다. S1-G1 범위 밖이므로 수정하지 않음.
