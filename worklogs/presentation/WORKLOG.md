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

## 2026-08-13 — S5-G4 C4 Godot Frame Kit 도입

Owner: Presentation
Branch: `ui-design`

### 작업

- 승인된 C4 Selective-Waist CRT Cabinet의 투명 PNG 10개를 Presentation-owned runtime 경로로 도입했다.
- `GameplayFrame` Scene과 profile script를 추가해 L0/L1/L2/L3에서 field와 고정 폭 wing이 화면 중심 `x=800`을 기준으로 함께 이동하도록 구성했다.
- CRT shell과 phosphor glass를 별도 layer로 유지하고, 왼쪽 full housing·오른쪽 top/bottom housing·CRT가 없는 18px selective waist 구조를 반영했다.

### 변경 파일과 계약

- Goal: `S5-G4`, lane: Presentation, 상태: `IN PROGRESS`.
- 추가 Owned Files: `scripts/presentation/gameplay_frame.gd`, `assets/sprites/ui/frame/c4/**`.
- Integration-owned Main/StageManager와 S5-G3 임시 adapter는 변경하지 않았다.
- 기존 `stage_shift_started(next_definition, shift_id)` 및 `stage_shift_presentation_finished(shift_id)` wiring은 이번 frame asset 단위에서 의도적으로 제외했다.

### 확인 / 남은 검증

- 10개 PNG의 선언 크기와 partial alpha 0을 정적 검사했다.
- Scene의 `res://` 참조 11개가 모두 존재하고 `git diff --check`가 통과했다.
- L0/L1/L2/L3 중심축·field width·152px wing 위치를 자동 검증하는 Godot test Scene을 추가했다.
- Godot 4.7.1 CLI로 프로젝트 import/load exit 0, 전용 test Scene exit 0과 `4 profiles, fixed wings, centered field`를 확인했다.
- Primary `godot` MCP 3.2.2를 Codex에 등록하고 `get_project_info`에서 Godot `4.7.1.stable`과 프로젝트 구조 응답을 확인했다.
- 프레임 kit 검증은 통과했지만 Stage World·Shift presentation 전체는 남아 있으므로 S5-G4는 `IN PROGRESS`를 유지한다.

## 2026-08-13 — S5-G4 플레이 프레임 하단 레이아웃 보정

- 물리 Play Field와 시각적 Cashout corridor를 분리하고, Ground의 최대 cashout 가능 공이 완전히 퇴장할 때까지 중앙 베젤 안에 보이도록 하단 여유를 64px 확보했다.
- 왼쪽 housing은 세로 Genealogy CRT 하단 + 12px까지 축소하고, 오른쪽 상단 housing도 Item CRT 하단 + 12px까지 축소했다.
- 오른쪽 하단 Pause CRT/housing/button을 하나의 패널로 합치고 중앙 베젤과 `y=900` 바닥선을 맞췄다.
- Godot 4.7.1 CLI에서 S5-G4 frame kit 및 playable integration 검증과 S1-G5/S3-G6/S5-G3 회귀 검증이 모두 통과했다.

## 2026-08-13 — S5-G4 CRT 스캔라인 보정

- 80px CRT glass NinePatch의 중앙 행이 세로로 확대되어 긴 CRT에 굵은 검은 띠가 생기던 원인을 확인했다.
- 별도 색상 변형 에셋 대신 모든 CRT glass의 세로 stretch mode를 `TILE`로 통일해 원본 1px 스캔라인과 승인 팔레트를 유지했다.
- S5-G4 frame kit 및 playable integration Godot CLI 검증이 통과했다.

## 2026-08-14 — Pixel Design Guidelines 편입

- 외부 `PIXEL_DESIGN_GUIDELINES.md`를 기존 Foundations, Stage-local radius, Web resize, asset production 계약과 대조했다.
- logical pixel, 크기별 Ball LOD, FX·Background·HUD 밀도, AI 생성물 cleanup을 `docs/design/12_PIXEL_DESIGN_GUIDELINES.md`의 단일 제작 기준으로 편입했다.
- `1600×900`을 고정 runtime 출력으로 해석하지 않고 authoring 기준으로 제한했으며, 개별 에셋의 정수 transform과 전체 Web viewport fractional fit을 구분했다.
- runtime Scene·Script·Resource와 Goal 상태는 변경하지 않았다. 문서 링크와 핵심 계약 정적 검증이 통과했다.

## 2026-08-14 — S5-G4 Paper-8 Laboratory modular frame kit

- Owner lane: Presentation. Goal remains `IN PROGRESS`; no Integration lock was used.
- Audited the approved concept source: `1672x941`, 114,963 unique colors, and 13 exact Paper-8 pixels.
- Added a deterministic cleanup pipeline that normalizes through `800x450`, quantizes to the exact eight-color Paper-8 palette, and exports at `1600x900` with enforced `2x2` authoring blocks.
- Exported 36 modular PNGs: 3 coarse modules, 8 bezel pieces, 12 CRT references, 10 machinery cutouts, and 3 deterministic tiles.
- Added an exploded image-generation reference for component-boundary guidance only; it is explicitly excluded from runtime use.
- Fixed both round-gauge cutouts after validation found an opaque rectangular crop; dedicated ellipse masks now produce binary-alpha ornaments.
- `verify_paper8_frame_kit.ps1` passed all 36 assets for exact palette, alpha, dimensions, and pixel-grid compliance.
- Godot 4.7.1 `--import` completed successfully. The dedicated Godot test loaded all 36 PNGs as `Texture2D` and passed; the existing four-profile C4 frame regression also passed.
- Intentionally excluded runtime wiring and replacement of the current 152px C4 wings. That adoption requires a separate approved layout change.

## 2026-08-14 — S5-G4 Paper-8 runtime reassembly and field-boundary alignment

- Replaced the C4 frame scene visuals with exact-size Paper-8 runtime pieces while keeping the approved centered four-profile expansion and 152px moving wings.
- Rebuilt the central bezel as a transparent 50px frame whose outside spans `y=0..900`; removed the previous 120px top presentation gap.
- Defined the visible and physical Play Field as the bezel's inner pixel opening: L0/L1/L2/L3 widths `560/720/880/1040`, shared vertical range `y=50..850`.
- Existing Main frame wiring now applies that single Rect to Simulation, Paddle, Backdrop, and Spawn. The simulation's strict lower test removes a ball only when `ball_top > 850`, after the full sprite clears the opening.
- Added 10 runtime assembly assets, bringing the validated manifest to 46 PNGs. Removed the obsolete `crt_genealogy_132x360` intermediate after replacing it with the final 132x400 panel; it can be recreated from the source crop by restoring the old build size parameter.
- Updated the directly coupled Main integration verification expectations without changing Integration-owned runtime files or signal contracts.
- Verification: exact palette/alpha/grid `46/46`; Godot 4.7.1 asset import; Paper-8 Texture2D load; four-profile frame and ball-boundary checks; Main frame/bounds/HUD/Pause integration; S3-G6 HUD and S1-G5 Pause regressions; clean Main load.
- Native OpenGL render captured a `1600x900` L0 preview with the top and bottom frame pixels touching the viewport edges and no runtime errors.
- Goal remains `IN PROGRESS` because Stage backgrounds and Scale Shift animation are still outstanding.

## 2026-08-14 — S5-G4 Paper-8 frame v2 independent-component rebuild

- Rejected the crop-derived runtime assembly and retained the approved full-frame image only as a visual reference.
- Independently designed nine new components: one dynamic central bezel, two continuous full-height chassis, and six purpose-built CRTs.
- Removed separate machinery filler sprites from the runtime scene. Empty chassis regions now come from the continuous left/right body art instead of pasted fragments.
- Expanded each moving wing from 152px to 200px while preserving centered L0/L1/L2/L3 field widths and the authoritative `y=50..850` physics opening.
- Archived chroma and cleaned alpha sources outside Godot import; finalized runtime PNGs use the exact Paper-8 palette, binary alpha, and an enforced 2x2 authoring grid.
- Verification: `PAPER8_FRAME_V2_VERIFIED assets=9`; Godot 4.7.1 Texture2D load; four-profile frame/ball-boundary test; Main HUD/Pause integration test; native OpenGL 1600x900 capture.
- Preview: `docs/design/mockups/drafts/frame-paper8-runtime-preview-v2.png`.
- S5-G4 remains `IN PROGRESS`; Stage backgrounds and Scale Shift animation are intentionally not claimed complete.

## 2026-08-14 — S5-G4 Stage World and Scale Shift completion

- Documented two deferred improvements without implementing them: stronger open-Cashout direction cues and powered CRT phosphor/static treatment.
- Generated independent Ground, Planetary, and Galactic Stage World sources with built-in ImageGen, then normalized them to `1600x900`, approved per-Stage palettes, opaque pixels, and a strict 2x2 authoring grid.
- Ground uses snow banks/conifers plus 48 moving snow particles. Planetary uses an Earth horizon aligned to the Ground side banks, Mercury/Moon/Mars/Sun, and 28 twinkling stars. Galactic uses a separated spiral galaxy and teal nebula plus 44 twinkling stars.
- Added `BackgroundManager`, `StageAmbientLayer`, and `PresentationManager`. The `0.9s` Shift crossfades Stage World, moves the bezel and both 200px wings around center x=800, keeps HUD/Pause aligned, and emits the matching completion ID once.
- Verification: `STAGE_WORLD_BACKGROUNDS_VERIFIED assets=3 canvas=1600x900 grid=2`; Godot 4.7.1 Stage World/Shift test; frame bounds and HUD/Pause regressions; Native OpenGL Ground and mid-Shift captures at 1600x900.
- Runtime visual load: three static backgrounds total 4,320,000 pixels, approximately 16.48 MiB uncompressed RGBA; dynamic overlay peak 48 small draw-rect particles. FPS was not measured in this Goal and remains part of S5-G5 Web integration evidence.
- Preview paths: `docs/design/mockups/drafts/frame-paper8-stage-world-preview.png` and `frame-paper8-scale-shift-preview.png`.
- S5-G4 is `VERIFIED`; three-Stage Desktop/Web completion remains S5-G5.

## 2026-08-18 — S2-G5 contract repair and S6-G2 design preparation

Owner: Presentation
Branch: `fx-design`

### 작업

- `ball_merged(result_level, world_position)` 2인자 계약에 없는 score amount 추측을 제거하고 catalog name만 표시하도록 정정했다.
- D안 `FIRST CONTACT` CUT-IN을 공통 배경과 공별 문구·공 레이어로 분리하고, 대상 6종을 Ground `Giant Snowball`·`Moon`, Planetary `Supernova`·`Galaxy`, Galactic `Event Horizon`·`Black Hole`로 확정했다.
- 후속 Goal로 local Lv4 즉시 Clear 제거(S3-G7), Stage Score gauge(S3-G8), 축하 메시지·`Next Stage` 확인(S5-G6/G6I), Galactic 투명 배경(S5-G7)을 문서화했다.

### 검증

- Godot 4.7.1 CLI project load exit 0. S2-G5, S6-G1, S6-G3, S6-G4 foundation, S6-G4 wiring 검증이 모두 exit 0으로 통과했다. S6-G4 wiring 종료 시 기존 ObjectDB 12개/resource 6개 leak 진단이 남지만 test assertion과 exit code는 정상이다.
- S2-G5 fixture는 현재 Stage-local Merge 계약에 맞게 Ground chain을 명시했다. Core runtime은 변경하지 않았다.
- CUT-IN layer asset 12개는 투명 alpha와 1600×900 공통 배경 조립 규격을 사용한다.
- `git diff --check` 통과. MCP/Web은 이번 문서·asset 준비 변경에 사용하지 않았다.
- push 직전 `origin/main` `dbd62bb`를 pull해 S6-G4 VERIFIED 오디오 갱신을 병합했다. STATUS 단일 충돌은 원격 S6-G4 최신 증거와 신규 PENDING Goal을 모두 보존해 해결했으며, 병합 뒤 Godot 4.7.1 CLI project load, S2-G5, S6-G4 foundation/wiring, Main 120-frame smoke가 모두 exit 0이었다.

### 제외

- S6-G2 runtime controller, pause/handoff, Run-scoped 중복 억제는 구현하지 않았다.
- S3-G7/S3-G8/S5-G6/S5-G6I/S5-G7은 PENDING 문서 계약이며 runtime 파일을 수정하지 않았다.
- 사용자가 별도로 결정한 Stage Restart 계약은 변경하지 않았다.
## 2026-08-20 — S8-G5 Black Hole Phase Presentation 구현

- Owner lane: Presentation/UI
- Goal: S8-G5
- Owned files: `scripts/presentation/presentation_manager.gd`, `scripts/presentation/black_hole_presentation_overlay.gd`, `scenes/backgrounds/gameplay_frame.tscn`, `scenes/effects/black_hole_presentation_overlay.tscn`, `tests/presentation/s8_g5_black_hole_presentation_verification.*`.
- 구현: Galactic L2→L3 Frame/HUD visual profile 보간, 중복·stale phase ID 방어, Black Hole field pulse/ring overlay, terminal two-Black-Hole orbit·burst overlay, gameplay HUD/Pause hide와 retry-reset API를 추가했다.
- Integration contract: `black_hole_phase_presentation_finished(phase_id)` 및 `black_hole_finale_presentation_finished()`를 제공한다. S8-G4는 실제 Main에서 phase 요청/완료와 terminal Result 지연 표시를 연결해야 한다.
- Verification: Godot 4.7.1 CLI/headless `s8_g5_black_hole_presentation_verification.tscn` exit 0 (`l2_to_l3=true`, phase ID single-flight, finale once); `s5_g4_stage_world_shift_verification.tscn` exit 0.
- 상태: Presentation 산출물은 `IMPLEMENTED`; S8-G4 실제 wiring과 S8-G3 Result handoff 이후 Desktop/Web 최종 관찰이 남아 있다.

## 2026-08-20 — Pause/Retry B-design control module

- Owner lane: Presentation/UI
- Scope: 기존 우측 하단 Pause/Retry CRT 모듈을 사용자가 선택한 B안(이중 원형 청록 CRT + 밝은 금속 베젤)으로 원본 `176×104` 스프라이트의 팔레트·도트 밀도·외곽 배치를 유지해 직접 편집한 런타임 스프라이트로 교체했다.
- Owned files: `assets/sprites/ui/frame/paper8_lab_v2/**`, `scenes/backgrounds/gameplay_frame.tscn`, `scenes/ui/pause_menu.tscn`.
- Compatibility: 기존 `pause_requested`/`retry_requested` 신호와 Button 라벨 렌더링은 유지한다. 새 원형 버튼의 중심·면적에 맞춰 투명 Button 입력 영역을 재정렬했다.
- Verification: 새 PNG를 Godot import한 뒤 Web release export `savepack` exit 0을 확인했다. 이 환경의 standalone headless scene test는 `user://logs` open 실패 뒤 signal 11로 종료되어 UI action regression 증거로 사용하지 않았다.

## 2026-08-20 — Empty current-item slot

- Owner lane: Presentation/UI
- Scope: 우측 `CURRENT ITEM` CRT의 중앙 녹색 필드를 빈 슬롯 유휴색 `#1F244B`로 교체했다. 프레임·파이프·indicator는 보존했다.
- Intent: 아이템 미보유 상태가 활성 녹색 표시처럼 보이지 않도록 한다.
- Verification: 런타임 `176×300` 텍스처에서 중앙 연결 필드 20,956px만 변경했으며 Web release export를 재생성한다.

## 2026-08-20 — S3-G8 20-cell Stage Score gauge 및 Pause/Retry CRT 재구성

- Owner lane: Presentation/UI. Goal S3-G8은 `IMPLEMENTED`로 전환했다.
- 우측 빈 CRT에 `stage_score / clear_score`를 read-only로 표시하는 20칸 세로 게이지를 추가했다. 0점에는 셀을 보이지 않고, 점수에 따라 아래부터 채우며 70%는 14칸, overflow는 20칸으로 clamp한다. 다음 Scale Shift target이 없는 Galactic은 gauge를 숨긴다. HUD는 Clear 판정이나 점수 변경을 하지 않는다.
- Pause/Retry는 별도 이미지를 덧붙이지 않고 원본 `crt_pause_v2_176x104`의 녹색 버튼 내부 픽셀을 직접 원형 청록 CRT/밝은 금속 베젤로 치환해 `crt_pause_b_v2_176x104`를 재생성했다. 원래 cabinet 외곽·상단 표시등·하단 패널은 그대로 보존했고, 실제 Button hit 영역과 글자를 두 원 중심에 맞췄다.
- 변경: `scripts/ui/stage_score_gauge.gd`, HUD scene/script, pause layout, `build_pause_b_from_original.ps1`, runtime PNG와 manifest, S3-G8 verification scene.
- Verification: Godot 4.7.1 Web release export가 `[ DONE ] savepack`으로 성공해 새 script/scene/texture가 Web PCK에 포함됨을 확인했다. 이 환경에서 headless scene test는 project assertion 전에 `user://logs`를 열지 못하고 Godot process가 signal 11로 종료되어, S3-G8의 실제 Web visual/hit-area 확인은 남겼다.

## 2026-08-20 — Pause modal terminal overlay ordering

- Black Hole overlay가 GameplayFrame 내부 `z_index=100`으로 Pause modal보다 앞에 그려지던 회귀를 수정했다.
- PauseMenu root를 `z_index=200`으로 올려 Pause modal과 dim layer가 Black Hole Phase/Finale overlay를 포함한 gameplay presentation보다 항상 전면에 렌더링되게 했다.
- Godot 4.7.1 Web release export `[ DONE ] savepack` 성공. 실제 Galactic Pause 화면은 Web 수동 확인이 남아 있다.

## 2026-08-20 — Pause/Retry B안 기준 재적용

- 직전 직접 픽셀 재구성이 사용자가 채택한 B안의 넓은 강철 원형 베젤·중앙 결합부·외곽 파이프 비율과 다르다는 피드백을 반영했다.
- 사용자가 제공한 B안의 버튼 모듈을 기준 자산으로 보존하고, `176×104` runtime PNG를 nearest-neighbor로 rasterize했다. 두 버튼의 명칭은 자산 내부 도트 텍스트만 사용하며, 별도 Godot Button 텍스트를 제거해 중첩을 막았다.
- 기존 hit 영역은 원형 버튼 중심 `(50, 54)`·`(126, 54)`과 일치한다. Runtime PNG는 `176×104`, binary alpha(부분 alpha 0px), 80개의 투명 모서리 픽셀을 확인했다.
- Godot 4.7.1 Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — Pause/Retry B안 외곽 판 제거

- B안 전체의 검은 배경 판이 원래 오른쪽 하단 CRT 위에 덧씌워진 것처럼 보인다는 피드백을 반영했다.
- `crt_pause_v2_176x104`를 최종 베이스로 유지하고, 내부 녹색 사각 버튼 픽셀만 빈 CRT색으로 치환한 뒤 B안의 두 원형 버튼과 중앙 결합 볼트 영역만 직접 복사했다. 따라서 외곽 투명 alpha·상단 표시등·원래 하우징의 도트 픽셀은 유지되고, 검은 바깥 여백은 존재하지 않는다.
- Godot 4.7.1 Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — Pause/Retry B안 수직 정렬

- 원형 버튼과 중앙 결합부가 원래 하우징에 비해 낮아 보이는 피드백을 반영해 B안 삽입 픽셀만 4px 위로 이동했다.
- 실제 Button hit 영역 중심(`y=52`)과 새 원형 버튼 중심(`y=51`)을 맞췄다. Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — Pause/Retry B안 수직 정렬 재보정

- 4px 보정이 실제 게임 크기에서 충분히 드러나지 않아, B안 삽입부를 원래 기준에서 총 8px 위로 옮겼다.
- hit 영역도 `y=12` offset으로 함께 이동해 원형 버튼 중심(`y=47`)과 맞췄다. Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — Pause/Retry 위치 이동 취소

- 사용자 지시에 따라 4px 및 8px 수직 위치 이동을 모두 취소했다. 원형 버튼·중앙 결합부와 Button hit 영역은 원래 기준 좌표로 복귀했다.
- 다음 보정은 node/asset translation이 아니라 원본 CRT 내부의 도트 픽셀 재작화로만 수행한다. Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — S5-G6 Stage Clear 확인 UI

- Final Settlement Score Clear 뒤 gameplay를 바꾸지 않는 `StageClearPanel`을 추가했다. panel은 authoritative snapshot의 Stage 이름/점수와 `NEXT STAGE` action만 표시하며 `clear_id` 요청을 한 번 발행한다.
- 통합 검증에서 panel 표시, focus, matching request 이후 hide를 확인했다.

## 2026-08-21 — S8-G5 final player-path verification

Owner: Presentation

- 사용자 실제 플레이로 첫 Black Hole Snowball 뒤 phase 진입·기믹 생성, L2→L3 Frame/HUD 확장 뒤 Galactic 재개, 두 번째 Black Hole 충돌 뒤 finale→Result 경로를 확인했다.
- 기존 S8-G5 CLI phase/finale verification과 S5-G4 regression evidence를 합쳐 S8-G5를 `VERIFIED`로 갱신했다.
