# S5 — Scale Shift

원문: [`../../current/tasks/04_stage_shift.md`](../../current/tasks/04_stage_shift.md)

## 결과

Ground, Planetary, Galactic을 연속 플레이하며 이전 최고 공이 다음 기본 공이 된다.

## Goals

### S5-G1 Stage 콘텐츠 매핑

- Owner: Content/Systems
- Owned Files: `resources/stages/**`, `resources/balls/**`, `tests/content/**`
- Integration Point: StageCatalog가 ordered `local_ball_levels`, spawn rate, `visual_radius_scale`, background key를 제공.
- Dependencies: S3-G1과 S4 완료.
- Verification: Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`가 각각 5종이고 이전 top이 다음 base와 동일; Lv7·Lv9는 catalog에는 있으나 기본 chain에서 비활성; Lv14는 `Black Hole` 최종 공; 값은 runtime 공식이 아닌 데이터.
- Do Not Modify: Stage runtime, StageManager, background scene.

### S5-G2 Stage re-baselining runtime

- Owner: Core
- Owned Files: `scripts/core/stage_runtime.gd`, `scripts/simulation/ball_simulation_manager.gd`, `tests/core/**`
- Integration Point: `apply_stage_definition(definition)`과 stage snapshot을 Integration에 제공.
- Dependencies: S5-G1 data와 S3 계약.
- Verification: base global level과 spawn rate 전환, Merge가 현재 ordered chain의 다음 항목을 사용해 Planetary `6→8→10`을 만들고 `global_level + 1`을 가정하지 않음, 새 Stage에 이전 배열/시간/점수 잠금이 누출되지 않음.
- Do Not Modify: StageManager, resource 값, Stage World.

### S5-G3 Scale Shift 상태 통합

- Owner: Integration
- Owned Files: `scripts/core/stage_manager.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`
- Integration Point: Core `CLEARED`, `stage_shift_started(next_definition, shift_id)`, Presentation `stage_shift_presentation_finished(shift_id)`, Content StageCatalog를 연결. S5-G4 전에는 Main의 임시 adapter가 같은 완료 API를 deferred 한 번 호출한다.
- Dependencies: S5-G1, S5-G2와 `INTEGRATION_CONTRACTS.md`의 Shift signal 계약.
- Verification: `CLEARED` 뒤에만 `SHIFTING`; spawn/timer stop→Settlement→연출/임시 adapter→다음 Stage; 잘못되거나 중복된 `shift_id`에도 Shift 한 번.
- Do Not Modify: Core 계산, StageDefinition 값, Presentation animation.

### S5-G4 Stage World와 Shift presentation

- Owner: Presentation
- Owned Files: `scripts/presentation/background_manager.gd`, `scripts/presentation/presentation_manager.gd`, `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`, `scenes/backgrounds/**`, `scenes/effects/**`, `tests/presentation/**`
- Integration Point: `stage_changed`, `stage_shift_started` 구독; `stage_shift_presentation_finished` 반환.
- Dependencies: S5-G1 background key와 `INTEGRATION_CONTRACTS.md`의 Shift signal 계약.
- Verification: Stage World 전환, Stage 이름을 persistent HUD에 갱신, 현재 Stage 5종 족보를 세로로 배치하고 공개된 항목만 표시, Shift 후 새 목록과 `revealed_count=1`이 한 번 적용됨, 새 공 최초 생성마다 한 항목만 공개, `NEXT` Spawn 예고 없음, Shift 완료 신호 한 번, animation/HUD가 gameplay state를 직접 변경하지 않음.
- Do Not Modify: StageManager와 resource level mapping.

#### S5-G3 handoff — Presentation 구현 전제

S5-G3는 S5-G4가 실제 Shift presentation을 제공한다는 전제에서 먼저 통합됐다. 현재 Main의 `auto_complete_shift_presentation`은 화면 연출을 대체하는 임시 adapter일 뿐이며, S5-G4 완료 조건이 아니다.

Presentation은 `stage_shift_started(next_definition, shift_id)`를 받은 뒤에만 Stage World/HUD 전환을 시작하고, 완료 시 같은 `shift_id`로 `stage_shift_presentation_finished(shift_id)`를 정확히 한 번 반환한다. Presentation은 `StageManager` state·timer·spawn·Stage data를 직접 변경하지 않는다. S5-G4 연결 시 Integration이 Main의 임시 adapter를 제거한다; Presentation은 adapter와 별도 자동 전이를 추가하지 않는다.

### S5-G5 3-Stage 통합 완주

- Owner: Integration
- Owned Files: `scenes/main/main.tscn`, `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `tests/integration/**`
- Integration Point: S5-G1~G4 결과를 playable Main에 조립.
- Dependencies: S5-G1~G4 `VERIFIED`.
- Verification: Top Ball/Score Clear 양쪽으로 세 Stage 연속 진행; stage reset/run preserve; 체류 시간과 Cashout 시간 기록.
- Do Not Modify: 각 Owner 내부 구현; 발견된 결함은 소유 lane으로 반환.

## Exit Gate

Q-S5, Integration Gate, 3-Stage Desktop/Web 완주.
