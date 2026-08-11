# S5 — Scale Shift

원문: [`../../current/tasks/04_stage_shift.md`](../../current/tasks/04_stage_shift.md)

## 결과

Ground, Planetary, Galactic을 연속 플레이하며 이전 최고 공이 다음 기본 공이 된다.

## Goals

### S5-G1 Stage 콘텐츠 매핑

- Owner: Content/Systems
- Owned Files: `resources/stages/**`, `resources/balls/**`, `tests/content/**`
- Integration Point: StageCatalog가 local Lv0~Lv3와 global ball 범위, spawn rate, background key를 제공.
- Dependencies: S3-G1과 S4 완료.
- Verification: Ground/Planetary/Galactic의 level 범위가 연속이며 이전 top이 다음 base와 동일; 값은 runtime 공식이 아닌 데이터.
- Do Not Modify: Stage runtime, StageManager, background scene.

### S5-G2 Stage re-baselining runtime

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/simulation/ball_simulation_manager.gd`, `tests/core/**`
- Integration Point: `apply_stage_definition(definition)`과 stage snapshot을 Integration에 제공.
- Dependencies: S5-G1 data와 S3 계약.
- Verification: base global level과 spawn rate 전환, 새 Stage에 이전 배열/시간/점수 잠금이 누출되지 않음.
- Do Not Modify: StageManager, resource 값, Stage World.

### S5-G3 Scale Shift 상태 통합

- Owner: Integration
- Owned Files: `scripts/core/stage_manager.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`
- Integration Point: Core `CLEARED`, Presentation `stage_shift_presentation_finished`, Content StageCatalog를 연결.
- Dependencies: S5-G1, S5-G2와 `INTEGRATION_CONTRACTS.md`의 Shift signal 계약.
- Verification: `CLEARED` 뒤에만 `SHIFTING`; spawn/timer stop→Settlement→연출→다음 Stage; 중복 signal에도 Shift 한 번.
- Do Not Modify: Core 계산, StageDefinition 값, Presentation animation.

### S5-G4 Stage World와 Shift presentation

- Owner: Presentation
- Owned Files: `scripts/presentation/background_manager.gd`, `scripts/presentation/presentation_manager.gd`, `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`, `scenes/backgrounds/**`, `scenes/effects/**`, `tests/presentation/**`
- Integration Point: `stage_changed`, `stage_shift_started` 구독; `stage_shift_presentation_finished` 반환.
- Dependencies: S5-G1 background key와 `INTEGRATION_CONTRACTS.md`의 Shift signal 계약.
- Verification: Stage World 전환, 현재 Stage local 공 4~5종의 족보가 순서대로 표시되고 Shift 후 새 목록으로 한 번 교체됨, `NEXT` Spawn 예고 없음, Shift 완료 신호 한 번, animation/HUD가 gameplay state를 직접 변경하지 않음.
- Do Not Modify: StageManager와 resource level mapping.

### S5-G5 3-Stage 통합 완주

- Owner: Integration
- Owned Files: `scenes/main/main.tscn`, `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `tests/integration/**`
- Integration Point: S5-G1~G4 결과를 playable Main에 조립.
- Dependencies: S5-G1~G4 `VERIFIED`.
- Verification: Top Ball/Score Clear 양쪽으로 세 Stage 연속 진행; stage reset/run preserve; 체류 시간과 Cashout 시간 기록.
- Do Not Modify: 각 Owner 내부 구현; 발견된 결함은 소유 lane으로 반환.

## Exit Gate

Q-S5, Integration Gate, 3-Stage Desktop/Web 완주.
