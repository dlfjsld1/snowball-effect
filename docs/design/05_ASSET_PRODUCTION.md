# 05. Asset Production

Status: APPROVED PLAN — runtime asset production requires Goal approval  
Owner: Presentation  
Purpose: 승인된 디자인을 Goal 순서에 맞춰 반복 제작 가능한 asset backlog로 바꾼다.

## 1. Production Principles

- 먼저 hierarchy와 state coverage를 검증하고 polish를 올린다.
- 한 Stage의 완성 에셋보다 네 Frame 단계의 구조 비교를 먼저 만든다.
- gameplay object, UI, Stage World, particle source를 분리한다.
- source 파일과 runtime export의 이름을 대응시킨다.
- 최종 asset을 만들기 전 grayscale proxy로 크기·여백·가독성을 통과한다.
- 구현 Goal이 열리기 전 runtime asset import나 scene wiring을 하지 않는다.

## 2. Priority Definitions

| Priority | 의미 | 완료 기준 |
|---|---|---|
| P0 | 다음 Goal을 시작하기 위한 계약/판독 자료 | 비교판 승인, 크기·상태·handoff 명시 |
| P1 | playable slice에 필요한 production asset | runtime 규격, state coverage, Web 확인 |
| P2 | 데모 품질과 정체성을 강화 | animation/polish, density budget 통과 |
| P3 | 시간 여유가 있을 때 추가 | 핵심 정보·성능에 영향 없음 |

## 3. P0 Design Assets

| Asset | Format | 목적 | Dependency |
|---|---|---|---|
| Visual north-star keyframe | PNG + source | 전체 hierarchy 승인 | Foundations |
| V4 Frozen Enamel board | HTML + PNG set | Main/Playing/Pause 재질·구성 기준 | 2026-08-11 채택 |
| Slim Frame profile comparison | PNG/HTML + source | fixed-width bezel + Initial/L1/L2/L3 폭 비교 | V4 승인, Rect 수치 tuning |
| Ball visual bible | PNG + source | 15등급 level/outline/density 규칙 | S2-G1 catalog + future Ball contract |
| Merge FX state sheet | PNG/storyboard | Compression Bloom T1/T2 계약 | V4 승인, numeric amount는 S2-G3 계약 대기 |
| HUD slot/reflow board | PNG + spec | Time·점수·effect strip layout | HUD Contract v1 |
| Item Box state sheet | PNG + source | 3 rarity, crack, break, miss 상태 | S7 contract rewrite |
| Item/Milestone FX sheet | PNG/storyboard | Salvage Burst와 Cabinet Score Lock | V4 승인, authoritative event 대기 |
| Main/Pause/Settings board | PNG + spec | focus·confirmation·return flow | S8/new UI Goals |
| Scale Shift storyboard | 7-beat PNG/animatic | S5 cross-lane 합의 | Stage profile proposal |
| Web resize board | PNG set | 720/768/900/1080p 검증 | layout draft |

P0는 모두 `docs/design/**`의 문서·비교판·source reference다. P0 제작은 runtime asset import나 renderer 변경을 승인하지 않는다.

채택 원본은 `~/.gstack/projects/snowball-effect/designs/design-system-20260811-v4/`에 보존한다. 저장소에는 이 디자인을 재현하는 명세와 검증 기준을 version control한다.

## 4. Runtime Asset Families — Planned

실제 생성은 각 Goal 승인 뒤 시작한다.

### Ball

- `assets/sprites/balls/**`
- `ball_lv00`~`ball_lv14` sprite/atlas, outline/mask, top-ball variant.
- optional source sheet는 versioned design source 위치를 팀과 합의한다.
- 현재 S2-G5 Owned Files에는 Ball asset/renderer가 없다. S2에서는 visual bible과 Merge FX만 만들고 production Ball sprite adoption은 별도 Goal 전까지 보류한다.
- Plan 1 runtime은 13종을 사용하지만 Red Giant와 Nebula export도 Plan 2 비교용으로 제작한다. 사용 여부와 asset 존재 여부를 같은 것으로 취급하지 않는다.

### Frame and Stage World

- `assets/backgrounds/**`
- `scenes/backgrounds/**`
- frame rail/corner/panel tile, stage motif layer, shift reveal layer.
- `S5-G4`를 시작하기 전에 `assets/backgrounds/**`와 필요한 Frame sprite 경로를 Goal Owned Files에 추가한다.

### UI

- `assets/sprites/ui/hud/**`
- `assets/sprites/ui/main/**`
- `assets/sprites/ui/pause/**`
- `assets/sprites/ui/settings/**`
- `assets/sprites/ui/items/**`
- panel tile, focus frame, icon, prompt glyph, number separators.
- runtime scene/script는 current ownership을 따른다.
- `S3-G6`에 `assets/sprites/ui/**`를 추가하지 않는다면 해당 Goal에서는 code-native Control/StyleBox와 proxy만 사용한다.

### Item Box

- `assets/sprites/items/item_box/**`
- Common/Rare/Epic base, three crack states, break fragments, hidden-content core, miss cue.
- content item icon은 `assets/sprites/ui/items/**`에서 공유하되 Ball sprite나 logical particle을 재사용하지 않는다.
- runtime scene/script/Resource 경로는 S7 Goal 재구성 뒤에만 만든다.

### FX

- `assets/particles/**`
- `assets/shaders/**`
- `scenes/effects/**`
- merge burst, cashout trail, clear lock, shift charge/reveal, result accent.

### Audio

- `assets/audio/**`는 Content/Systems-owned.
- Presentation은 event tier별 key/priority/polyphony 요구만 전달한다.

## 5. Goal Owned Files Gate

Team-level ownership과 Goal-level Owned Files는 다르다. 아래 runtime family를 만들기 전에 Goal 계약을 먼저 갱신한다.

| Runtime family | Current gap | Required Goal action |
|---|---|---|
| production Ball sprites | S2-G5가 renderer/ball assets를 소유하지 않음 | 별도 Presentation asset Goal + Core renderer consumer/Integration point 추가 |
| Merge particles | S2-G5는 effect scene 중심, raw asset 경로 없음 | 필요 시 S2-G5에 좁은 `assets/particles/merge/**` 추가 |
| HUD sprites/theme | S3-G6에 `assets/sprites/ui/**` 없음 | asset을 쓸 경우 해당 경로 추가; 아니면 code-native proxy로 제한 |
| Frame/Stage World exports | S5-G4에 `assets/backgrounds/**`가 없음 | S5-G4 Owned Files에 target asset 경로 추가 |
| Title/Result visual assets | S8-G3 runtime UI가 Content-owned | Presentation asset Goal을 추가하거나 Content가 제공받는 approved export 경로 명시 |
| Main/Pause/Settings visual assets | 현재 Pause Goal은 toolbar 수준이고 Settings/Main 확장 Goal 없음 | Content UI Goal과 Presentation asset handoff Goal을 분리하고 UI 하위 경로 명시 |
| Item Box/rarity/fragment assets | S7 Goal이 Paddle pickup과 effect만 소유 | Item Box Content/Core/Presentation Goal을 추가하고 `assets/sprites/items/item_box/**`와 effect 경로 명시 |

Goal이 갱신되지 않으면 Presentation은 `docs/design/**`의 spec/keyframe까지만 제공하고 runtime 경로에 파일을 쓰지 않는다.

## 6. Naming Proposal

```text
{family}_{stage-or-tier}_{role}_{state}_{size-or-variant}
```

예시:

- `frame_l2_corner_idle_01.png`
- `world_galactic_grid_far_01.png`
- `ball_lv05_core_idle_01.png`
- `fx_merge_t2_burst_01.png`
- `ui_focus_primary_active_01.png`
- `item_box_rare_crack_02.png`
- `fx_item-box_t3_break_epic_01.png`

이 이름은 제안이며 기존 repository naming convention과 충돌하면 Goal 착수 시 조정한다.

## 7. Pixel Asset Checklist

- 투명 배경 가장자리의 dark/white matte bleed가 없다.
- nearest filtering에서 의도한 outline이 유지된다.
- atlas frame 사이 padding이 sampling bleed를 막는다.
- 720p 축소에서 기능 detail이 사라지지 않는다.
- 동일 family의 texel density와 light direction이 일관된다.
- glow가 없는 base sprite만으로 silhouette이 읽힌다.
- pivot/origin 정보가 handoff sheet에 기록된다.

## 8. UI Asset Checklist

- 9-slice 또는 tile 가능한 panel은 corner/edge/center 영역이 표시된다.
- normal/focus/pressed/disabled 상태가 색 외 shape나 line 변화로 구분된다.
- 숫자 폭, colon, slash, plus/minus가 HUD stress string에서 정렬된다.
- icon은 16/24/32px 후보 크기에서 테스트한다.
- localized text가 들어올 가능성이 있는 panel은 baked text를 포함하지 않는다.
- active effect icon은 name label이 없어도 Magnet/Blizzard/Fire를 구분한다.
- Pause의 Resume/Restart Stage/Settings/Main과 confirmation의 Cancel focus가 720p에서 잘리지 않는다.

## 9. FX Asset Checklist

- effect가 사용하는 event tier와 maximum concurrent count가 기록된다.
- logical Ball sprite와 particle sprite를 재사용하지 않는다.
- effect bounds가 Frame 밖 Stage World를 불필요하게 덮지 않는다.
- pause/reset/shift 중 종료 또는 정리 정책이 있다.
- density degradation rule이 있다. 사용자용 reduced-effects variant는 별도 Goal 전까지 요구하지 않는다.
- Web texture/shader 지원 여부를 확인한다.
- Merge는 수렴, Cashout은 하강, Item Box break는 방사형 개방 silhouette을 유지한다.

## 10. Handoff Sheet per Asset Family

각 family는 다음 정보를 동반한다.

- Owner와 target Goal.
- source path / exported path.
- canvas size, pivot, frame rate, loop 여부.
- color token과 shader dependency.
- event/API key.
- expected maximum concurrent count.
- fallback/low-effects behavior.
- 필수 Ball, Item Box, HUD icon/font는 texture/font/visual key 누락 시에도 gameplay silhouette과 text가 사라지지 않는 code-native 또는 승인 proxy fallback을 가진다.
- missing visual key 경고는 key당 한 번만 기록하고 매 frame 반복하지 않는다.
- screenshots와 verification result.

## 11. Review Cadence

1. grayscale structure review.
2. palette/material review.
3. motion/state review.
4. Godot import/render review — 구현 승인 후.
5. Web density/performance review.

각 단계에서 한 family가 승인되기 전에 다음 family를 production polish까지 진행하지 않는다.

## 12. Intentional Exclusions

- 외부 asset 구매·다운로드.
- runtime import settings와 scene 생성.
- Audio asset 제작.
- 최종 naming rule의 팀 전체 강제.
