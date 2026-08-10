# Content / Systems Worklog

> Append-only. 실제 작업과 검증만 기록한다.

## 2026-08-09 — S1-G5 Pause·Restart 요청 UI

Owner: Content/Systems
Branch: `main` working tree

### 작업

- Pause와 Retry 의도만 Integration에 전달하는 요청 UI를 구현했다.

### 변경

- Esc/R 입력과 버튼을 `pause_requested`/`retry_requested` 신호로 변환.
- pause 상태에 따른 버튼 문구만 변경하고 SceneTree와 gameplay는 직접 수정하지 않음.

### 확인

- Primary `godot` MCP validate 4/4.
- Godot 4.7.1 headless: exit 0, `S1_G5_VERIFIED pause_requests=1 retry_requests=1 gameplay_mutation=none`.

### 다음 작업 / 주의

- 실제 pause/reset은 S1-G6 Integration의 GameManager가 처리한다.

## 2026-08-10 — S2-G1 공·점수 데이터

Owner: Content/Systems
Branch: `codex/s2-g1-ball-data`

### 작업

- `BallDefinition` Resource와 Lv0~6 BallDefinition `.tres`를 추가했다.
- Core가 읽기 전용으로 사용할 `BallCatalog.get_definition(global_level)` API를 제공했다.
- Lv1 collision radius는 Shared Skeleton에서 승인된 4 world units를 사용했다.
- Time Bonus는 StageDefinition 전용이므로 BallDefinition에 추가하지 않았다.

### 확인

- Godot 4.7.1 CLI headless: S2-G1 Catalog 검증과 S1-G1 배열 풀 회귀가 모두 exit 0.
- Primary `godot` MCP validate: `ball_definition.gd`, `ball_catalog.gd`, S2-G1 verification script/scene 모두 valid (4/4).

### 다음 작업 / 주의

- Core는 S2-G2에서 `BallCatalog.get_definition(global_level)`을 read-only로 소비해야 한다.
- Merge 결과 velocity 계약과 Catalog를 simulation에 연결하는 작업은 S2-G1 범위 밖이다.

## 2026-08-10 — S2-G1 구현 검토

### 수정

- Resource는 Godot에서 수정 가능한 객체이므로 `BallDefinition`의 부정확한 immutable 주석을 canonical source data로 바로잡았다.
- Catalog 검증을 실제 radius, mass, visual key 값 비교로 강화했다.
- `score_value`가 계획된 late-game `1e36`을 유지하는지 검증을 추가했다.

### 재확인

- Godot 4.7.1 CLI headless parse와 S2-G1 verification exit 0.
- Primary `godot` MCP validate: 수정한 definition/test/scene 3/3 valid.
