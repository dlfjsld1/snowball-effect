# S6 — Game Feel

원문: [`../../current/tasks/05_effects.md`](../../current/tasks/05_effects.md)

## 결과

공이 많아져도 조작과 중요한 이벤트가 읽히는 Retro Pixel Arcade × Cosmic Escalation 연출이 동작한다.

## Goals

### S6-G1 이벤트 등급과 FX budget

- Owner: Content/Systems
- Owned Files: `scripts/presentation/effect_manager.gd`, `scenes/effects/**`, `assets/particles/**`, `tests/content/s6_g1_**`
- Integration Point: Core Merge/Cashout/Clear event를 구독하고 등급별 표현만 결정.
- Dependencies: S5 완료와 event signature 안정화.
- Verification: 일반/고레벨/Clear 효과 등급 분리; burst에서 일반 FX throttle, 중요 이벤트 보존.
- Do Not Modify: event 발생 조건과 gameplay score/state.

### S6-G2 FIRST CONTACT CUT-IN과 화면 연출

- Owner: Presentation
- Owned Files: `scripts/presentation/presentation_manager.gd`, `scripts/presentation/cutin_controller.gd`, `scenes/effects/**`, `tests/presentation/s6_g2_**`
- Integration Point: Integration이 pause lock을 수락한 뒤에만 `play_first_contact_cutin(payload: Dictionary) -> bool`를 호출한다. Presentation은 `first_contact_cutin_finished(event_id: int, run_epoch: int)`를 정확히 한 번 반환하고 `reset_first_contact_cutin(run_epoch: int)`로 stale visual/callback을 정리한다.
- Dependencies: S6-G1 `VERIFIED`; S3-G9와 S6-G2I가 실제 검증 Evidence와 함께 `VERIFIED`. 두 선행 Goal이 계약 문서만 가진 `PENDING` 상태에서는 controller·scene·Main wiring 구현을 시작하지 않는다.
- Verification: active roster는 Ground `Giant Snowball`·`Moon`, Planetary `Supernova`·`Galaxy`, Galactic `Event Horizon`·`Black Hole`의 정확히 6종; v1 payload의 `first_contact_id`로 공통 `1600×900` 배경 하나와 공별 투명 title/portrait 레이어 조립; normal `2.00초`, reduced-effects `1.80초`; Integration 호출 전 visible panel 없음; active/completed `(run_epoch, event_id)` 중복·stale 방어; matching 완료 signal 한 번; reset 즉시 hide/cancel; reduced-effects에서도 identity와 완료 semantics 유지; Core/Stage/gameplay 불변.
- Do Not Modify: GameManager/StageManager와 Merge logic.

#### Presentation producer 경계

- 입력은 S3-G9의 immutable-style `first_contact_discovered` payload v1을 S6-G2I가 검증·pause 수락한 뒤 전달한 값뿐이다. `ball_merged`, `top_ball_created`, `black_hole_phase_requested`를 직접 구독해 FIRST_CONTACT를 추론하지 않는다.
- `first_contact_id`는 [`../../design/mockups/drafts/s6-g2-cutin-d-components/README.md`](../../design/mockups/drafts/s6-g2-cutin-d-components/README.md)의 active roster 자산에 1:1 매핑한다. `Galaxy Cluster`와 `Quasar` draft는 입력으로 수락하지 않는다.
- 출력은 matching `first_contact_cutin_finished(event_id, run_epoch)`뿐이다. Presentation은 gameplay resume, timer/spawn/Paddle, Stage outcome, S8 Phase 또는 `phase_id`를 직접 변경·발급하지 않는다.
- Result/Failure/Main/Retry reset에서 Panel을 숨기는 것은 시각 cleanup이며 stale completion을 발행하지 않는다. Galactic은 Event Horizon과 첫 Black Hole만 허용하고, Black Hole도 다른 5종과 동일한 완료 signal까지만 책임진다.

### S6-G2I FIRST CONTACT CUT-IN pause·S8 handoff

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s6_g2i_**`
- Integration Point: S3-G9 `first_contact_discovered(payload)`를 받아 end-of-tick 중재 후 `play_first_contact_cutin(payload)`를 호출하고, Presentation의 `first_contact_cutin_finished(event_id, run_epoch)`를 `accept_first_contact_cutin_finished(event_id, run_epoch) -> bool`로 수락한다. Black Hole matching 완료만 기존 S8-G4 `begin_black_hole_phase(from_rect, to_rect) → black_hole_phase_started(phase_id, ...)`에 넘긴다.
- Dependencies: S3-G9 `VERIFIED`, S1-G6 gameplay pause/reset 경계, S8-G4의 기존 phase accept/resume API와 reset API. 실제 S6-G2 controller는 선행이 아니며 Integration fixture/stub로 독립 검증한다.
- Verification: current Run/`PLAYING`/schema/roster를 통과한 discovery만 end-of-tick에 수락; visible 호출 전에 timer/spawn/simulation/Paddle gameplay input lock; 같은 tick의 Merge/Cashout/종료 중재 보존; distinct event FIFO와 head-only finish; wrong/stale/duplicate event/epoch 거부; 일반 5종 완료 뒤에만 lock 해제·같은 PLAYING 재개; 첫 Black Hole은 CUT-IN 완료 전 phase id/`black_hole_phase_started` 0회, matching 완료 뒤 기존 S8 Phase 한 번, CUT-IN과 Phase 사이 gameplay 재개 없음; Retry/Main/fresh Run은 epoch 무효화·queue/lock/panel reset; `CLEAR_LOCKED/TIME_UP_LOCKED/FAILED/RUN_ENDED`·Result·Scale Shift에서는 새 CUT-IN 미표시; Galactic은 승인된 두 identity 외 거부.
- Do Not Modify: S3-G9 discovery 계산, Presentation animation/assets, S8 force/absorption/finale와 `phase_id` 수락 규칙, score/Settlement/Clear 판정.

S6-G2I는 기존 `S8-G4 VERIFIED` 증거를 폐기하지 않는다. 그 증거는 `black_hole_phase_started` 이후의 L2→L3 presentation·matching `phase_id`·finale/Retry 경로를 증명한다. FIRST_CONTACT 완료 **이전**에 Phase를 시작하지 않는 upstream gate는 S6-G2I의 새 Evidence로만 닫는다.

### S6-G3 Audio 콘텐츠

- Owner: Content/Systems
- Owned Files: `assets/audio/**`, `resources/audio/**`, `tests/content/**`
- Integration Point: S6-G1이 확정한 event tier를 받아 audio key·asset catalog·재생 정책의 단일 source of truth를 제공.
- Dependencies: S6-G1 event tier 목록.
- Verification: 모든 필수 event key가 유효 asset을 가리키고 Web 지원 format으로 import 가능.
- Do Not Modify: gameplay event 조건, Web export 설정.

### S6-G4 사운드 계층과 가독성

- Owner: Content/Systems
- Owned Files: `scripts/presentation/audio_manager.gd`, `assets/audio/**`, `resources/audio/**`, `tests/content/**`
- Integration Point: S6-G3 audio catalog와 기존 Core/Integration의 read-only gameplay event를 소비. `scripts/ui/hud.gd` 변경이 필요하면 Presentation에 별도 요청.
- Dependencies: S6-G1 event tiers와 S6-G3.
- Verification: sound priority/polyphony 제한, late density에서 Paddle/공/HUD 가독성, Web 첫 입력 후 audio.
- Do Not Modify: Web export 설정, gameplay event 조건, HUD 구현.

### S6-G5 BGM 상태 전환

- Owner: Content/Systems/Release
- Owned Files: `scripts/presentation/audio_manager.gd`, `assets/audio/**`, `resources/audio/**`, `tests/content/**`
- Integration Point: 기존 read-only `stage_changed`, Content screen request, Black Hole phase/finale 및 terminal snapshot을 소비한다. 새 gameplay signal이나 Integration-owned 파일 변경이 필요하면 별도 요청한다.
- Dependencies: S6-G3 audio catalog, S6-G4 Web first-input audio 계약, S8-G4 terminal wiring.
- Verification: `bgm_title`, `bgm_ground`, `bgm_planetary`, `bgm_galactic`, `bgm_pause`, `bgm_result`의 유효 asset/catalog 등록; Stage 전환 단일 BGM; Pause에서 Stage BGM 위치 저장·`bgm_pause` 교체·Resume 위치 재개; Black Hole Phase에서 `bgm_galactic` 정지 후 `black_hole_loop` 단독 재생; Final Result에서 loop 정리 후 `bgm_result`; Retry/Main Menu/terminal cleanup; Desktop과 실제 Web 첫 입력 unlock·console 확인.
- Do Not Modify: gameplay event 조건, 점수·시간·Stage state, `project.godot`, Main scene.

### S6-G6 Minimal Final Settlement presentation

- Owner: Presentation
- Owned Files: `scripts/presentation/effect_manager.gd`, `scripts/presentation/final_settlement_effect.gd`, `scripts/ui/hud.gd`, `scenes/effects/final_settlement_effect.tscn`, `tests/presentation/s6_g6_**`
- Integration Point: 기존 `final_settlement_started(amount)`와 simulation `get_render_snapshot()`을 read-only로 소비하고 `final_settlement_presentation_finished()`를 한 번 제공한다.
- Dependencies: S3-G4, S6-G1.
- Verification: 단일 draw node가 최대 64개 visual sample로 active snapshot을 `0.5s` 안에 pixel dissolve·Stage Score 방향 stream으로 표현; HUD Stage Score count-up; 완료 signal exactly once; score/state/simulation 불변.
- Do Not Modify: Settlement 계산, Clear/Failure 판정, `StageManager`, Main scene, Scale Shift.

### S6-G6I Final Settlement handoff wiring

- Owner: Integration
- Owned Files: `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s6_g6i_**`
- Integration Point: S6-G6의 완료 signal을 기다린 뒤 기존 Clear/Failure 판정과 Shift를 이어간다.
- Dependencies: S6-G6, 활성 S8-G4 Integration lock 해제.
- Verification: `TIME_UP_LOCKED → SETTLING`에서 presentation 완료 전 상태·Shift가 진행되지 않고, matching 완료 뒤 기존 score 판정이 exactly once 실행됨.
- Do Not Modify: Settlement 점수 계산, Presentation 내부 모션, Black Hole terminal flow.

### S6-G6J Final Settlement UI reveal handoff

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s6_g6j_final_settlement_ui_reveal_**`
- Integration Point: `StageManager.final_settlement_started(amount)`, `stage_clear_ready(clear_snapshot, clear_id)`, `stage_run_ended(result_snapshot)`와 Presentation `EffectManager.final_settlement_presentation_finished()`를 read-only로 중재한다.
- Dependencies: S6-G6 Presentation producer와 S5-G6I Clear/Next Stage wiring.
- Verification: authoritative Settlement와 `CLEARED`/`FAILED` state는 즉시 확정하되, active Settlement visual과 pending terminal/clear outcome이 모두 준비되기 전에는 Stage Clear Panel 또는 Result Panel을 열지 않는다. matching finish 뒤 Ground/Planetary Clear는 copied snapshot과 `clear_id`로 Panel을 한 번 열고, Time Up failure는 Result를 한 번 연다. Retry/Main/fresh Run은 pending reveal과 stale completion을 버리며, gameplay score/state·Clear 판정·Stage Shift·Black Hole finale을 변경하지 않는다. Desktop과 Web에서 0.5초 수렴/count-up이 실제로 보인 뒤 UI가 열린다.
- Do Not Modify: Settlement 계산과 Stage state transition, EffectManager dissolve/count-up 구현, S5-G6 Panel의 request-once semantics, Black Hole finale UI handoff.

## Exit Gate

Q-S6와 Web burst smoke 통과.
