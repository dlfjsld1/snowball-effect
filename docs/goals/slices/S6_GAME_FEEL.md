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

### S6-G2 CUT-IN과 화면 연출

- Owner: Presentation
- Owned Files: `scripts/presentation/presentation_manager.gd`, `scripts/presentation/cutin_controller.gd`, `scenes/effects/**`, `tests/presentation/**`
- Integration Point: `presentation_pause_requested(duration)`와 `cutin_finished(event_id)`를 Integration에 제공.
- Dependencies: S6-G1, S3-G7과 S5-G3 상태 계약.
- Verification: Ground `Giant Snowball`·`Moon`, Planetary `Supernova`·`Galaxy`, Galactic `Event Horizon`·`Black Hole`의 Run 내 최초 생성 CUT-IN 6종; 공통 배경 하나와 공별 문구·공 레이어 조립; 기본 1초 미만; 같은 공 반복 생성 억제; Moon/Galaxy 뒤 PLAYING 복귀, 첫 Black Hole 뒤 Phase handoff; animation 완료가 gameplay 판정을 직접 실행하지 않음.
- Do Not Modify: GameManager/StageManager와 Merge logic.

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

## Exit Gate

Q-S6와 Web burst smoke 통과.
