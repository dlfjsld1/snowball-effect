# Presentation Worklog

> Append-only. 실제 작업과 검증만 기록한다.

## 2026-08-09 — S1-G4 최소 HUD

Owner: Presentation
Branch: `main` working tree

### 작업

- Core의 점수와 활성 공 수 신호를 읽기만 하는 최소 HUD를 구현했다.

### 변경

- Stage Score, Run Score, active ball count label과 source binding API.
- 표시만 초기화하는 `reset_view()`와 source disconnect 처리.
- HUD가 gameplay 값을 변경하지 않는 자동검증.

### 확인

- Primary `godot` MCP validate 4/4.
- Godot 4.7.1 headless: exit 0, `S1_G4_VERIFIED score_readonly=true ball_count=1 reset_view=display_only`.

### 다음 작업 / 주의

- Main mount와 실제 source 연결은 S1-G6 Integration 소유다.
