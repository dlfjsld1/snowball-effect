# Goal Status

상태와 검증 Evidence의 유일한 기록 장소다. `VERIFIED`는 실제 실행 결과가 있을 때만 사용한다. 역할과 lane은 초기안이며 변경 시 [`../team/`](../team/) 문서와 함께 갱신한다.

## Active lanes

| Lane | Active Goal | Owner | 상태 |
|---|---|---|---|
| Core | 없음 | 팀 리드/Core 담당 | available |
| Presentation | 없음 | 팀원 A | available |
| Content/Systems | 없음 | 본인/Content·Systems·Release 담당 | available |
| Integration | 없음 | 팀 리드/Integration 담당 | available |

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
| S2-G1 공·점수 데이터 | Content/Systems | VERIFIED | 2026-08-12 catalog resource와 content verification을 최신 계약으로 재정렬했다: Lv6 Sun, Lv7 Red Giant, Lv9 Nebula, Lv10 Galaxy, Lv14 `Black Hole`/`black_hole`. 15종의 score/radius/mass/fx tier와 Time Bonus 부재를 유지했다. Primary `godot` validate로 definition/catalog/test script/test scene 4/4 valid, Main runtime에서 15개 전부의 name/key/score를 직접 조회했고 runtime error 0. 이 환경에는 CLI executable을 신뢰성 있게 찾을 수 없어 MCP headless validation을 baseline으로 기록한다. 이동 Black Hole 맵 기믹은 BallDefinition과 별도다. |
| S2-G2 같은 레벨 후보 탐색 | Core | VERIFIED | 2026-08-11 중앙 SoA의 `global_levels`와 read-only `BallCatalog` instance API를 사용한다. Primary `godot` Main runtime에서 같은 Lv0 overlap 후보 `(0,1),(0,3),(1,3)`, 다른 Lv1 제외, 반복 query 동일, index 1 deactivate 뒤 `(0,3)`만 남음을 확인했고 validate 3/3 통과. 실제 Merge commit은 S2-G3 범위. |
| S2-G3 결정적 Merge commit | Core | VERIFIED | 2026-08-11 mass-weighted velocity를 `maximum_ball_runtime_speed=900`으로 한 번 제한한다. Primary `godot` Main runtime에서 Lv0 pair가 midpoint Lv1 하나로 합쳐지고 velocity `(50,50)`을 계승, 같은 tick의 Lv1 재합체는 없고 다음 commit에서만 발생, 2000 world units/s pair는 900으로 제한, Lv13 pair의 Lv14 생성은 `top_ball_created(14)` 1회를 확인했다. simulation/S2-G3/S2-G2/S1-G3/S1-G1 validate 5/5 통과 및 runtime error 0. |
| S2-G4 Score formatter | Content/Systems | VERIFIED | 2026-08-10 `format_score(value)` pure API로 0, K/M/B/T 경계, 반올림 승격, `1e36` 과학 표기와 NaN/Infinity 방어를 자동 검증. Godot 4.7.1 headless exit 0, Primary `godot` MCP validate 3/3. |
| S2-G5 Merge 표시 통합 | Presentation | PENDING | S2-G3/G4 계약 필요 |
| S3-G1 Stage 데이터 | Content/Systems | VERIFIED | 2026-08-12 Stage resource와 content verification을 Stage당 5종 계약으로 재정렬했다: Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`. 세 Stage의 Time Bonus는 `[0,0.25,0.5,1,2]`, Galactic만 `black_hole_enabled=true`다. 최근 팀 검토로 Lv7 `Red Giant`와 Lv9 `Nebula`를 15종 catalog에는 보존하되 기본 Run에서 제외하는 배치가 의도된 계약임을 재확인했다. Primary `godot` validate로 schema/catalog/S3 test script/test scene/S2 regression/Main scene 6/6 valid, Main runtime에서 세 resource를 직접 조회했고 runtime error 0. 이 환경에는 CLI executable을 신뢰성 있게 찾을 수 없어 MCP headless validation을 baseline으로 기록한다. |
| S3-G2 Stage 진입·Cashout 점수/시간 | Core | VERIFIED | 2026-08-12 `StageRuntime.enter_stage()`가 stage score/time만 data-defined 값으로 초기화하고 run score는 보존한다. `apply_active_cashout(amount, global_level)`는 current Stage의 `local_ball_levels`에서 비연속 global ID를 조회해 Time Bonus를 한 번 반영한다. Godot 4.7.1 CLI headless scene exit 0, Primary `godot` validate 5/5, runtime 호출에서 Ground Lv2 `+0.5s`, Planetary Lv8(local Lv3) `+1.0s`, stage/run `25/35`, score/time signal 각 5회를 확인했고 Main runtime error 0. |
| S3-G3 Tick 종료 중재 | Core | PENDING | S3-G2/S2-G3 필요 |
| S3-G4 Snapshot Settlement | Core | PENDING | S3-G3 필요 |
| S3-G5 Clear·Fail 상태 통합 | Integration | PENDING | S3-G2~G4/G6 계약 필요 |
| S3-G6 Stage HUD | Presentation | PENDING | S3-G1/G2 signal 필요 |
| S4-G1 Spatial Grid | Core | PENDING | S2 완료 필요 |
| S4-G2 슬롯 재사용·할당 점검 | Core | PENDING | S4-G1 필요 |
| S4-G3 1,000공 스트레스 | Core | PENDING | S4-G2와 release 측정 계약 필요 |
| S5-G1 Stage 콘텐츠 매핑 | Content/Systems | PENDING | S3-G1/S4 완료 필요 |
| S5-G2 Stage re-baselining runtime | Core | PENDING | S5-G1/S3 계약 필요 |
| S5-G3 Scale Shift 상태 통합 | Integration | PENDING | S5-G1/G2/G4 계약 필요 |
| S5-G4 Stage World·Shift presentation | Presentation | PENDING | S5-G1/G3 signal 필요 |
| S5-G5 3-Stage 통합 완주 | Integration | PENDING | S5-G1~G4 `VERIFIED` 필요 |
| S6-G1 이벤트 등급·FX budget | Presentation | PENDING | S5 완료 필요 |
| S6-G2 CUT-IN·화면 연출 | Presentation | PENDING | S6-G1/S5 상태 계약 필요 |
| S6-G3 Audio 콘텐츠 | Content/Systems | PENDING | S6-G1 event tier 필요 |
| S6-G4 사운드 계층·가독성 | Presentation | PENDING | S6-G1/G3 필요 |
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
- S3-G1은 최신 5종·비연속 Stage chain으로 재정렬·재검증되어 `VERIFIED`다. Lv7 Red Giant와 Lv9 Nebula는 catalog에는 남지만, 팀 합의에 따라 기본 Run에는 의도적으로 포함하지 않는다. S3-G2도 Stage data 소비·점수/time source-of-truth까지 `VERIFIED`다. S3-G3은 tick 종료 중재를 이어서 구현할 수 있다.
- 다음 가능한 Presentation Goal은 S2-G5이며, S3-G6에는 Stage 이름과 세로 5칸 progressive genealogy가 추가됐다. Black Hole Phase 전용 Presentation은 S8-G5에서 수행한다.
- 알려진 별도 문제: 기존 Web preset의 `export_filter="all_resources"`가 `build/` 산출물까지 다시 패킹한다. S1-G1 범위 밖이므로 수정하지 않음.
