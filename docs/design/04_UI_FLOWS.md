# 04. UI Flows

Status: APPROVED PLAN — runtime state/API remains Goal-gated  
Visual specification owner: Presentation  
Runtime screen owner: Content/Systems  
State transition owner: Integration

## 1. Flow Map

```text
Main Screen
  ├─ Start → Playing
  └─ Settings → close → Main Screen

Playing
  ↔ Pause Modal
      ├─ Resume → Playing
      ├─ Restart Stage → Confirm/Cancel
      │    └─ Confirm → Stage entry snapshot restore → Playing
      ├─ Settings → close → Pause Modal
      └─ Main Screen → Confirm/Cancel
           └─ Confirm → end current Run → Main Screen
  ├─ Black Hole gimmick activation → Black Hole Phase Transition → Galactic Playing (L3)
  ├─ local Lv3/Lv4 first discovery → FIRST CONTACT CUT-IN → Playing
  └─ Time Up Lock → Final Settlement
       ├─ non-final + score clear → Congratulations pause → `Next Stage` → Scale Shift → Next Stage Playing
       ├─ non-final + score miss → Failure → Run Result
       └─ final Stage → Final Result

Result
  ├─ Retry Run → full reset → Stage 1 Playing
  └─ Main Screen → Main Screen
```

Presentation은 request/finished signal과 read-only snapshot만 사용하고 gameplay state를 직접 변경하지 않는다.

최상위 화면 상태는 Integration이 authoritative `UiFlowViewState`로 제공한다. Main/Pause/Settings/Confirm/Result view는 이 상태를 렌더하고 request signal만 보낸다. 각 view가 별도 gameplay/router state를 소유하지 않는다.

## 2. Main Screen

기존 Title과 별도 Main을 만들지 않고 `Title = Main Screen`으로 정의한다.

- 한 장의 포스터형 arcade cabinet composition을 사용하고 menu card를 여러 장 쌓지 않는다.
- 우주 공간에 독립적으로 놓인 짙은 청록 에나멜 cabinet 전체 실루엣을 사용한다.
- `SNOWBALL EFFECT`는 성애 낀 marquee로 표현하고 고드름·쌓인 눈은 상단과 외곽에 집중한다.
- 녹은 주재료가 아니라 노출 금속 edge의 제한된 마모 흔적이다.
- primary action: `START`.
- secondary action: `SETTINGS`.
- title/logo, compact controls/help, audio/focus 안내, credits/version을 위한 역할 영역을 둔다.
- 첫 화면에서 90년대 픽셀 아케이드, 어두운 machine, 고대비 Ball을 보여준다.
- Main Screen scene/script는 Content/Systems-owned이고 Presentation은 keyframe, assets, focus states를 전달한다.

## 3. Playing

- Frame, Play Field, Stage World가 첫 hierarchy다.
- HUD는 [01_SCREEN_AND_HUD.md](01_SCREEN_AND_HUD.md)의 v1 계약을 사용한다.
- transient feedback은 persistent HUD housing을 밀어내지 않는다.
- Pause button은 낮은 시각 강도의 utility control이며 `Esc`와 같은 request를 한 번만 보낸다.
- 브라우저 focus loss는 자동 Pause request를 만들지만 focus 복귀는 자동 Resume을 만들지 않는다.

## 4. Pause Modal

- simulation, spawn, Stage timer, active effect timer, Item Box, gameplay FX를 즉시 동결한다.
- gameplay 화면은 남기되 dim 처리해 입력 가능해 보이지 않게 한다.
- 중앙의 stepped-corner 에나멜 maintenance hatch 하나에 아래 순서로 배치한다. hinge·handle·stamped label은 action text와 focus outline을 침범하지 않는다.

```text
RESUME
RESTART STAGE
SETTINGS
MAIN SCREEN
```

- 기본 focus는 `RESUME`.
- `Esc`는 Pause 진입 전이면 Pause, Pause modal 안에서는 Resume으로 동작한다.
- Tab/arrow/controller navigation을 panel 안에 가두고 뒤의 gameplay control은 focus를 받지 않는다.
- Settings에서 돌아오면 Pause 상태를 유지하고 이전 선택에 focus를 복원한다.

### Destructive confirmations

- `RESTART STAGE`: “현재 스테이지의 점수와 진행을 되돌립니다.” 전용 확인.
- `MAIN SCREEN`: “현재 런을 종료하고 메인 화면으로 돌아갑니다.” 전용 확인.
- 두 확인 모두 기본 focus는 `CANCEL`이고 `Esc`도 cancel이다.
- confirm signal은 button/key repeat에도 한 번만 발행한다.

## 5. Stage Restart Contract

Pause의 Restart는 Result의 full Retry와 다르다. UI signal 이름을 `restart_stage_requested`로 고정하고 `retry_requested`와 혼용하지 않는다.

Stage entry 시 Integration/Core가 다음 snapshot을 보관한다.

```text
StageRestartSnapshot
- stage_index / StageDefinition identity
- stage_entry_run_score
- stage_entry_run_statistics
- stage_entry_highest_ball/statistics
- active_effects and remaining duration at entry
- stage RNG/spawn seed state required for reproducible reset
```

Restart confirm 뒤에는 다음을 원자적으로 수행한다.

- `stage_score = 0`.
- `run_score = stage_entry_run_score`.
- Stage에서 증가한 merge/cashout/item/time/statistics를 snapshot으로 rollback.
- `stage_time = StageDefinition.base_time`.
- Ball arrays/free slots, Settlement/Shift locks, pending commands, active Item Box와 Presentation queue를 초기화.
- Stage entry 당시 active effect와 남은 시간을 복원하고 현재 Stage에서 획득한 효과는 제거.
- 같은 Stage/profile/background를 entry 상태로 재활성화.

Integration coordinator는 lane별 `restart_prepare(stage_restart_id) → restore(snapshot, stage_restart_id) → restored(stage_restart_id)` barrier를 관리한다. 모든 필수 lane의 ack 전 gameplay를 재개하지 않는다. timeout/restore 실패 시 paused 상태를 유지하고 사용자가 Main Screen으로 안전하게 나갈 수 있는 복구 UI를 제공한다. 새 Restart/full Retry마다 `run_epoch`를 증가시킨다.

Presentation은 snapshot을 만들거나 score를 빼지 않고 `restart_stage_requested`와 `reset_view(run_epoch, stage_restart_id)`만 사용한다. late completion/event는 `run_epoch` 또는 restart correlation ID가 다르면 무시한다.

## 6. Settings v1

Main Screen과 Pause가 같은 Settings panel을 공유한다.

| Setting | Behavior |
|---|---|
| Master Volume | 전체 audio bus의 0~100 값 |
| Mute | Master output on/off; volume 값을 파괴하지 않음 |
| Fullscreen | Web fullscreen request; browser 거부 시 windowed 표시 |

- 설정은 브라우저 local storage/config에 저장하고 다음 실행에 복원한다.
- 저장·로드 실패는 crash나 blocking modal 없이 default 값으로 fallback한다.
- Fullscreen 선호값은 저장하지만 브라우저 정책상 자동 적용하지 못하면 다음 `START` 또는 설정 click 같은 사용자 gesture에서 요청한다.
- Main에서 닫으면 Main, Pause에서 닫으면 동결된 Pause modal로 돌아간다.
- Settings 진입이나 종료가 gameplay를 자동 재개하지 않는다.
- Reduced Effects는 v1 범위가 아니다. 실제 FX 시안 검토 뒤 별도 Goal 여부를 논의한다.

## 7. Clear, Settlement, and Shift

UI는 다음 순서를 섞지 않는다.

1. Time Up Lock.
2. Final Settlement: 남은 공의 base score 반영 표시.
3. authoritative success/failure reason 표시.
4. non-final success면 축하 메시지와 `Next Stage` 버튼을 표시한 채 정지, final success면 Final Result.
5. matching `Next Stage` 요청을 받은 뒤에만 Scale Shift.
6. non-final Shift의 HUD reflow와 profile activation.
7. 다음 Stage control 반환 또는 Final Result.

Settlement score가 이미 run score에 반영되는 authoritative event를 표시할 뿐 Presentation이 `run_score += stage_score`를 수행하지 않는다.

## 8. Terminal State Matrix

| Trigger | Stage | After Final Settlement | Presentation destination |
|---|---|---|---|
| local Lv4 first discovery | non-final | `PLAYING` | FIRST CONTACT CUT-IN → Playing |
| Two Black Holes contact | final | terminal snapshot | mutual orbit·폭발 뒤 gameplay UI 제거, `SNOWBALL EFFECT`, `CLEAR SCORE`, `MAIN MENU` |
| Time Up + score clear | non-final | `CLEARED` | Congratulations pause → `Next Stage` → Scale Shift |
| Time Up + score miss | non-final | `FAILED` | Failure → Run Result |
| Time Up | final | final result snapshot | Final Result; no next Stage |

- 같은 tick의 Active Cashout으로 시간이 다시 양수가 되면 Time Up UI를 띄우지 않는다.
- 같은 tick에 local Lv4와 Time Up이 함께 생기면 최초 발견은 기록하되 종료 경로는 Time Up 결과를 사용한다.
- 결과가 잠기기 전에 failure overlay를 선행 표시하지 않는다.
- 하나의 terminal correlation ID에는 presentation 한 종류만 시작한다.

## 9. Result and Full Retry

- Result는 final Run Score, highest Stage, highest Ball을 필수로 표시한다.
- 추가 통계는 result snapshot에 실제 값이 있을 때만 보조 영역에 표시한다.
- primary action `RETRY RUN`은 전체 Run을 Stage 1부터 초기화한다.
- secondary action `MAIN SCREEN`은 Main으로 이동한다.
- full Retry 뒤에는 Ball array, score, timer, snapshot, Settlement/Shift, item, Presentation/audio lock이 남지 않는다.
- Result scene/script는 Content/Systems-owned, reset wiring은 Integration-owned다.

Result는 Integration이 생산한 typed immutable snapshot 하나만 소비한다.

```text
ResultViewState
- run_id: int
- run_epoch: int
- terminal_reason: StringName
- run_score: float
- highest_stage_id: StringName
- highest_ball_id: StringName
- highest_ball_visual_key: StringName
- optional_stats: Dictionary
```

필수 identity와 score 필드는 typed field로 고정한다. `optional_stats`는 값이 있는 통계만 보조 영역에 그리기 위한 확장 영역이며 gameplay 판정을 담지 않는다. Presentation은 같은 `run_id` Result를 두 번 열지 않고 이전 `run_epoch` snapshot을 거부한다.

## 10. Focus, Input, and Copy

- keyboard/controller focus는 색 외 outline, bracket, 1px offset으로 구분한다.
- modal은 focus trap과 focus restoration을 가진다.
- browser focus loss 때 pressed input을 clear하고 자동 Pause한다. 복귀 후 수동 Resume만 허용한다.
- resize 후 click/mouse position과 logical Play Field mapping이 일치한다.
- `RESTART STAGE`, `RETRY RUN`, `RESUME`을 서로 바꾸어 쓰지 않는다.
- warning과 confirmation은 손실 대상과 다음 행동을 먼저 쓴다.
- decorative glitch가 점수, 시간, 확인 문구를 훼손하지 않는다.

## 11. Screen Deliverables

1. Main Screen normal/focus state sheet.
2. Playing Initial/L1/L2와 Galactic Black Hole Phase L3 gameplay keyframes.
3. Pause modal과 두 destructive confirmation focus sheet.
4. Settings Main-entry/Pause-entry return states.
5. Clear → Settlement → Shift storyboard.
6. Failure/Run Result와 Final Result.
7. Web audio-locked/focus-lost/fullscreen-denied states.

## 12. Intentional Exclusions

- runtime state machine, storage adapter, audio bus, signal wiring 구현.
- result calculation.
- Reduced Effects runtime toggle.
- 별도 Main Screen과 Title 중복 구현.
