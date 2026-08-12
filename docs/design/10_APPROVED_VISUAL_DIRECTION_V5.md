# 10. Approved Visual Direction V5

Revision: V5.1 — 2026-08-12 Lv14 `Black Hole` 명칭 복원

Status: APPROVED VISUAL DIRECTION — production and runtime remain Goal-gated
Approved by: User
Approved on: 2026-08-12
Owner: Presentation
Working name: **Frozen Enamel Arcade / Black Hole Phase Revision**

## 1. Adoption Statement

V5는 V4의 Frozen Enamel 재질, slim fixed-width bezel, Main/Pause 구성과 Merge·Item·Milestone FX 문법을 유지하면서 최신 Ball/HUD/Black Hole 계약을 반영한다. 이 문서와 팀 공유 [HTML mockup](WIREFRAME_DYNAMIC_PLAYFIELD.html)이 현재 visual source다. V4 문서는 역사 자료로 남긴다.

이 승인은 Godot runtime Scene·Script·Resource·asset import 구현 승인이 아니다.

## 2. Canonical Ball and Stage Mapping

전역 visual catalog는 0~14의 15종이다.

| Global level | Concept | Default Run |
|---:|---|---|
| 0 | Snowflake | Ground |
| 1 | Snowball | Ground |
| 2 | Big Snowball | Ground |
| 3 | Giant Snowball | Ground |
| 4 | Moon | Ground top / Planetary base |
| 5 | Earth | Planetary |
| 6 | Sun | Planetary |
| 7 | Red Giant | catalog only |
| 8 | Supernova | Planetary |
| 9 | Nebula | catalog only |
| 10 | Galaxy | Planetary top / Galactic base |
| 11 | Galaxy Cluster | Galactic |
| 12 | Quasar | Galactic |
| 13 | Event Horizon | Galactic |
| 14 | Black Hole | Galactic top |

기본 ordered chain은 Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`다. Lv7과 Lv9는 15종 visual bible에는 포함하지만 기본 Run에서는 사용하지 않는다. Lv14 Black Hole Ball은 작은 gameplay silhouette, 공 전용 고대비 outline, compact accretion ring을 사용한다. 이동 Black Hole 맵 기믹은 훨씬 큰 환경 scale, field grid lensing, `MAP GIMMICK` label로 구분한다.

## 3. Black Hole Phase

Lv14 `Black Hole`은 BallDefinition이다. 이와 별개의 이동 Black Hole 맵 기믹은 별도 Stage나 BallDefinition이 아니라 Galactic 안에서 발동하는 최종 국면 Stage effect다. 정확한 발동 조건은 S8 Core/Content 계약에서 정한다.

| Profile | Gameplay role | Active Rect seed |
|---|---|---|
| Initial | Ground | `Rect2(500, 0, 600, 900)` |
| L1 | Planetary | `Rect2(420, 0, 760, 900)` |
| L2 | Galactic | `Rect2(340, 0, 920, 900)` |
| L3 | Galactic — Black Hole Phase | `Rect2(260, 0, 1080, 900)` |

L2→L3의 이름은 **Black Hole Phase Transition**이다. `terminal presentation transition`은 gameplay가 계속되는 상태를 종료 상태처럼 오해하게 하므로 사용하지 않는다. 전환 중에만 gameplay를 잠그고 Frame·표시 Field·logical Play Field·HUD housing을 같은 중심축에서 함께 확장한 뒤 Galactic gameplay를 재개한다. Lv14 최종 공 Clear 뒤에는 추가 Frame Shift 없이 Result로 이동한다.

## 4. HUD Contract

왼쪽 slim bezel의 순서는 다음과 같다.

1. Stage name — `Ground`, `Planetary`, `Galactic`.
2. Time.
3. Stage Score / Target.
4. Ball genealogy — 고정 5칸 세로 chain.
5. Run Score.

Stage 진입 시 첫 공만 표시한다. 새 local 공을 처음 만들면 다음 슬롯의 아이콘과 이름을 한 번 공개한다. 5칸 housing의 크기는 유지해 reflow를 막지만 미발견 공의 정답 silhouette·아이콘·이름은 출력하지 않는다. Stage Shift에서는 새 chain과 첫 공 공개 상태로 바꾼다. Stage Restart 복원 방식은 이 디자인 문서에서 새로 결정하지 않는다.

오른쪽 slim bezel은 active item/effect와 Pause를 유지한다.

## 5. Pixel and Type Floor

- 1600×900 필수 gameplay text: 최소 `16px`.
- Time·Score·Stage name 등 1차 정보: `18px` 이상 시작.
- 보조 상태/label: 최소 `14px`.
- 14px 미만 text는 제거 가능한 장식 각인에만 허용.
- 기능 경계는 기준 화면에서 최소 `2px`; focus는 색 외 outline/offset을 함께 사용.
- 1280×720에서 text가 최소 기준 아래로 축소되면 label을 줄이고 숫자·Stage 이름·아이콘을 우선 보존한다.

## 6. FX Continuity

- Merge: V4 `Compression Bloom`; 확정된 `ball_merged(result_level, world_position)` 2인자만 사용한다.
- Merge numeric score popup: 별도 authoritative `amount + world_position` event가 없으면 사용하지 않는다.
- Item Box: Ball impact → crack → break → item reveal의 `Salvage Burst`.
- Score milestone: gameplay를 멈추지 않는 `Cabinet Score Lock`.
- Black Hole Phase: cyan rail charge → L2/L3 edge separation → dark lens reveal → HUD 안정화 → control return. Lv14 Black Hole Ball과 이동 Black Hole 맵 기믹은 이름/motif를 공유하되 scale·outline·field distortion으로 즉시 구분한다.

## 7. Team Artifact

- Interactive HTML: [WIREFRAME_DYNAMIC_PLAYFIELD.html](WIREFRAME_DYNAMIC_PLAYFIELD.html)
- Default PNG: [WIREFRAME_DYNAMIC_PLAYFIELD.png](WIREFRAME_DYNAMIC_PLAYFIELD.png)
- 추가 viewport/state PNG는 `mockups/approved-v5/`에 둔다.

HTML의 screen selector로 Main, Ground, Planetary, Galactic, Black Hole Phase, Pause, FX를 비교한다. 이는 visual/reference artifact이며 Godot runtime evidence가 아니다.

## 8. Implementation Handoff

- S2-G1: 최신 15종 Resource를 재검증하되 기존 Lv14 `Black Hole`/`black_hole`은 유지.
- S2-G5: 2인자 Merge FX.
- S3-G6: Stage 이름 + 세로 5칸 progressive HUD.
- S5-G1/G2/G4: non-contiguous chain, Stage profile, Initial/L1/L2.
- S8-G1/G4/G5: Black Hole phase trigger/force, logical activation, L3 presentation.

Pause의 Stage Restart 계약은 이번 V5에서 변경하지 않는다.
