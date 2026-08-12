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

## Exit Gate

Q-S4와 Content/Systems가 수행한 Web stress smoke 통과.
