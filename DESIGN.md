# Snowball Effect Design Source of Truth

Status: APPROVED VISUAL DIRECTION — runtime implementation remains Goal-gated  
Approved by: User  
Approved on: 2026-08-12
Owner: Presentation

이 파일은 Snowball Effect의 디자인 진입점이다. 상세 명세는 [docs/design/README.md](docs/design/README.md), 현재 채택한 목업과 제작 기준은 [docs/design/10_APPROVED_VISUAL_DIRECTION_V5.md](docs/design/10_APPROVED_VISUAL_DIRECTION_V5.md)를 따른다. 게임 규칙과 기술 계약이 충돌하면 저장소의 `AGENTS.md` 문서 우선순위를 적용한다.

## Product Context

Snowball Effect는 공을 합쳐 더 큰 공을 만들고, Ground/Planetary Clear와 Galactic의 Black Hole 기믹 발동에서 아케이드 기계와 실제 Play Field가 함께 확장되는 픽셀 아케이드 게임이다. 플레이어가 기억해야 할 장면은 중앙축을 유지한 캐비닛이 좌우로 열리며 더 큰 우주를 수용하는 순간이다.

## Aesthetic

채택 방향은 **Frozen Enamel Arcade**다.

- 90년대 픽셀 아케이드와 어두운 배경, 고대비 gameplay object를 유지한다.
- 주재료는 짙은 청록 에나멜 도장 강판과 노출 금속이다.
- 마모와 녹은 모서리와 체결부의 작은 흔적으로만 사용한다.
- 성애·고드름·쌓인 눈은 Main Screen의 마키와 캐비닛 외곽에 집중한다.
- Play Field 내부는 깨끗하게 유지해 Ball, Paddle, Cashout cue와 FX를 우선한다.

## Typography

- Display/short command: `Silkscreen` 방향.
- Korean UI: `Galmuri14` 방향.
- Numeric/instrument data: tabular numeral이 있는 `IBM Plex Mono` 방향.
- 위 글꼴은 승인된 스타일 기준이며, runtime 도입 전 라이선스와 Web glyph coverage를 검증한다.

## Color

| Token | Seed | Role |
|---|---|---|
| `void_950` | `#050709` | 우주·전체 바탕 |
| `enamel_deep` | `#172225` | 캐비닛 그림자·깊은 패널 |
| `enamel` | `#223033` | 기본 도장 강판 |
| `enamel_light` | `#344345` | 융기·활성 패널 |
| `bare_steel` | `#8F9992` | 노출 금속·기능 경계 |
| `oxide_trace` | `#456F69` | 절제된 산화 흔적 |
| `ice` | `#C9F3F5` | 성애·냉기 강조 |
| `paper_050` | `#F4F5E8` | 본문·최고 대비 |
| `signal_cyan` | `#48DDEC` | 시스템·새 결과 경계 |
| `score_amber` | `#FFC857` | 점수·주의 |
| `merge_pink` | `#FF5B9F` | Merge 계열 |
| `hazard_red` | `#FF554D` | 위험·실패 |

색만으로 상태를 전달하지 않는다. silhouette, label, outline pattern, motion 중 하나 이상을 함께 사용한다.

## Layout

- Authoring canvas: `1600×900`.
- 중앙 x축은 모든 Frame profile에서 유지한다.
- Play Field seed 폭은 `600 → 760 → 920 → 1080`이며 마지막 `1080`은 Galactic의 Black Hole Phase gameplay profile이다.
- 좌우 HUD/캐비닛 베젤은 1600×900에서 약 `190px`의 고정 폭 시드로 설계한다.
- Stage가 넘어가면 베젤 폭을 늘리지 않고, Play Field의 좌우 경계와 함께 같은 거리만큼 바깥으로 이동한다.
- 목업 HTML의 `%` 값은 비교판 구성값일 뿐 runtime physics 상수가 아니다.

## HUD

- `Ground`/`Planetary`/`Galactic` Stage 이름을 지속 표시한다.
- 현재 Stage 공 5종은 왼쪽 베젤에 세로로 배치한다.
- Stage 진입 시 첫 공만 표시하고 새 공을 처음 만들 때 다음 아이콘과 이름을 공개한다.
- 미발견 공은 이름·아이콘으로 미리 노출하지 않는다.

## Motion

- Merge: 안쪽 압축 뒤 원형 bloom.
- Cashout: 아래 방향 이탈과 흡수.
- Item Box break: 바깥쪽 파편과 중앙 item reveal.
- Score milestone: gameplay를 멈추지 않는 계수기 lock, 측면 lamp, 금속 stamp.
- Scale Shift: 중앙 고정, Frame과 표시용 Field의 대칭 확장, world reveal, HUD 안정화 순서.
- Pause에서는 gameplay motion과 gameplay FX를 동결한다.

## Decision Log

- 2026-08-11: V4 목업을 제작 기준으로 채택했다.
- 2026-08-12: V5 정정으로 Black Hole을 Galactic 내부 최종 국면 기믹으로 확정하고, L3를 gameplay profile로 변경했다.
- 2026-08-12: Lv14 Ball은 `Black Hole`로 확정했다. 동일 이름의 Lv14 BallDefinition과 Galactic의 이동 Black Hole 맵 기믹은 서로 다른 gameplay entity로 구분하고, HUD에는 Stage 이름과 세로 5칸 progressive genealogy를 사용한다.
- 넓은 고정 side frame을 폐기하고, 얇은 고정 폭 베젤이 Play Field와 함께 바깥으로 이동하는 구조를 채택했다.
- “고철”은 형태와 제작 흔적으로 표현하되 녹을 주재료로 사용하지 않는다.
- Main은 우주 공간의 동결된 레트로 캐비닛, Pause는 에나멜 maintenance hatch로 표현한다.
- Merge, Item Box break, Score Milestone의 FX 문법을 채택했다.
- Merge 숫자 popup은 authoritative amount event가 생기기 전까지 목업 fixture이며 runtime 기본안은 ring/burst와 비점수 label이다.

## Implementation Boundary

이 승인 자체는 Godot runtime 구현 승인이 아니다. Scene, Script, Resource, asset import와 Goal 상태는 해당 Goal의 Owner, Owned Files, Integration Point, Dependencies, Verification이 승인된 뒤에만 변경한다.
