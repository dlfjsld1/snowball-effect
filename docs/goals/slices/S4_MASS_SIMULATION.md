# S4 — Mass Simulation

원문: [`../../current/tasks/03_mass_simulation.md`](../../current/tasks/03_mass_simulation.md)

## 결과

Merge 경로가 모든 공 쌍을 검사하지 않고 Web release 필수 규모인 동시 활성 500개를 감당하며, 1,000개 stretch 부하도 측정할 수 있다.

## Goals

### S4-G1 Spatial Grid

- Owner: Core
- Owned Files: `scripts/simulation/spatial_grid.gd`, `scripts/simulation/ball_simulation_manager.gd`, `tests/simulation/**`
- Integration Point: debug 지표 `candidate_count/grid_cell_count`를 Presentation/Release에 read-only 제공.
- Dependencies: S2 완료.
- Verification: level-aware grid, 필요한 인접 cell만 조회, release path에 전수 O(N²) 없음.
- Do Not Modify: HUD layout와 release 설정.

### S4-G2 슬롯 재사용과 allocation 점검

- Owner: Core
- Owned Files: `scripts/simulation/**`, `tests/simulation/**`
- Integration Point: `simulation_metrics_updated(metrics)` read-only contract.
- Dependencies: S4-G1.
- Verification: 비활성 index 우선 재사용, physics hot path 반복 대형 allocation 없음, FX와 논리 공 분리.
- Do Not Modify: Presentation FX implementation.

### S4-G3 Web release·1,000공 stretch 스트레스

- Owner: Core
- Owned Files: `tests/simulation/stress_test_scene.tscn`, `tests/simulation/**`
- Integration Point: Content/Systems가 Web 환경 측정을 반복할 수 있는 stress mode와 metric schema 제공.
- Dependencies: S4-G2; Content/Systems의 측정 환경 계약.
- Verification: 100/500/1,000개 평균·최저 FPS, 후보 수, allocation 기록. 실제 Web에서 500개 최저 30 FPS 이상이면 필수 Gate를 통과한다. 1,000개는 stretch/torture 결과와 병목을 정직하게 기록하되 30 FPS 미달만으로 Goal을 막지 않는다.
- Do Not Modify: Web export preset.

### S4-G4 일반 Snowball MultiMesh renderer

- Owner: Core
- Owned Files: `scripts/simulation/ball_renderer.gd`, `scripts/simulation/ball_renderer_circle.gdshader`, `scripts/simulation/ball_simulation_manager.gd`, `tests/simulation/**`
- Integration Point: simulation의 read-only render snapshot(`positions/radii/global_levels`)만 소비한다. Presentation은 향후 level별 Texture2D/머티리얼 binding을 제공할 수 있으나 simulation 배열을 직접 수정하지 않는다.
- Dependencies: S4-G3, S2 Ball catalog와 S5 local runtime radius 계약.
- Verification: 일반 Lv0~13은 global level별 reusable MultiMesh batch로 표시하고, runtime position/radius·Stage re-baseline/reset을 정확히 반영한다. Lv14 Black Hole은 전용 fallback 경로를 유지한다. 실제 Web에서 500개 Merge ON과 1,000개 stretch를 재측정하며 기존 S2/S4 simulation 회귀와 console error가 없다.
- Do Not Modify: Merge/Cashout/Stage rules, Item Ball/Black Hole 전용 gameplay·visual 구현, Presentation FX asset.

## Exit Gate

Q-S4와 Content/Systems가 수행한 Web stress smoke 통과.

## 승인된 후속 계획

S4-G3의 Web 병목 기록과 2026-08-12 local-only A/B prototype을 근거로 일반 Snowball 본체의 레벨별 `MultiMeshInstance2D` 전환을 S4-G4로 활성화한다. 기존 S4-G1~G3의 `VERIFIED` 상태는 유지한다.

- Owner 예정: Core
- Owned Files 예정: `scripts/simulation/ball_renderer.gd`, `tests/simulation/**`
- Integration Point 예정: simulation render snapshot을 read-only 소비하고, Presentation의 global-level Texture2D/머티리얼 binding을 gameplay state와 분리
- Dependencies: S4-G3, S2 Ball/Stage level 계약
- 대상: Item Ball과 Lv14 Black Hole Ball/runtime entity를 제외한 일반 Snowball 전체
- Verification 예정: draw 기준선과 결과 동일성, Stage binding/reset, 실제 Web 500 Merge ON, 1,000 stretch, 대표 HUD/FX 통합 회귀

최종 이미지 제작을 기다리지 않고 중앙 정렬 procedural placeholder 또는 Texture2D로 Core 구조를 검증할 수 있다.
