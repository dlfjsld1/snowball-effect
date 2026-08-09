# S6 — Game Feel

원문: [`../../current/tasks/05_effects.md`](../../current/tasks/05_effects.md)

## 결과

공이 많아져도 조작과 중요한 이벤트가 읽히는 Retro Pixel Arcade × Cosmic Escalation 연출이 동작한다.

## Goals

### S6-G1 이벤트 등급과 FX budget

- Owner: Presentation
- Owned Files: `scripts/presentation/effect_manager.gd`, `scenes/effects/**`, `assets/particles/**`, `tests/presentation/**`
- Integration Point: Core Merge/Cashout/Clear event를 구독하고 등급별 표현만 결정.
- Dependencies: S5 완료와 event signature 안정화.
- Verification: 일반/고레벨/Clear 효과 등급 분리; burst에서 일반 FX throttle, 중요 이벤트 보존.
- Do Not Modify: event 발생 조건과 gameplay score/state.

### S6-G2 CUT-IN과 화면 연출

- Owner: Presentation
- Owned Files: `scripts/presentation/presentation_manager.gd`, `scripts/presentation/cutin_controller.gd`, `scenes/effects/**`, `tests/presentation/**`
- Integration Point: `presentation_pause_requested(duration)`와 `cutin_finished(event_id)`를 Integration에 제공.
- Dependencies: S6-G1과 S5-G3 상태 계약.
- Verification: 중요 Merge/Shift 연출 1초 미만, 중복/우선순위 정상, animation 완료가 gameplay 판정을 직접 실행하지 않음.
- Do Not Modify: GameManager/StageManager와 Merge logic.

### S6-G3 Audio 콘텐츠

- Owner: Content/Systems
- Owned Files: `assets/audio/**`, `resources/audio/**`, `tests/content/**`
- Integration Point: event tier별 audio key와 asset catalog를 Presentation에 제공.
- Dependencies: S6-G1 event tier 목록.
- Verification: 모든 필수 event key가 유효 asset을 가리키고 Web 지원 format으로 import 가능.
- Do Not Modify: AudioManager, gameplay event 조건, Web export 설정.

### S6-G4 사운드 계층과 가독성

- Owner: Presentation
- Owned Files: `scripts/presentation/audio_manager.gd`, `scripts/ui/hud.gd`, `tests/presentation/**`
- Integration Point: S6-G3 audio catalog와 첫 입력 활성화 요청을 소비.
- Dependencies: S6-G1 event tiers와 S6-G3.
- Verification: sound priority/polyphony 제한, late density에서 Paddle/공/HUD 가독성, Web 첫 입력 후 audio.
- Do Not Modify: Web export 설정과 gameplay event 조건.

## Exit Gate

Q-S6와 Web burst smoke 통과.
