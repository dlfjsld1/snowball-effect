# 02. Frame and Stage World

Status: APPROVED PLAN — Rect2 seed values remain tuning inputs  
Primary Owner: Presentation  
Cross-lane dependency: Content/Systems, Core, Integration

## 1. Core Visual Contract

Stage를 Clear하면 프레임 폭이 한 단계 넓어진다. 프레임 장식만 커지는 것이 아니라 그 안쪽의 표시 영역과 다음 Stage에서 사용되는 논리 `Play Field`가 같은 목표 크기로 넓어진다.

- 변화 축: 현재 계획은 **폭만 증가**한다. 높이 변화는 별도 결정 전까지 제외한다.
- 기준점: 화면 중심을 기준으로 좌우 대칭.
- 경계: 좌·우·상단 반사 경계, 하단 열린 Cashout 경계를 유지한다.
- 전환 조건: Initial→L1과 L1→L2는 Top Ball/Clear Lock → Final Settlement 뒤에 시작한다. L2→L3는 Galactic 안에서 Black Hole 기믹이 발동할 때 시작한다.
- gameplay: Shift 동안 simulation, spawn, timer, input effect를 정지한다.

## 2. Frame Level Naming

| 진행 | 표시 이름 | 기존 Stage anchor | `play_field_rect` seed | 상태 |
|---|---|---|---|---|
| 시작 | Initial Frame | Ground | `Rect2(500, 0, 600, 900)` | TUNING |
| 첫 Clear 후 | Frame Level 1 | Planetary | `Rect2(420, 0, 760, 900)` | TUNING |
| 둘째 Clear 후 | Frame Level 2 | Galactic | `Rect2(340, 0, 920, 900)` | TUNING |
| Black Hole 발동 | Frame Level 3 | Galactic — Black Hole Phase | `Rect2(260, 0, 1080, 900)` | TUNING |

폭은 1600×900 authoring viewport의 logical unit 기준이다. v1은 `Ground/Planetary/Galactic` 3개 Stage를 사용한다. L3는 별도 Stage나 Final Result 배경이 아니라 Black Hole 기믹이 활성화된 Galactic의 gameplay profile이다. 각 Stage의 구체적인 그림과 재질은 재설계할 수 있다.

## 3. One Source of Truth Proposal

Presentation과 Core가 각각 폭 상수를 가지면 시각 프레임과 실제 충돌 경계가 어긋난다. 구현 전 다음 계약을 `StageDefinition`과 Integration contract에 반영한다.

### Canonical stage data — proposed, not implemented

Authoritative owner는 Content/Systems이고 위치는 `resources/stages/**`다. 별도 폭 상수를 추가하지 않고 `StagePlayFieldProfile` Resource를 StageDefinition이 read-only로 참조한다.

| Field | Godot type | 소비자 | 의미 |
|---|---|---|---|
| `profile_id` | `StringName` | all lanes | Initial/L1/L2/L3 correlation key |
| `active_rect` | `Rect2` | Core, Integration, Presentation | Canvas/world 좌표계의 authoritative target |
| `frame_visual_key` | `StringName` | Presentation | 프레임 art/animation variant |
| `background_key` | `StringName` | Presentation | Stage World variant |

`StageDefinition.play_field_profile`은 Stage 진입 profile을 가리킨다. Galactic은 추가로 `black_hole_phase_profile`을 가리키며 두 필드 모두 같은 `StagePlayFieldProfile` schema를 사용한다. `active_rect`는 1600×900 logical Canvas/world 좌표를 사용한다. 현재 height는 `900`, top은 `y = 0`, open Cashout line은 `rect.end.y = 900`으로 유지한다. 폭 변화는 `x = (1600 - width) / 2`로 center x `800`을 보존한다. 별도의 `width`, visual inset, collision Rect를 authoritative 값으로 병행하지 않는다.

HUD safe inset과 side/top/hybrid 선택은 gameplay Stage data에 넣지 않는다. 현재 `play_field_rect`는 full-height active physics 영역이므로 persistent HUD는 Rect 밖 side gutter에만 둔다. top reserved band가 필요하면 D2 HUD와 D3 Rect를 공동 재승인하고 Core bounds schema부터 바꾼다. Presentation-only inset으로 physics safety를 주장하지 않는다.

현재 문서의 네 `Rect2`는 schema를 고정하기 위한 seed다. L3 Black Hole profile도 Core와 Presentation이 같은 `active_rect`를 활성화하며, transition 완료 뒤 spawn·timer·input을 재개한다. 실제 Resource field 추가와 값 확정은 S5/S8 Goal 계약에서 수행한다.

## 4. Visual and Logical Synchronization

논리 physics 경계를 매 frame 보간할 필요는 없다. Shift 동안 gameplay가 정지하므로 다음 방식이 안전하다.

1. Integration이 current/target `StagePlayFieldProfile`, current `run_epoch`, unique `shift_id`를 확정한다.
2. Integration이 Core의 `prepare_play_field_rect(target_rect: Rect2, run_epoch: int, shift_id: int)`를 호출한다.
3. Integration이 Presentation의 `StageWorldPresenter.play_stage_shift(run_epoch: int, shift_id: int, from_rect: Rect2, to_rect: Rect2, frame_visual_key: StringName, background_key: StringName)`를 호출한다.
4. `StageWorldPresenter`는 Frame, 표시용 Play Field mask, Stage World child track을 병렬 실행하고 필수 track이 모두 끝난 뒤 `stage_shift_presentation_finished(run_epoch: int, shift_id: int)`를 정확히 한 번 보낸다.
5. Integration은 같은 `run_epoch`와 correlation ID를 확인한 뒤 Core의 prepared Rect를 활성화한다. L1/L2는 다음 Stage activation과 같은 제어 구간에 묶고, L3는 같은 Galactic의 Black Hole phase activation에 묶는다.
6. Core의 `get_play_field_rect() -> Rect2`가 target과 일치하는지 확인한다. L1/L2와 L3 모두 해당 transition이 끝나면 gameplay를 재개한다. L3에서는 두 Black Hole 접촉 뒤 별도 Shift 없이 finale와 타이틀로 이동한다.

따라서 플레이어가 보는 Frame/Field 전환과 실제 다음 Stage의 logical rect는 같은 target data를 사용한다. animation 중 physics collision을 보간하는 추가 복잡도는 만들지 않는다. Step 4와 5 사이에는 input/simulation이 재개되지 않으므로 visual target과 아직 활성화되지 않은 Core target을 플레이어가 조작하는 순간은 없다.

위 API와 signal은 canonical **proposal**이다. 구현 전에 `docs/team/INTEGRATION_CONTRACTS.md`와 S5 Goal에 같은 signature, producer/consumer, once-only/reset 규칙을 복사해 승인해야 한다.

### Restart / Retry invalidation

- Integration은 Stage Restart/full Retry 때 새 `run_epoch`를 발급하고 `StageWorldPresenter.reset_presentation(new_epoch)`를 호출한다.
- Presenter는 이전 epoch의 Tween, child completion, queued callback을 취소하거나 무효화한다.
- Presenter와 Integration은 양쪽 모두 stale `run_epoch` 또는 이미 완료된 `(run_epoch, shift_id)`를 거부한다.
- reset 도중 늦게 도착한 animation callback은 새 Shift의 완료로 재사용하지 않는다.

## 5. Scale Shift Beats

| Beat | 목적 | 시각 행동 | Gameplay 상태 |
|---:|---|---|---|
| 1. Clear Lock | 성공을 즉시 이해 | 최고 Ball 강조, 주변 contrast 감쇠 | clear 잠금 |
| 2. Settlement | 정산이 끝났음을 이해 | score/count가 source에서 target으로 이동 | 정지 |
| 3. Frame Charge | 확장 예고 | 좌우 rail, latch, meter 점등 | 정지 |
| 4. Expand | 핵심 변화 | Frame과 내부 mask가 동시에 좌우 확장 | 정지 |
| 5. World Reveal | 다음 규모 노출 | 새 StageWorld가 넓어진 gutter/behind-frame에 등장 | 정지 |
| 6. HUD Reflow | 정보 안정화 | fixed-width side housing을 Field edge와 함께 이동; compact label은 필요할 때만 적용 | 정지 |
| 7. Control Return | 다음 Stage 시작 | 강조 감소, control cue | 재개 |

총 길이는 아직 미확정이다. S6-G2가 요구하는 중요 연출 1초 미만 계약과 실제 Shift의 필요 길이를 함께 검토한다. 긴 cinematic보다 명료한 7-beat rhythm을 우선한다.

## 6. Frame Construction Language

### Initial Frame

- 가장 좁고 압축된 캐비닛.
- 굵은 상·좌·우 경계가 Play Field를 명확히 감싼다.
- 좌우 bezel은 1600×900에서 약 190px 고정 폭 시드로 HUD를 수용한다.
- 짙은 청록 에나멜 도장과 노출 금속 edge가 기본이며 녹은 체결부의 작은 wear로만 남긴다.

### Frame Level 1

- 첫 확장임을 한눈에 알 수 있도록 rail 한 쌍이 바깥으로 이동한다.
- rail/bezel 폭은 Initial과 같고 Field 확장 거리만큼 좌우 대칭 translate한다.
- 이전 프레임의 clamp/bolt 흔적을 남겨 성장 이력을 보여준다.
- 새로운 StageWorld 요소는 한 계층만 추가한다.

### Frame Level 2

- 폭 증가와 함께 기계의 중심 구조가 좌우 wing으로 분리된다.
- 고정 폭 side housing은 더 바깥으로 이동하고 내부 HUD 계층은 유지한다.
- 장식보다 내부 공간 증가가 먼저 읽히도록 frame detail contrast를 억제한다.

### Frame Level 3

- 화면 대부분을 Play Field가 차지하지만 외곽 machine silhouette은 남긴다.
- Black Hole 기믹의 발동과 도달한 최대 gameplay 규모를 크기·재질·motion cadence로 표현한다.
- 프레임이 사라진 것처럼 보이지 않도록 최소 housing thickness와 corner anchors를 유지한다.

V4의 핵심은 “화면 가장자리에 붙은 넓은 frame 안에서 범위만 조절”하는 방식이 아니다. 중앙에 놓인 완성된 cabinet rig가 시작점이며, Shift 때 실제 Play Field와 그 양쪽의 얇은 housing이 함께 열려야 한다. 자세한 재질·구성은 [09_APPROVED_VISUAL_DIRECTION_V4.md](09_APPROVED_VISUAL_DIRECTION_V4.md)를 따른다.

## 7. Stage World Direction

Stage World는 “밝은 풍경 네 장”의 교체가 아니라 동일한 arcade machine이 다른 규모의 우주를 수용하도록 변형되는 배경 체계로 본다.

- Base layer: 공통 machine interior/void.
- Stage identity layer: Stage별 horizon, orbit, grid, distortion 등 한 가지 dominant motif.
- Scale history layer: 이전 Stage의 흔적을 작은 단위나 panel marking으로 남길 수 있다.
- Event layer: Shift, Clear, failure 동안만 나타나는 transient lighting.

v1의 Ground/Planetary/Galactic progression을 사용하되 meadow·우주사진·검은 소용돌이 같은 직설적 배경에 묶이지 않는다. 이동 Black Hole 맵 기믹은 별도 네 번째 Stage가 아니라 Galactic L3 gameplay phase의 dominant map motif로 사용한다. Lv14 Black Hole Ball은 별도 gameplay object로 존재한다.

## 8. Balance and Input Dependencies

폭 변화는 시각 문제만이 아니다. 다음 항목을 같은 profile 검증에서 다룬다.

- ball spawn x-range와 초기 분포.
- active ball density와 공 반지름/단계 구성.
- Paddle 폭, 이동 속도, clamp bounds.
- mouse/global 좌표를 logical Play Field로 변환하는 mapping.
- 좌·우 반사 경계 위치와 collision tolerance.
- Cashout width와 화면 하단 cue.
- 카메라/viewport scaling과 resize 후 input consistency.

Presentation은 값을 정하지 않지만, Frame seed 폭을 확정하기 전에 Core/Content의 측정 결과를 받아야 한다.

## 9. Cross-lane Handoff

| Lane | 요청 |
|---|---|
| Content/Systems | Stage/Black Hole phase profile별 authoritative `active_rect`와 visual keys를 data로 제공 |
| Core | target rect를 spawn/boundary/paddle에 일관되게 적용하는 API 제공 |
| Presentation | current/target profile 기반 Shift animation과 완료 signal 제공 |
| Integration | Settlement 이후 순서, profile activation, signal once-only 보장 |

`project.godot`, `main.tscn`, `GameManager`, `StageManager`는 Integration-owned이므로 Presentation이 직접 wiring하지 않는다.

## 10. Verification

- 비교판에서 Initial/L1/L2/L3의 내부 폭 차이가 label 없이도 구별된다.
- 각 단계에서 Frame 안쪽 표시 폭과 Core debug logical rect가 일치한다.
- Shift 중 공·timer·spawn이 움직이지 않는다.
- animation finished signal은 한 번만 발생한다.
- Shift의 각 beat에서 Restart를 요청해도 이전 epoch의 완료 signal이 새 Run에 반영되지 않는다.
- resize 후 visual frame, logical collision, Paddle clamp, mouse position이 같은 rect를 사용한다.
- 새 Stage 시작 첫 tick에 Ball이 경계 바깥에 생성되지 않는다.
- Black Hole Phase L3에서는 target Rect 활성화 뒤 spawn·timer·input이 같은 Galactic gameplay로 재개된다.

## 11. Intentional Exclusions

- 최종 폭 값 확정.
- Stage profile Resource 구현.
- StageManager wiring.
- 개별 Stage illustration 완성.
