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

## 2026-08-10 — Retro Pixel Arcade visual direction 문서 정교화

Owner: Presentation
Branch: `main` working tree

### 작업

- 구현 없이 기존 디자인 문서의 Retro Pixel Arcade Machine 방향을 dark retro arcade / dim CRT machine 톤으로 구체화했다.

### 변경

- 어두운 기본 팔레트, 제한적 강조색, CRT·기계 프레임 HUD 방향을 명시했다.
- Merge와 Cashout 효과의 재질을 각진 픽셀 파편·도트·사각형 스파크로 정리했다.
- 밝은 캐주얼 퍼즐풍, 파스텔, 과도한 soft bloom, 둥근 모바일 UI, 연기·마법형 파티클을 피할 방향으로 기록했다.

### 확인

- `00_VISUAL_IDENTITY`, `01_SCREEN_COMPOSITION`, `03_GAMEPLAY_EFFECTS`만 수정했다.
- runtime 코드, Scene, 테스트, Goal 상태는 변경하지 않았다.

## 2026-08-12 — V5 Ball/HUD/Black Hole Phase 디자인 동기화

Owner: Presentation
Branch: `ui-design` working tree

### 작업

- 사용자 최신 결정에 맞춰 Ball catalog, HUD genealogy, 네 Frame profile과 Galactic Black Hole 최종 국면을 문서 전반에 동기화했다.
- 승인된 V4 Frozen Enamel 방향을 계승한 팀 공유 V5 interactive HTML과 1600×900/1280×720 PNG export를 제작했다.

### 변경

- 기본 Stage chain을 Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`로 고정하고 Lv14를 `Final Snowball (working title)`로 Black Hole 기믹과 분리했다.
- L3를 terminal profile에서 Galactic `Black Hole Phase Transition` 이후 gameplay profile로 변경했다.
- HUD에 Stage 이름과 세로 5칸 progressive reveal을 추가하고 `ball_merged(result_level, world_position)` 2인자 계약을 동기화했다.
- S3-G6/S5-G1·G2·G4/S8-G1·G4와 새 S8-G5의 Owner, Integration Point, Verification을 갱신했다.

### 확인

- `git diff --check` 통과, 변경 Markdown relative link 0건 오류, fence mismatch 0건.
- HTML selector 8/8, duplicate id 0, CSS `font-size` 14px 미만 0.
- system Chrome headless software rendering으로 1600×900 8개 화면과 1280×720 Black Hole Phase를 렌더하고 육안 점검했다.
- Godot runtime Scene/Script/Resource는 수정하지 않았고 CLI/MCP 게임 검증은 수행하지 않았다.

### 다음 작업 / 주의

- S2-G1 runtime Resource는 최신 catalog와 달라 `PENDING` 재검증이 필요하다.
- Black Hole Phase의 정확한 발동 조건은 S8 Core/Content 계약에서 확정해야 한다.
- Pause Stage Restart 계약은 이번 변경에서 수정하지 않았다.

## 2026-08-12 — V5.1 Lv14 Black Hole 명칭 복원

Owner: Presentation
Branch: `ui-design` working tree

### 작업

- 사용자 최신 결정을 우선해 Lv14 Ball의 이름과 visual key를 `Black Hole`/`black_hole`로 확정했다.
- 동명인 Lv14 BallDefinition과 Galactic 이동 Black Hole 맵 기믹을 별도 gameplay entity로 문서·Goal·목업에서 구분했다.

### 변경

- `Final Snowball (working title)` 및 `final_snowball` 구계약을 active split 문서에서 제거했다.
- Black Hole Phase 목업에서 작은 `LV14 BLACK HOLE BALL`과 거대한 `BLACK HOLE FIELD · MAP GIMMICK`을 scale·outline·field distortion으로 구분했다.
- S2-G1은 Lv14 Resource가 이미 최신 계약과 일치함을 기록하되, Lv6/Lv7/Lv9/Lv10 catalog drift 때문에 `PENDING`을 유지했다.

### 확인

- Godot runtime Scene/Script/Resource는 수정하지 않았다. 기존 `ball_14_black_hole.tres`의 display name, visual key, score를 read-only로 확인했다.
- V5.1 HTML과 Black Hole Phase PNG를 system Chrome headless로 1600×900/1280×720 재렌더하고, 작은 Ball과 큰 맵 기믹의 label·scale·outline 구분을 육안 검증했다.

## 2026-08-12 — S3-G6 Stage HUD

Owner: Presentation
Branch: `codex/s3-g6-stage-hud`

### 작업

- 현재 Stage의 이름, 남은 시간, Stage/Run Score, Clear Target을 HUD에 읽기 전용으로 표시했다.
- 현재 Stage chain을 고정 세로 5칸 genealogy로 표시하고, Stage 진입에는 첫 공만 공개하며 실제 Merge 결과가 처음 생성될 때만 다음 칸을 공개했다.

### 확인

- Godot 4.7.1 CLI headless S3-G6와 S1-G4 HUD verification: exit 0.
- Primary `godot` MCP validate 5/5, Desktop Main에서 Ground readout과 Snowflake → Snowball → Big Snowball 공개, runtime error 0.
- MCP 종료 후 clean Web release export를 In-app Browser에서 검증: Canvas와 live HUD/genealogy 정상, console warning/error 0.

## 2026-08-12 — S2-G5 Merge 표시 통합

Owner: Presentation
Branch: `codex/s2-g5-merge-presentation`

### 작업

- `ball_merged(result_level, world_position)`을 read-only 구독하는 HUD 내부 `EffectManager`를 추가했다.
- 결과 공의 catalog 이름·기본색·`fx_tier`와 `ScoreFormatter` 값으로 짧은 픽셀 파편/원형 flash 및 `VALUE` 표시를 생성한다.

### 확인 / 남은 검증

- Primary `godot` validate 7/7, Desktop Main에서 Merge 1회당 FX 1개, score 상태 불변, `10K`와 `1.00e+43` 포맷, runtime error 0을 확인했다.
- clean Web release export는 성공했다. 다만 이 환경에서는 local HTTP port bind가 `WinError 10013`으로 차단되어 browser smoke가 남아 S2-G5는 `IMPLEMENTED`로 유지한다.

## 2026-08-12 — Stage-local runtime radius 정정

- 잘못 적용했던 global Lv0~14 radius 일괄 2배 변경을 전부 되돌렸다.
- 실제 visual/collision 반지름은 현재 Stage local level 기준 `4, 8, 16, 32, 64`로 계산하도록 정정했다.
- 공유 공 Moon과 Galaxy는 다음 Stage의 local Lv0가 되면 visual/collision 반지름 모두 `4`로 다시 시작한다.
