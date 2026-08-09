# S2 — Merge and Score

원문: [`../../current/tasks/02_merge_system.md`](../../current/tasks/02_merge_system.md)

## 결과

같은 global level 공만 결정적으로 합체하고 데이터 기반 점수와 표시가 동작한다.

## Goals

### S2-G1 공과 점수 데이터

- Owner: Content/Systems
- Owned Files: `scripts/data/ball_definition.gd`, `resources/balls/**`, `tests/content/**`
- Integration Point: read-only `BallCatalog.get_definition(global_level)` API.
- Dependencies: S1 완료; Core가 필요한 필드 계약 제시.
- Verification: global level, radius, mass, base `score_value`, visual key가 로드됨; Time Bonus 필드 없음.
- Do Not Modify: Merge 로직, renderer, HUD.

### S2-G2 같은 레벨 후보 탐색

- Owner: Core
- Owned Files: `scripts/simulation/ball_simulation_manager.gd`, `tests/simulation/**`
- Integration Point: S2-G1의 BallCatalog를 read-only로 소비.
- Dependencies: S2-G1 API와 S1-G1 배열 구조.
- Verification: 같은 global level의 겹친 공만 후보; 다른 level은 통과; tie-break 재현 가능.
- Do Not Modify: Resource 값과 Presentation.

### S2-G3 결정적 Merge commit

- Owner: Core
- Owned Files: `scripts/simulation/ball_simulation_manager.gd`, `tests/simulation/**`
- Integration Point: `ball_merged(result_level, world_position)`와 `top_ball_created(global_level)` 이벤트 제공.
- Dependencies: S2-G2.
- Verification: 입력 둘 제거·출력 하나 생성, 한 공은 tick당 한 번만 소비, 동일 seed 결과 재현.
- Do Not Modify: Stage 전환, Merge FX.

### S2-G4 Score formatter

- Owner: Content/Systems
- Owned Files: `scripts/utils/score_formatter.gd`, `tests/content/**`
- Integration Point: Presentation이 호출할 pure formatting API.
- Dependencies: S2-G1 score range.
- Verification: 0, 경계값, late-game 큰 값에서 overflow/깨진 문자열 없음.
- Do Not Modify: 점수 ledger와 HUD layout.

### S2-G5 Merge 표시 통합

- Owner: Presentation
- Owned Files: `scripts/presentation/effect_manager.gd`, `scenes/effects/merge_effect.tscn`, `scripts/ui/hud.gd`, `tests/presentation/**`
- Integration Point: Core `ball_merged` 구독, Content `score_formatter` 소비, Main mount는 Integration에 요청.
- Dependencies: S2-G3 event와 S2-G4 API.
- Verification: Merge 한 번에 FX 한 번, 큰 값 표시 정상, Presentation이 Merge/score state를 변경하지 않음.
- Do Not Modify: simulation, score ledger, Main scene.

## Exit Gate

Q-S2와 Desktop/Web smoke 통과.
