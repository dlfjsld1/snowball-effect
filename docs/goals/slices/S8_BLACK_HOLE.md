# S8 — Black Hole and Final Result

원문: [`../../current/tasks/07_black_hole.md`](../../current/tasks/07_black_hole.md)

## 결과

마지막 Galactic Stage에서 첫 Lv14를 이동 Black Hole 기믹으로 전환하고 L3 Frame/Play Field로 확장한다. 두 번째 Black Hole과 충돌하면 최종 회전·폭발·타이틀 연출로 Run을 끝내고 완전한 Retry에 도달한다.

## Goals

### S8-G1 Black Hole force

- Owner: Core
- Owned Files: `scripts/simulation/ball_simulation_manager.gd`, `scripts/core/stage_runtime.gd`, `tests/simulation/**`
- Integration Point: 첫 Lv14 생성에서 첫 Black Hole entity/readiness와 position snapshot을 read-only 제공한다. S6-G2I matching CUT-IN 완료 뒤 Integration이 기존 `begin_black_hole_phase(from_rect, to_rect)`를 호출할 때만 StageRuntime의 `black_hole_phase_started(phase_id, from_rect, to_rect)` downstream이 열린다.
- Dependencies: S5 완료와 S4 performance baseline.
- Verification: 첫 Lv14가 일반 Clear 없이 Black Hole runtime entity로 한 번 전환; 모든 일반 Snowball 흡수와 Cashout 가치 `12.5%`/phase-entry Run Score `25%` 상한 패널티, 단일 흡수 즉사 방지와 반복 손실의 run score 0 즉시 Game Over, 다중 source vector 합산·1500 total cap, Black Hole 상호 450 척력, 하단 반사·Paddle continuous reflection·Cashout 제외, 비성장·Merge 제외, NaN·폭주 없음, 1,000공 성능 회귀 기록; 별도 Stage나 새 BallDefinition을 생성하지 않음.
- Do Not Modify: Black Hole visual과 Stage resource 값.

### S8-G2 두 Black Hole 최종 충돌 runtime

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/core/settlement_service.gd`, `tests/core/**`
- Integration Point: 두 Black Hole 접촉에서 terminal lock과 read-only finale/result snapshot을 Integration에 제공.
- Dependencies: S8-G1과 S3 Settlement 계약.
- Verification: 첫 Lv14는 종료하지 않고 두 번째 Lv14까지 gameplay 지속; 두 Black Hole의 earliest contact가 일반 Merge보다 우선; terminal event 한 번; 추가 Stage Shift 없음.
- Do Not Modify: Result UI, GameManager/StageManager.

### S8-G3 Title·Main·Terminal UI

- Owner: Content/Systems
- Owned Files: `scripts/ui/title_screen.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/result_panel.gd`, `scenes/ui/title_screen.tscn`, `scenes/ui/pause_menu.tscn`, `scenes/ui/result_panel.tscn`, `tests/content/**`
- Integration Point: `start_requested`, `retry_requested`, `resume_requested`, `settings_requested`, `main_menu_requested`; read-only terminal/result snapshot 표시 API.
- Dependencies: S8-G2 terminal snapshot schema와 S0-G2 UI mount 계약.
- Verification: finale에서 gameplay HUD/UI가 사라지고 `SNOWBALL EFFECT` 타이틀, `CLEAR SCORE` 최종 run score, Run 누적 `TOTAL MERGES`, `RUN TIME`, 실제 `RETRY RUN`·`MAIN` 버튼 표시; Result 전체가 아래에서 위로 진입하고 좌우 실험관 기포와 독립 최대치 게이지 motion이 동작; 통계 값이 없는 fixture에서는 통계 영역을 숨김; Start/Retry/Pause modal 행동 요청 한 번; Pause modal에 재개·다시 시작·설정·메인 화면이 표시됨; UI가 runtime state를 직접 초기화하지 않음.
- Do Not Modify: GameManager, StageManager, Core result 계산.

### S8-G4 Black Hole Finale와 Retry 통합

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/**`
- Integration Point: Core result snapshot, Content UI의 `retry_requested/main_menu_requested`, 모든 Owner의 reset API 연결.
- Skeleton Start Dependencies: S8-G2의 terminal/result snapshot과 S8-G1의 Black Hole Phase 공개 signal.
- Final Verification Dependencies: S8-G3, S8-G5, Content·Presentation·Item reset API.
- Integration Skeleton: S8-G2 완료 뒤 Integration-owned 파일에서 즉시 시작할 수 있다. Phase 시작을 전달하고 matching `phase_id` 완료만 수락하는 API, terminal snapshot 전달 지점, `retry_requested/main_menu_requested` handler, Core-owned reset 연결을 먼저 제공한다. 실제 Presentation 완료 producer가 없을 때는 같은 완료 API를 deferred 한 번 호출하는 임시 adapter를 둘 수 있다.
- Parallel Handoff: 임시 adapter는 Presentation/Content-owned 파일을 수정하거나 그 연출·UI 동작을 흉내 내지 않는다. S8-G5는 `black_hole_phase_started(...)`를 구독해 동일한 완료 API를 호출하고, S8-G3는 read-only result snapshot을 표시한 뒤 기존 request signal을 발행한다. 실제 producer가 Main에 연결되면 Integration이 해당 임시 adapter를 제거한다.
- Skeleton Verification: matching/stale/duplicate `phase_id` 중재, terminal lock 뒤 gameplay commit·추가 Shift 차단, result snapshot 1회 전달, Core reset과 handler 중복 호출 방지를 Integration test로 확인한다. 이 증거만으로 S8-G4를 `IMPLEMENTED` 또는 `VERIFIED`로 닫지 않는다.
- Final Verification: 실제 S8-G3/G5 산출물을 Main에 연결한 뒤 matching `phase_id`에서 Presentation Frame과 같은 L2 `880`→L3 `1040` logical Rect 활성화 후 같은 Galactic gameplay 재개; 두 Black Hole 접촉 뒤 finale→타이틀→Run End에서 추가 Shift 없음; Retry가 배열·점수·타이머·settlement/shift/phase/Black Hole/item/presentation lock 완전 초기화; Main 이동은 Run state를 안전하게 종료하고 Title/Main 화면으로 돌아감.
- Do Not Modify: Result UI 내부와 각 Owner reset 내부.

#### S6-G2I upstream gate와 기존 S8-G4 API

S8-G4의 기존 `begin_black_hole_phase(from_rect, to_rect) → black_hole_phase_started(phase_id, from_rect, to_rect) → black_hole_phase_presentation_finished(phase_id)` 경로는 FIRST_CONTACT 이후의 authoritative downstream API로 유지한다. S6-G2I는 첫 Black Hole discovery와 이 API 사이에 pause/CUT-IN gate만 추가한다. 따라서 `phase_id`는 matching `(run_epoch, event_id)` CUT-IN 완료 전에는 발급하지 않으며, 완료 수락 뒤부터는 기존 S8-G4의 matching/stale/duplicate 방어와 reset 계약을 그대로 사용한다. 과거 S8-G4 검증은 이 downstream을 증명하지만 새 upstream gate의 구현 증거는 아니다.

### S8-G5 Black Hole Phase presentation

- Owner: Presentation
- Owned Files: `scripts/presentation/background_manager.gd`, `scripts/presentation/presentation_manager.gd`, `scenes/backgrounds/**`, `scenes/effects/**`, `scripts/ui/hud.gd`, `tests/presentation/**`
- Integration Point: `black_hole_phase_started(phase_id, from_rect, to_rect)`를 구독하고 `black_hole_phase_presentation_finished(phase_id)`를 정확히 한 번 반환.
- Dependencies: S5-G4의 Frame/Field 이동 계약과 S8-G1의 phase/position snapshot.
- Verification: L2 `880`에서 L3 `1040`으로 Frame·표시 Play Field·고정 폭 HUD housing이 함께 좌우 대칭 확장; `Galactic` Stage 표시는 유지; 전환 완료 뒤 gameplay Black Hole과 HUD가 활성 상태로 남음; 두 Black Hole 접촉 시 mutual orbit·폭발 뒤 HUD/UI 제거와 타이틀·Clear Score·Retry Run·Main 표시; reduced-effects에서도 상태명·경계 이동·finale가 읽힘; duplicate/stale `phase_id`는 완료로 재사용되지 않음.
- Do Not Modify: StageManager, logical bounds, force 계산, Stage/ball resource 값.

### S8-G6 Black Hole max-two·overflow commit

- Owner: Core
- Owned Files: `scripts/simulation/ball_simulation_manager.gd`, `tests/simulation/s8_g6_**`
- Integration Point: 기존 `get_black_hole_snapshot()`/`get_black_hole_count()`, `ball_merged`, FIRST CONTACT, `black_hole_phase_requested`, `black_hole_finale_started` 계약을 유지한다. capacity와 overflow 판정은 Core 내부 source of truth이며 Presentation/Integration이 재계산하지 않는다.
- Dependencies: S2-G2/G3 deterministic Merge·non-Merge contact, S3-G3 `valid_play_delta`, S8-G1/G2 Black Hole entity·terminal 계약.
- Deliverables / Scope: 이동 Black Hole 최대 수를 `2`로 강제; stable merge-candidate commit 순서에서 남은 slot을 accepted plan까지 포함해 예약; `1 existing + 2 Lv13 pairs`의 첫 pair만 #2로, `0 existing + 3 pairs`의 앞 두 pair만 #1/#2로 commit; capacity가 없는 pair는 source 두 Lv13을 consume/deactivate하지 않고 mass/current velocity 기반 non-Merge contact·분리로 전달; first entity만 FIRST CONTACT/Phase readiness를 한 번 발행; normal/generic Lv14 spawn과 그 Cashout·인력·흡수 경로 차단.
- Exclusions: Black Hole force `480/1200/1500`, mutual repulsion `450`, 흡수 패널티, finale contact semantics, Presentation cue/asset, Stage/Ball Resource, GameManager/StageManager/Main wiring 변경.
- Verification: focused Core fixture에서 `0 existing + 3 pairs`, `1 existing + 2 pairs`, `2 existing + 1 pair`를 반복 실행해 같은 candidate order·entity 수 `2`·보존된 source Lv13 수/level·물리 분리·event exact count를 확인; overflow pair에 `ball_merged`/Lv14 discovery/score/entity event 0회; normal render snapshot·Cashout·absorption 입력에 Lv14 0개; slot 승인 전 source inactive 0개; 기존 S2-G3/S3-G3/S8-G1/G2 회귀 통과.
- Evidence Expectations: Godot CLI/headless focused fixture와 관련 Core/Simulation 회귀의 명령·exit code·machine-readable marker; 반복 run의 동일 candidate/result order; overflow 전후 active levels/positions/velocities와 signal count. 문서나 코드 정적 검사만으로 완료 처리하지 않는다.
- Lock Notes: Core-owned 범위만 사용하므로 Integration lock 없음. 이 Goal이 `PENDING`인 동안 어떤 파일도 잠그지 않는다.

### S8-G7 Black Hole cue cleanup·Void Cathedral consistency

- Owner: Presentation
- Owned Files: `scripts/presentation/black_hole_phase_effect.gd`, `scripts/presentation/ball_texture_lod_catalog.gd`, `scenes/effects/**`, `tests/presentation/s8_g7_**`
- Integration Point: Core의 read-only `get_black_hole_snapshot()` position/radius와 프레임 간 이동 방향만 소비한다. 기존 S8-G5 phase/finale completion API를 유지하며 gameplay force·absorption·collision 값을 Presentation에서 추론하지 않는다. player-visible 방어 surface는 승인된 `Void Cathedral C`를 제공하고, Core-owned generic fallback을 직접 수정하지 않는다.
- Dependencies: S8-G5 Presentation lifecycle과 reset 계약, 승인된 `Void Cathedral C` runtime resource. S8-G6은 구현 시작 선행이 아니지만 third+ Lv14 unreachable 최종 수락은 S8-G8에서 함께 검증한다.
- Deliverables / Scope: `300-unit` 대형 dashed influence ring과 orbiting square-dot reticle 제거; persistent cue를 최대 두 개의 close-range lensing arc와 짧은 moving-direction light trail로 정리; `Void Cathedral C`의 gold/Galactic-violet palette 유지; normal/reduced-effects와 한 개/두 개 Black Hole snapshot 지원; dependency transition 중 노출 가능한 Presentation fallback도 `Void Cathedral C` 사용. arc/trail은 procedural이라 새 bitmap을 만들지 않는다.
- Exclusions: Core force/absorption/collision/Phase radius, gameplay footprint, finale orbit·폭발 timing, Stage/ball data, 새 bitmap asset, Main/StageManager/GameManager wiring 변경. cue 길이/반경을 gameplay 범위로 표기하지 않는다.
- Verification: actual-size Native capture에서 300-unit 점선 ring과 공전 사각 점 0개, Black Hole마다 근거리 arc 최대 2개와 짧은 비공전 trail만 표시; trail이 최근 이동 반대 방향을 따름; normal/reduced-effects 모두 `Void Cathedral C` 본체와 gold/violet hierarchy 유지; 한 개/두 개 entity, reset, duplicate/stale phase/finale 회귀; player-visible generic circle/global14 fallback 0개; Core snapshot 불변.
- Evidence Expectations: Godot CLI/headless Presentation fixture, normal/reduced actual-size Native captures, visual metrics/static draw-path assertion, resource path/hash 또는 동일성 근거, frame sample과 runtime error. 새 bitmap 산출물이 없음을 파일 diff로 확인한다.
- Lock Notes: Presentation-owned 범위만 사용하므로 Integration lock 없음. Core-owned `scripts/simulation/ball_renderer.gd`가 player-visible한 dependency fallback으로 남는다면 S8-G8 활성 전 Core handoff를 요청하며 직접 수정하지 않는다.

### S8-G8 Black Hole max-two·cue Main acceptance

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s8_g8_**`
- Integration Point: S8-G6의 authoritative max-two/overflow 결과와 S8-G7의 Presentation surface를 실제 Main에 연결한다. 기존 FIRST CONTACT→Phase, `black_hole_finale_locked`→finale→Result, Retry/Main reset API를 재사용하며 capacity나 cue 의미를 Integration에서 재구현하지 않는다.
- Dependencies: S8-G6와 S8-G7의 실제 구현·독립 Evidence, 기존 S8-G3/G4/G5 Result·phase/finale·reset 계약.
- Deliverables / Scope: actual Main에서 최대 두 moving entity만 mount/render; same-tick overflow source Lv13 pair 보존과 non-Merge separation 관찰; first entity의 FIRST CONTACT/Phase exact-once와 second entity의 no-repeat; 두 Black Hole contact의 finale/Result exact-once; active overlay가 generic circle fallback을 노출하지 않도록 연결; Retry Run/Main/fresh Run에서 entity, reserved slot, pending discovery/phase/finale, Presentation trail/snapshot을 함께 초기화.
- Exclusions: S8-G6 Core 알고리즘 재작성, S8-G7 cue drawing 재작성, force/흡수/점수 tuning, 새 Stage/normal Lv14 behavior, 새 bitmap, Result UI redesign.
- Verification: actual Main fixture에서 `0 existing + 3 pairs`와 `1 existing + 2 pairs`를 한 valid gameplay tick에 주입해 entity `2`, overflow source Lv13 pair `2`, generic Lv14 `0`, extra discovery/Cashout/absorption `0`을 확인; 보존 pair가 물리적으로 분리; 두 entity contact 후 terminal snapshot/finale/Result 1회; Retry는 fresh Ground/Black Hole `0` 뒤 다음 Run의 #1 FIRST CONTACT를 새 epoch로 허용하고 Main은 Title로 안전 복귀; moving gameplay와 Result 사이에 misleading ring/square cue 0개.
- Evidence Expectations: Godot CLI/headless Integration fixture와 S8/S3 회귀, 실제 Desktop 전체 경로, fresh Web export→local HTTP→Browser Canvas 입력·finale·Result·Retry/Main, console warning/error, actual-size capture. Desktop/Web 모두 없으면 `VERIFIED`로 올리지 않는다.
- Lock Notes: `PENDING` 동안 Integration lock은 `없음/released`다. `IN PROGRESS`로 전환할 때만 `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s8_g8_**`를 `STATUS.md`에 잠그고 완료 뒤 해제한다.

## Exit Gate

Q-S8, Integration Gate, 전체 Run Desktop/Web 완주.
