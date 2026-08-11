# 01. Screen and HUD

Status: APPROVED PLAN — runtime payload/signals remain Goal-gated  
Owner: Presentation  
Runtime ownership note: HUD는 Presentation-owned, Pause/Main/Settings runtime은 Content/Systems-owned이며 Integration이 상태 전환을 연결한다.

## 1. Base Screen Model

- Authoring viewport: 1600×900, 16:9.
- 중심: 세로형 `Play Field`.
- 외곽: Frame과 Stage World/machine panels.
- persistent HUD는 모든 Frame profile에서 authoritative `play_field_rect` 밖 좌우 gutter에 둔다.
- 1600×900 V4 기준 side housing은 약 190px 고정 폭 시드이며, field-facing edge가 `play_field_rect`의 좌우 edge를 따른다.
- 현재 `play_field_rect`는 `y=0, height=900`의 full-height physics 영역이므로 persistent top rail을 두지 않는다.
- Frame profile은 Stage 진행으로만 바뀌며 브라우저 viewport 크기로 바뀌지 않는다.
- HUD reflow가 Frame 또는 논리 Play Field 크기를 바꾸지 않는다.

## 2. HUD Information Contract v1

플레이 중 항상 표시할 정보는 다음으로 확정한다.

| 정보 | 우선순위 | 표시 규칙 | Authoritative source |
|---|---:|---|---|
| `stage_time_left` | 1 | 항상 표시, 10초 미만 warning state | Core Stage runtime |
| `stage_score / clear_score` | 1 | Stage Score와 Target을 한 묶음으로 크게 표시 | Core score ledger + StageDefinition |
| `ball_progression[]` | 2 | 현재 Stage의 4~5종을 낮은 단계부터 compact icon strip으로 표시 | StageDefinition + BallCatalog |
| `run_score` | 2 | Stage Score보다 작고 낮은 대비로 항상 표시 | Core score ledger |
| `active_effects[]` | 2 | 0개면 숨김, 활성 효과마다 남은 시간 표시 | Optional Item/Effect system |
| Pause action | 3 | 작은 고정 utility button과 `Esc` cue | Content UI request |

Stage 이름·index는 Stage 시작/Shift의 transient identity로 보여줄 수 있지만 persistent HUD 필수 항목은 아니다. Ball count와 최고 Ball은 debug/result 정보이며 v1 gameplay HUD에서 제외한다.

## 3. HUD Hierarchy and Placement

### Left — immediate decision panel

위에서 아래 순서:

1. Time.
2. Stage Score / Target.
3. Current Stage Ball Progression.
4. Run Score.

Time과 Stage Score/Target은 같은 1차 계층이지만 역할을 구분한다. Time은 압박, Score/Target은 현재 목표다. Ball Progression은 Merge 결과를 화면을 떠나지 않고 확인하는 compact read-only strip이며, Run Score는 누적 성취로 읽히되 현재 Stage 판단보다 먼저 튀지 않는다.

### Right — active state panel

위에서 아래 순서:

1. Active Effect Strip.
2. Pause button / `Esc` cue.

Pause는 gameplay action보다 낮은 대비의 utility control로 유지한다. 오른쪽 panel 전체를 버튼처럼 보이게 만들지 않는다.

## 4. Active Effect Strip

- 활성 효과 0개: housing까지 접고 빈 panel을 남기지 않는다.
- 1개: 아이콘, 짧은 이름, 남은 시간 bar/숫자를 펼친다.
- 2~3개: 아이콘과 남은 시간 중심의 compact row/stack으로 전환한다.
- 같은 효과 재획득: 새 slot을 만들지 않고 authoritative duration 갱신을 받은 뒤 해당 slot만 짧게 pulse한다.
- 다른 효과는 현재 계약대로 동시에 유지할 수 있고 각 timer를 독립적으로 표시한다.
- 색 외에 icon silhouette, border pattern, timer depletion을 함께 사용한다.
- 데이터 모델은 가변 목록이지만 v1 layout verification은 최대 3개 동시 활성 기준이다. 아이템 추가로 4개 이상 동시 활성 가능성이 생기면 별도 HUD capacity review를 통과한다.

## 5. Proposed Read-only View Model

구현 전 S3/S7 Goal과 Integration contract에 동등한 payload를 확정한다.

```text
HUDViewState
- run_epoch: int
- view_revision: int
- stage_time_left: float
- stage_score: float
- clear_score: float
- run_score: float
- ball_progression: Array[BallProgressionEntry]
- active_effects: Array[ActiveEffectView]

BallProgressionEntry
- ball_id: StringName
- display_name: String
- icon_key: StringName
- is_stage_top: bool

ActiveEffectView
- effect_id: StringName
- display_name: String
- icon_key: StringName
- remaining_seconds: float
- duration_seconds: float
- refresh_sequence: int
```

`HUDViewState`, `BallProgressionEntry`, `ActiveEffectView`는 runtime 저장용 Resource나 문자열 key `Dictionary`가 아니라 typed `RefCounted` read-only DTO로 구현한다. `run_epoch`가 이전이면 snapshot 전체를 거부하고 같은 epoch에서는 증가한 `view_revision`만 반영한다. `refresh_sequence`는 같은 효과 재획득을 UI가 한 번만 pulse하기 위한 correlation 값이다.

HUD는 시간·점수·효과를 계산하거나 감소시키지 않고 authoritative snapshot/event만 표시한다. Ball Progression은 전달된 순서를 그대로 그리며 다음 Merge 결과를 계산하지 않는다. 숫자는 S2-G4 `format_score(value)`를 사용한다. 점수·Pause·effect add/remove·Stage 변경은 즉시 갱신하고, 연속적인 timer/effect countdown snapshot은 producer에서 최대 10Hz로 coalesce한다. HUD는 같은 text/icon 값이면 Control 속성을 다시 쓰지 않는다.

## 6. Reflow Rules

- Initial/L1에서는 이름과 label을 충분히 표시한다.
- L2에서는 label을 줄이고 숫자와 icon의 폭을 우선 보존한다.
- L3 terminal fixture에서는 Stage Score/Target, Time, Ball Progression, effect icon/timer, Pause hit target의 frozen backdrop을 보존하고 장식 line과 긴 이름을 축소한다. L3 gameplay 상태를 만들지는 않는다.
- score formatter의 suffix/scientific boundary, NaN/Infinity fallback, 1~5자리 이상의 time overflow를 stress test한다.
- effect strip 변화가 Stage Score panel의 위치나 Play Field edge를 밀지 않는다.
- Frame 전환 중 `HUD REFLOW` beat에서 side housing은 폭을 보간하지 않고 `play_field_rect` edge와 함께 좌우 대칭으로 이동한다. 내부 stacking은 유지하고, responsive compact mode에서만 label 축약을 허용한다.
- transient Merge/Cashout/Item popup은 persistent HUD housing을 재배치하지 않는다.

## 7. State Coverage

| State | HUD behavior |
|---|---|
| Playing | 모든 authoritative 값 표시 |
| Time pressure | Time의 shape/pulse 변경, 색만으로 경고하지 않음 |
| Item refreshed | 해당 effect slot만 짧은 refresh pulse |
| Paused | 값은 동결하고 전체 HUD 대비를 낮춤; Pause modal이 focus 소유 |
| Clear locked / Settling | 입력 utility 비활성, 확정 점수 event만 표시 |
| Shifting | 값 동결, fixed-width side housing 이동, 다음 Stage 시작 전에 갱신 |
| Focus lost | 자동 Pause 상태 표시; 복귀만으로 재개하지 않음 |
| Audio locked | 첫 사용자 입력 전 작은 비차단 안내 가능 |

## 8. Responsive Web Behavior

| 환경 | 기본 전략 | 확인 항목 |
|---|---|---|
| 1920×1080 이상 | 16:9 uniform scale, 주변 void 허용 | text가 과도하게 작아지지 않음 |
| 1600×900 | authoring 기준 | 모든 keyframe/evidence 기준 |
| 1366×768 | proportional scale | HUD 자릿수, fractional pixel |
| 1280×720 | compact L3 density | timer, icon, focus hit target |
| 비정상 aspect | 16:9 유지, safe letterbox | mouse mapping, focus, crop 없음 |

디자인 지원 기준은 desktop landscape 1280×720 이상이다. 1024×768은 engine/browser smoke 전용이고 portrait/mobile은 이번 release 디자인 지원 범위 밖이다.

## 9. Verification

- Initial/L1/L2/L3에서 HUD가 active `play_field_rect`, Ball, Paddle, Cashout cue를 가리지 않는다.
- Initial/L1/L2/L3에서 좌우 housing의 폭이 같고 중심축에서 같은 거리만큼 이동한다.
- `stage_score=0`, Target 직전/초과, 매우 큰 Run Score에서 panel width가 흔들리지 않는다.
- Time `0`, `9`, `999`, `1000`, `9999`와 overflow fallback을 확인한다.
- active effect 0/1/3개, 긴 이름, 동시 refresh, 서로 다른 expiry를 확인한다.
- Ball Progression 4/5개, 긴 이름, top marker와 Stage 교체를 확인한다.
- 1280×720 terminal L3 backdrop에서도 Stage Score/Target과 Time이 첫 시선 계층으로 남는다.
- 같은 값 snapshot 반복 시 Label/Icon layout 갱신이 없고 연속 timer 갱신이 10Hz를 넘지 않는다.
- focus·warning·rarity를 grayscale에서 shape와 pattern으로 구분한다.
- source가 없는 placeholder가 gameplay state를 추론하거나 계산하지 않는다.

## 10. Intentional Exclusions

- Runtime signal binding과 scene/script 구현.
- 아이템 4개 이상 동시 활성화용 최종 layout.
- Stage 이름·최고 Ball·Ball count의 persistent HUD 추가. 현재 Stage Ball Progression은 이 제외 항목에 포함되지 않는다.
- portrait/mobile 전용 UI.
