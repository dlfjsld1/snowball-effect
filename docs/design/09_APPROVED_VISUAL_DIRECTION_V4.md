# 09. Approved Visual Direction V4

Status: APPROVED VISUAL DIRECTION — production and runtime remain Goal-gated  
Approved by: User  
Approved on: 2026-08-11  
Owner: Presentation  
Working name: **Frozen Enamel Arcade / Slim Expanding Cabinet + Gameplay FX**

## 1. Adoption Statement

2026-08-11 사용자는 V4 목업을 현재 디자인 제작의 기준으로 채택했다. 이전 문서의 구조·게임 계약은 유지하되, 시각 재질과 Frame 구성, Main/Pause 표현, 핵심 FX는 이 문서가 우선한다.

채택 범위는 다음과 같다.

- 어두운 우주 공간의 동결된 90년대 픽셀 아케이드 캐비닛.
- 녹보다 짙은 청록 에나멜 도장 강판과 노출 금속이 우선인 재질.
- 좁은 좌우 베젤이 중앙 Play Field의 확장과 함께 대칭으로 바깥 이동하는 구조.
- Main Screen의 서리 낀 마키, 고드름, 쌓인 눈과 `SNOWBALL EFFECT` 타이틀.
- Pause의 단일 maintenance hatch 패널.
- Merge, Item Box break, Score Milestone의 독립된 FX 문법.

채택이 runtime 수치, Core event payload, asset 경로 소유권 또는 Goal 상태를 자동으로 확정하지는 않는다.

## 2. Canonical Mockup Artifact

디자인 상담 원본은 gstack project artifact 경로에 보존한다.

```text
~/.gstack/projects/snowball-effect/designs/design-system-20260811-v4/
├─ approved.json
├─ snowball-effect-slim-cabinet-fx-preview.html
├─ mockup-v4-01-gameplay-initial.png
├─ mockup-v4-02-gameplay-l1.png
├─ mockup-v4-03-gameplay-l2.png
├─ mockup-v4-04-fx-merge.png
├─ mockup-v4-05-fx-item-break.png
└─ mockup-v4-06-fx-score-milestone.png
```

HTML preview의 interactive state와 PNG는 visual reference다. 저장소에서 구현 계약을 판단할 때는 이 문서와 `00`~`08` 명세를 함께 사용한다.

## 3. Visual North Star

> 우주를 떠도는 오래된 아케이드 기계를 다시 켠다. 작은 공이 우주적 크기로 자랄 때, 화면 중앙은 그대로이고 기계와 실제 Play Field가 좌우로 열린다.

재질은 오래됐지만 방치된 폐기물처럼 보이면 안 된다. 표면의 대부분은 관리된 에나멜 도장이고, 노출 강철과 산화 흔적은 구조를 설명하는 작은 detail이다. 눈과 얼음은 브랜드의 기억점이지만 gameplay field를 흐리지 않는다.

## 4. Slim Expanding Cabinet

### Structural rule

- Authoring canvas는 `1600×900`, 고정 중심축은 `x=800`이다.
- 좌우 side housing/HUD bezel은 `약 190px` 고정 폭을 제작 시드로 사용한다.
- 각 베젤의 Play Field 쪽 edge는 authoritative `active_rect`의 좌우 edge를 따른다.
- Stage Shift에서 베젤 자체를 늘리지 않는다. 왼쪽은 왼쪽으로, 오른쪽은 오른쪽으로 같은 거리만큼 translate한다.
- 표시용 Play Field mask와 다음 Stage의 logical Play Field는 같은 target Rect를 사용한다.
- 상단 rail과 corner anchor는 새 폭을 연결해 “단순 전체화면”이 아니라 열린 캐비닛으로 보이게 한다.
- viewport가 좁을 때만 별도의 responsive compact rule을 사용하며, 이것이 Stage profile을 바꾸지는 않는다.

| Profile | Role | Active Rect seed | Center | Visual behavior |
|---|---|---|---:|---|
| Initial | Ground gameplay | `Rect2(500, 0, 600, 900)` | 800 | 가장 압축된 캐비닛 |
| L1 | Planetary gameplay | `Rect2(420, 0, 760, 900)` | 800 | 두 bezel이 80px씩 이동 |
| L2 | Galactic gameplay | `Rect2(340, 0, 920, 900)` | 800 | 두 bezel이 다시 80px씩 이동 |
| L3 | Final Result terminal | `Rect2(260, 0, 1080, 900)` | 800 | 외곽 anchor를 남긴 terminal profile |

위 수치는 tuning seed다. Core/Content 측정 뒤 값이 바뀌더라도 `고정 중심 + 고정 폭 bezel 이동 + Field 동시 확장` 원칙은 유지한다. V4 HTML의 `65%/75%/85.7%/96%` rig 값은 목업 비교를 위한 CSS 값이며 runtime contract가 아니다.

### HUD relation

- 왼쪽 bezel: Time, Stage Score/Target, Ball Progression, Run Score.
- 오른쪽 bezel: active effects, Pause.
- HUD panel 폭은 Stage Shift 중 보간해 넓히거나 줄이지 않는다.
- HUD는 bezel과 함께 이동하되, 정보 계층과 내부 padding은 유지한다.
- transient popup과 particles는 persistent HUD를 재배치하지 않는다.

## 5. Material and Branding

### Material hierarchy

1. Dark teal enamel — 캐비닛의 주재료.
2. Bare steel — corner, bolt, hinge, handle, 기능 edge.
3. Frost/ice — Main marquee와 외곽 brand accent.
4. Oxide/wear — 모서리의 제한된 흔적.
5. Rust — 면적을 차지하지 않는 극소량의 warm contrast.

### Main Screen

- 우주 공간에 독립적으로 놓인 cabinet 전체 실루엣을 보여준다.
- `SNOWBALL EFFECT`는 서리 낀 marquee 자체로 읽혀야 한다.
- 성애, 고드름, 쌓인 눈은 상단과 외곽에 집중한다.
- primary `START`와 secondary `SETTINGS`는 물리 control panel의 명확한 조작부로 표현한다.
- Ball/Paddle motif는 cabinet screen 안에서 미리 보여주되 title보다 강하지 않게 한다.

### Pause

- modern floating card 대신 한 장의 에나멜 maintenance hatch를 사용한다.
- hinge, handle, stamped label은 구조를 설명하되 action text와 focus outline을 침범하지 않는다.
- action 순서는 Resume, Restart Stage, Settings, Main Screen이다.
- 기본 focus는 Resume이며 destructive confirmation의 기본 focus는 Cancel이다.

## 6. Color and Type Tokens

| Token | Seed | Use |
|---|---|---|
| `void_950` | `#050709` | outer space |
| `enamel_deep` | `#172225` | deep housing |
| `enamel` | `#223033` | painted steel base |
| `enamel_light` | `#344345` | raised panel |
| `bare_steel` | `#8F9992` | hardware edge |
| `steel_dark` | `#4C5755` | hardware shadow |
| `oxide_trace` | `#456F69` | restrained wear |
| `ice` | `#C9F3F5` | frost and title accent |
| `paper_050` | `#F4F5E8` | primary text |
| `signal_cyan` | `#48DDEC` | system/result boundary |
| `score_amber` | `#FFC857` | score/attention |
| `merge_pink` | `#FF5B9F` | Merge family |
| `hazard_red` | `#FF554D` | pressure/failure |

- Display/command: Silkscreen style.
- Korean UI: Galmuri14 style.
- Numeric/data: IBM Plex Mono style with tabular numerals.
- Font files and licenses are still an asset-import gate, not part of this approval.

## 7. Approved Gameplay FX Studies

정확한 particle cap, concurrent count, aggregation threshold와 실제 duration은 S6-G1 성능 측정으로 조정할 수 있다. 아래 시간은 keyframe 제작 seed다.

### FX-01 — Compression Bloom / Merge / 700ms

| Beat | Seed timing | Visual |
|---|---:|---|
| Contact | 0–80ms | 접점 flash |
| Compress | 80–180ms | source 잔상이 안쪽으로 압축 |
| Bloom | 180–360ms | result silhouette + circular ring |
| Settle | 360–700ms | label과 잔광 정리 |

- `ball_merged(result_level, world_position)`만 있을 때는 position ring, tier burst, 비점수 level-up label만 사용한다.
- 목업의 `+0240`은 fixture다. authoritative `amount + world_position` event가 없으면 숫자 score popup을 구현하지 않는다.
- 두 source Ball의 수렴 animation은 source/result snapshot 계약이 생기기 전까지 runtime 기본안에서 제외한다.
- reduced recipe: screen shake 제거, ring 1개, 인식 label 유지.

### FX-02 — Salvage Burst / Item Box Break / 1000ms

| Beat | Seed timing | Visual |
|---|---:|---|
| Impact | 0–100ms | Ball 반사와 hit flash |
| Split | 100–220ms | 외피가 진행 반대 방향으로 분리 |
| Reveal | 220–450ms | 중앙 item symbol과 짧은 beam |
| Acquire | 450–1000ms | field edge label 뒤 HUD slot 연결 |

- 파편은 decorative particle이며 gameplay collision에 참여하지 않는다.
- Presentation은 authoritative break/item effect event를 표시하고 effect를 직접 활성화하지 않는다.
- reduced recipe: fragment 50% 감소, beam 정적, item name/duration 유지.

### FX-03 — Cabinet Score Lock / Score Milestone / 1200ms

| Beat | Seed timing | Visual |
|---|---:|---|
| Count | 0–120ms | 상단 계수기 증가 |
| Lamps | 120–450ms | 좌우 cabinet lamp chase |
| Stamp | 450–760ms | milestone 금속 stamp |
| Fade | 760–1200ms | gameplay를 가리지 않고 정리 |

- gameplay를 pause하지 않고 중앙 action area를 덮지 않는다.
- threshold와 current run score는 Content/Core의 authoritative data에서 받는다.
- `10K`는 fixture threshold이며 최종 목록은 Content tuning data로 분리한다.
- reduced recipe: lamp chase 제거, 정적 stamp를 약 900ms 유지.

Reduced recipe는 밀도 저하와 향후 접근성 설정의 제작 기준이다. v1에 사용자용 Reduced Effects 설정을 추가하는 승인은 아니며, 별도 Goal과 Owner가 필요하다.

## 8. Production Handoff

### Can start as design work

- Frame Initial/L1/L2/L3 orthographic comparison sheet.
- Main cabinet, HUD bezel, Pause hatch의 pixel asset breakdown.
- 세 FX의 keyframe/state sheet와 grayscale readability board.
- 720p/900p/1080p 축소 비교와 fixed-width bezel 검증.
- 15등급 Ball visual bible과 현재 Stage chain 적용 예시.

### Must wait for Goal/contract approval

- Godot scene/script/resource 생성 또는 수정.
- runtime asset import와 실제 renderer/scene wiring.
- numeric Merge score popup: authoritative amount event 필요.
- source Ball convergence: source/result snapshot 필요.
- StageWorld profile activation: S5 cross-lane profile/API/lock 필요.
- user-facing Reduced Effects setting: 별도 Content/Presentation/Integration Goal 필요.

## 9. Acceptance Checklist

- [ ] label 없이 Initial/L1/L2/L3의 Field 폭 차이가 읽힌다.
- [ ] 좌우 bezel의 폭은 같고 중심축에서 같은 거리만큼 이동한다.
- [ ] 좁은 화면에서도 Time, Score/Target, Ball Progression, effects, Pause가 잘리지 않는다.
- [ ] 녹이 캐비닛 주재료처럼 보이지 않는다.
- [ ] Main의 눈/얼음이 Play Field object보다 강하지 않다.
- [ ] Merge, Cashout, Item Break의 motion silhouette이 grayscale에서도 구별된다.
- [ ] 세 FX의 핵심 정보가 reduced recipe에서도 남는다.
- [ ] 1,000-ball fixture에서 FX degradation 뒤 gameplay object가 먼저 읽힌다.
- [ ] Pause focus와 action text가 hinge/wear texture에 가려지지 않는다.

이 체크리스트는 design review 기준이다. runtime 검증과 성능 수치는 각 Goal의 `Verification`과 `QUALITY_GATES.md`에 따라 별도 evidence로 남긴다.
