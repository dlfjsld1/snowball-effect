# 06. Goal Roadmap

Status: APPROVED PLAN — does not change Goal status  
Planning owner: Presentation  
Source of truth for actual Goal status: `docs/goals/STATUS.md`

이 문서는 Presentation 준비 순서를 설명할 뿐 Goal을 `IN PROGRESS`, `IMPLEMENTED`, `VERIFIED`로 변경하지 않는다.

기술 리뷰에서 확인된 Core + Integration 선행 계약과 Presentation 진입 게이트는 [08_TECHNICAL_REVIEW_HANDOFF.md](08_TECHNICAL_REVIEW_HANDOFF.md)를 따른다.

## 1. Current Position

- S1 minimum loop는 repository status상 완료된 기반이다.
- 전체 next slice는 S2 Merge & Score다.
- 현재 next implementation Goal은 Core `S2-G2`다.
- 다음 Presentation implementation Goal은 `S2-G5`다.
- `S2-G5`는 Core의 `S2-G3` Merge events와 `S2-G4` score formatting API에 의존한다.
- `S2-G4`는 repository status상 VERIFIED다.
- 이 디자인 문서 작성은 Goal 구현이나 상태 진행이 아니다.

## 2. Design Preparation Track

Goal lane과 별도로, 구현 전 준비할 문서/시각 산출물이다.

| Order | Deliverable | 결과 |
|---:|---|---|
| D0 | Design foundations + roadmap | 현재 문서 세트 |
| D1 | 15등급 Ball visual bible + V4 Compression Bloom sheet | S2-G5 및 후속 catalog 기준; 숫자 popup은 amount 계약 대기 |
| D2 | HUD Information Contract v1 + reflow board | S3-G6 scope 확정 |
| D3 | StagePlayFieldProfile cross-lane contract | dynamic bounds 구현 범위 확정 |
| D4 | V4 slim bezel 7-beat Shift storyboard + Frame keyframes | S5-G4 production 기준 |
| D5 | V4 Merge/Item/Milestone FX tier·reduced recipe·audio cue matrix | S6-G1~G4 기준 |
| D6 | Frozen Enamel Main/Pause/Settings/Result visual handoff | Content UI 구현 지원 |
| D7 | Web visual QA pack | S9 release evidence 지원 |
| D8 | Item Box state/rarity/break sheet | 재구성된 S7 구현 기준 |
| D9 | Eng review handoff + contract fixtures | Core/Integration blocker와 Presentation 독립 검증 기준 |

## 3. S2 — Merge and Score

### Presentation Goal: S2-G5

Owned Files:

- `scripts/presentation/effect_manager.gd`
- `scenes/effects/merge_effect.tscn`
- `scripts/ui/hud.gd`
- `tests/presentation/**`

Preparation:

1. Ball hierarchy bible.
2. normal/high-level Merge comparison.
3. persistent score slot의 formatter boundary stress layout.
4. duplicate-event and effect reset states.

Integration inputs:

- `ball_merged(result_level, world_position)`.
- `top_ball_created(global_level)` if used for anticipation; Clear presentation remains later contract.
- pure formatting API from S2-G4.
- `score_changed(stage_score, run_score)` for persistent values.

`03_TECHNICAL_DESIGN.md`의 초안 signal에는 `special_type` 인자가 있지만 S2 slice와 `INTEGRATION_CONTRACTS.md`는 2-argument `ball_merged`를 사용한다. S2-G3를 구현하기 전에 한 signature로 동기화한다.

추가 계약:

- Merge가 실제 점수를 지급하면 `score_event_committed(event_id, source_type, amount, world_position)`처럼 amount와 위치가 함께 있는 authoritative event를 추가한다.
- Merge가 점수를 지급하지 않으면 numeric popup을 만들지 않고 level-up text/burst만 사용한다. result Ball의 잠재 score를 획득 점수처럼 표시하지 않는다.
- v1 Plan 1은 global 7/9를 건너뛰므로 장기 Merge API는 `StageDefinition.ball_global_levels`의 다음 항목을 결과로 반환해야 한다. 단순 `global_level + 1` 계약을 유지하려면 Plan 1을 구현할 수 없으므로 S2-G3 전에 game rules/task/slice 중 어느 시점에 이 lookup을 도입할지 명시한다.

Do not include Stage transition, dynamic Frame, score calculation, or runtime speed changes.

## 4. S3 — Stage Contract and HUD

### Missing Presentation Goal: Clear and Settlement presentation

현재 S3-G5 Integration은 Presentation의 clear/settlement 완료 signal을 기다리지만, 현행 S3에는 그 signal을 생산하는 Presentation Goal이 없다. S3 구현 전에 Goal을 재구성해야 한다.

권장 계약:

- Owner: Presentation.
- Owned Files: `scripts/presentation/presentation_manager.gd`, 새 `scripts/presentation/settlement_presenter.gd`, `scenes/effects/settlement_effect.tscn`, `tests/presentation/**`.
- Input: authoritative `stage_clear_decided(reason)`와 Core Final Settlement 완료 결과.
- Integration request: `settlement_presentation_requested(settlement_id: int, stage: int, reason: StringName, final_stage_score: float)`.
- Output: `settlement_presentation_finished(settlement_id: int)` exactly once.
- Default visualization: aggregate score/count presentation 한 번. per-ball Node/Tween queue는 만들지 않는다.
- Reset: active queue/tween/popup을 취소하고 이전 `settlement_id`의 late completion을 무시한다.
- Verification: duplicate request/finish에도 전이 한 번, Presentation은 score/clear를 계산하지 않음, reset 뒤 stale signal 없음.

권장 Goal 재정렬은 이 Presentation Goal을 현재 Integration settlement Goal보다 먼저 두고, Integration Goal과 HUD Goal을 뒤로 renumber하는 것이다. 대안으로 Integration이 Presentation 완료를 기다리지 않도록 계약을 단순화할 수 있지만, 둘 중 하나를 S3 slice/task/Integration contract에 명시하기 전에는 S3 settlement integration을 시작하지 않는다.

### Presentation Goal: S3-G6

`HUD Information Contract v1`은 디자인 기준으로 확정됐다.

- 필수: Stage Time, Stage Score/Clear Target, current Stage Ball Progression, Run Score, active effects, Pause action.
- hierarchy: 왼쪽 Time→Stage Score/Target→Ball Progression→Run Score, 오른쪽 effect strip→Pause.
- Stage name은 Shift/Stage start transient identity이고 persistent 필수 항목이 아니다.
- Ball Count와 highest Ball은 debug/result 정보로 이동한다.
- Core/Content/Integration은 typed `RefCounted` `HUDViewState`, `BallProgressionEntry`, `ActiveEffectView`와 동등한 read-only payload를 제공한다.
- HUD는 score/time/effect duration을 계산하거나 gameplay state를 변경하지 않는다.
- discrete state는 즉시 반영하고 timer/effect countdown snapshot은 producer가 최대 10Hz로 coalesce한다.
- `run_epoch`와 monotonic `view_revision`으로 Restart 뒤 stale snapshot을 거부한다.
- 현재 S3-G6 verification이 이 목록과 다르면 구현 전에 slice/task 계약을 갱신한다.

Deliverables:

- approved left/right side-panel layout.
- Initial/L1/L2/L3 HUD reflow board.
- normal/pressure/effect refresh/pause/clear/shift states.
- time bonus 0 edge-state visualization.

## 5. S4 — Mass Simulation Support

S4 has no primary Presentation Goal, but its outputs affect visual decisions.

- consume read-only `candidate_count/grid_cell_count` only if debug visualization is requested.
- S2에서는 100/500/1000 합성 mock만 사용하고, 실제 runtime capture는 S4-G3 이후 effect throttle design에 사용한다.
- do not add per-ball node/process architecture or logical particles.

## 6. S5 — Scale Shift and Dynamic Play Field

### Existing Presentation Goal: S5-G4

Owned Files include background/presentation managers, backgrounds, effects, and presentation tests. It subscribes to Stage/Shift events and returns `stage_shift_presentation_finished`.

### Required contract update before implementation

현재 S5 Goal set은 Stage World와 Shift presentation을 다루지만, **Stage별 logical Play Field 폭 변경을 명시적으로 소유하는 Goal이 없다.** 이 기능은 하나의 Presentation Goal에 암묵적으로 넣으면 안 된다.

또한 현재 rules/S8은 4개 Stage를 전제로 하지만 승인된 v1 디자인은 Ground/Planetary/Galactic 3개 Stage와 Final L3 profile을 사용한다. S5/S8 구현 전에 Stage 수, top Ball, terminal route를 최신 결정으로 동기화한다.

구현 전에 다음 중 하나로 Goal을 재구성한다.

1. Content Stage profile, Core bounds application, Integration activation을 각각 작은 Goal로 추가한다.
2. 기존 S5-G1/G2/G3 계약을 수정해 각 lane의 Owned Files, API, verification을 명시한다.

권장 분해:

- Content profile Goal: `resources/stages/**`의 `StagePlayFieldProfile.active_rect: Rect2`, `profile_id`, visual keys와 `StageDefinition.play_field_profile` reference.
- Content Ball extension Goal: global 7~14 BallDefinition과 Plan 1/Plan 2의 `ball_global_levels` data. 현재 VERIFIED S2-G1의 0~6 evidence를 덮어쓰거나 재사용하지 않는다.
- Core bounds Goal: `scripts/core/stage_runtime.gd`를 coordinator로 두고 `scripts/simulation/ball_simulation_manager.gd`, `scripts/gameplay/paddle.gd`, `tests/simulation/**`, `tests/core/**`의 prepared/active Rect를 spawn·reflection·cashout·paddle clamp·mouse mapping에 원자적으로 적용.
- Presentation Goal: `scripts/presentation/background_manager.gd`, `scripts/presentation/presentation_manager.gd`, `scenes/backgrounds/**`, `scenes/effects/**`, 승인된 `assets/backgrounds/**`에서 Frame + displayed field animation.
- Integration Goal and lock: `scripts/core/stage_manager.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`에서 Settlement → Shift → profile activation → next Stage wiring. `project.godot` 변경이 필요하면 lock 목록에 명시.

S5-G4는 animation이 gameplay state를 직접 바꾸지 않는 원칙을 유지한다.

### Proposed cross-lane API table

| Producer | Signal/API | Consumer | Cadence / idempotency |
|---|---|---|---|
| Content StagePlayFieldProfile | `active_rect: Rect2`, `profile_id: StringName` | Core, Integration, Presentation | Stage data load 시 read-only |
| Content StageDefinition | `ball_global_levels: Array[int]`, `play_field_profile` | Core, Integration, Presentation | Stage data load 시 read-only |
| Core `StageRuntime` | `prepare_play_field_rect(target_rect, run_epoch, shift_id)` | Integration | shift당 1회, duplicate id safe |
| Presentation `StageWorldPresenter` | `play_stage_shift(run_epoch, shift_id, from_rect, to_rect, frame_visual_key, background_key)` | Integration calls | shift당 1회; same identity 재호출은 중복 animation 금지 |
| Presentation `StageWorldPresenter` | `stage_shift_presentation_finished(run_epoch, shift_id)` | Integration | 완료 시 exactly once; stale epoch reject |
| Presentation `StageWorldPresenter` | `reset_presentation(new_epoch)` | Integration calls | Restart/Retry당 1회; 이전 Tween/callback 무효화 |
| Core `StageRuntime` | `activate_prepared_play_field_rect(run_epoch, shift_id)` | Integration | matching identity에서 once; simulation+paddle에 같은 tick 적용, mismatch reject |
| Core `StageRuntime` | `get_play_field_rect() -> Rect2` | Integration/tests | read-only verification |

이 표는 구현 전 `INTEGRATION_CONTRACTS.md`와 재구성한 S5 Goals에 복사·승인해야 효력이 생긴다.

L1/L2 완료 뒤에는 다음 Stage를 활성화하지만 final Clear의 L3는 terminal profile만 활성화하고 spawn·timer·input을 재개하지 않는다.

## 7. S6 — Game Feel

### S6-G1 Event Tiers and FX Budget

- T0~T4 matrix 확정.
- tier별 maximum concurrent count, popup aggregation threshold, duration을 Entry Gate에서 수치로 고정.
- burst 시 일반 FX throttle, critical event 보존.
- effect count와 frame-time evidence 기록.
- `FxBudgetProfile`을 사용해 T0/T1 aggregation pool, T2 제한 pool, T3/T4 reserved slot을 분리하고 event당 무제한 Node/Tween 생성 경로를 금지.

### S6-G2 CUT-IN and Screen Presentation

- high-tier Merge/Shift/Final event의 cut-in 우선순위.
- `presentation_pause_requested(duration)`와 `cutin_finished(event_id)` handoff.
- 중복/선점/취소/reset 정책.

### S6-G4 Sound Tier and Readability

- S6-G3 Content audio catalog 소비.
- priority/polyphony와 Web first-input audio 상태.
- late density에서 Paddle/Ball/HUD 가독성 확인.

## 8. S7 — Optional Item Layer

현재 S7과 task는 “낙하 item이 Ball과 충돌하지 않고 Paddle로 획득”을 전제로 한다. 승인된 방향은 “낙하 Item Box가 Ball을 완전 반사하고 durability가 0이 되면 item 획득”이므로 기존 S7-G1~G4를 시작하기 전에 재구성한다.

권장 Goal 분해:

| Goal result | Owner | Owned Files proposal | Integration Point |
|---|---|---|---|
| Item/rarity/Box data | Content/Systems | `scripts/data/item_definition.gd`, `resources/items/**`, `tests/content/**` | read-only ItemCatalog; rarity/durability/spawn weight |
| Box spawn·fall·miss lifecycle | Content/Systems | `scripts/gameplay/item_box_manager.gd`, `tests/content/**` | spawn/despawn request와 read-only box snapshot |
| Ball↔Box damage·reflection | Core | `scripts/simulation/ball_simulation_manager.gd`, `tests/simulation/**` | hit/break commands; centralized Ball arrays 유지 |
| Item gateway and reset | Integration | `scripts/core/item_effect_gateway.gd`와 명시적으로 잠근 coordinator files | break commit→effect activation, Pause/Shift/Restart/Retry once-only |
| Item Box/HUD presentation | Presentation | `scripts/presentation/item_box_presenter.gd`, `scenes/effects/item_box_effect.tscn`, `scripts/ui/hud.gd`, 승인된 item/UI assets, `tests/presentation/**` | damage/break/miss/effect refresh event 구독 |
| Magnet/Blizzard/Fire effects | Content/Systems | 기존 item effect files/tests | gateway의 authoritative activation/expiry 사용 |

Required data seed:

- rarity durability Common/Rare/Epic = 3/6/10.
- Stage-local grade damage 1~5 = 0/1/2/3/5.
- initial fixed rarity mapping: Magnet/Common, Blizzard/Rare, Fire Core/Epic.
- mapping, durability, spawn weight는 향후 아이템 추가/리밸런싱을 위해 Resource에 둔다.

Required behavior contract:

- 모든 Ball이 Box에서 완전 반사하고 speed magnitude를 유지한다. grade 1 damage만 0이다.
- same-tick hit damage는 모두 합산하지만 `box_id`별 break/reward는 once-only다.
- miss는 무벌점, Pause는 freeze, Settlement/Shift/Result/full Retry는 cleanup이다.
- Stage Restart는 Stage entry snapshot을 복원한다.
- Box damage/break가 score, time, terminal precedence를 직접 변경하지 않는다.
- Presentation은 effect를 직접 활성화하지 않는다.

다음 signature는 제안이며 구현 전에 slice/task/Integration contract에 동일하게 승인한다.

```text
item_box_hit(box_id, ball_slot_id, local_grade, damage, remaining_durability, world_position)
item_box_broken(box_id, item_id, rarity, world_position)
item_box_missed(box_id, world_position)
active_effects_changed(effects, refresh_sequence)
```

Fire와 optional item은 계속 Core rules와 분리한다. Item Box가 없어도 Merge/Cashout/Stage clear 계약이 바뀌지 않아야 한다.

## 9. S8 — Black Hole and Final Result

승인된 v1은 별도 Black Hole Stage가 아니라 Galactic Stage의 top Ball `Black Hole`과 terminal L3 profile로 끝난다. 따라서 현행 `S8_BLACK_HOLE.md`의 moving Black Hole force와 4번째 Stage 전제는 v1 필수 경로에서 제거하거나 Plan 2 experiment로 옮겨야 한다. 실제 Goal 상태를 바꾸기 전에 game rules, technical design, slice를 함께 재승인한다.

### Main/Result UI expansion

Runtime files are Content/Systems-owned:

- `scripts/ui/title_screen.gd`
- `scripts/ui/result_panel.gd`
- `scenes/ui/title_screen.tscn`
- `scenes/ui/result_panel.tscn`

Title은 Main Screen으로 확장해 Start/Settings를 제공한다. Result의 `RETRY RUN`은 전체 reset이고 Main으로 이동할 수 있다.

Result는 typed immutable `ResultViewState(run_id, run_epoch, terminal_reason, run_score, highest_stage_id, highest_ball_id, highest_ball_visual_key, optional_stats)`를 소비한다. Presentation은 같은 `run_id` 중복 표시와 stale `run_epoch`를 거부하고 결과 값을 계산하지 않는다.

### Pause/Settings UI Goal — required

현재 S1-G5의 항상 보이는 Pause/Retry toolbar는 v1 최종 UI가 아니다. 별도 Content/Systems Goal을 추가한다.

- Owned Files: `scripts/ui/pause*.gd`, `scenes/ui/pause*.tscn`, 새 `scripts/ui/settings*.gd`, `scenes/ui/settings*.tscn`, `tests/content/**`.
- Output requests: `resume_requested`, `restart_stage_requested`, `settings_requested`, `main_screen_requested`.
- Pause modal: Resume/Restart Stage/Settings/Main, focus trap, 두 destructive confirmation.
- Settings: Master Volume, Mute, Fullscreen, local persistence와 safe fallback.
- focus loss: auto Pause request only; focus return does not auto Resume.
- UI는 SceneTree, score, snapshot, AudioServer, fullscreen을 직접 바꾸지 않고 system adapter/Integration request를 사용한다.

### Stage Restart Snapshot Goal — required

Owner는 Core이고 Integration이 wiring한다.

- snapshot: Stage identity, entry Run Score/statistics/highest Ball, entry active effects/time, reproducible stage seed.
- restore: Stage Score/time, Ball/free slots, commands, Item Box/effects, Settlement/Shift/Presentation locks.
- current Stage 획득분은 rollback하고 이전 Stage 누적분은 보존한다.
- full Run `retry_requested`와 Stage `restart_stage_requested`를 별도 API/correlation ID로 유지한다.
- Integration coordinator가 lane별 `restart_prepare(id) → restore(snapshot, id) → restored(id)` barrier를 관리하고 모든 필수 ack 전 gameplay를 재개하지 않는다.
- timeout/restore 실패 시 paused 상태를 유지하는 사용자 복구 정책을 Integration Goal에서 승인한다.

### Integration Goal and lock — required

Main/Pause/Settings/Stage Restart/Result를 한 state flow로 묶는 Goal을 두고 `game_manager.gd`, `stage_manager.gd`, `main.tscn`, 필요 시 `project.godot`을 `STATUS.md`에서 잠근다. Settings의 storage/audio/fullscreen adapter 소유 경로도 Goal에서 먼저 정한다.

Presentation contribution:

- Title/Result keyframes and focus-state specs.
- Pause/Settings/confirmation keyframes and keyboard/controller focus specs.
- final Frame/Stage World visual package.
- read-only result hierarchy recommendation.
- Presentation reset API와 effect/audio cleanup 계약.

Content implements the UI, Integration wires retry/reset, Core owns result snapshot values.

## 10. S9 — Web Release

S9는 Content/Systems-owned release lane이다. Presentation은 다음 evidence를 제공한다.

- 1280×720, 1366×768, 1600×900, 1920×1080 screenshots.
- resize/focus/audio-locked visual states.
- late-game density screenshot과 frame-time observation.
- Title/Playing/Shift/Result의 representative capture.
- public thumbnail/video용 approved visual framing.

Web build/export 설정은 직접 수정하지 않는다.

## 11. Dependency Flow

```text
S2-G2 candidates
  → S2-G3 Merge lookup/event contract + S2-G4 formatter
  → S2-G5 Merge FX / score presentation
  → S3 Clear/Settlement Presentation Goal 재구성
  → S3 typed HUDViewState/BallProgression fixture + current S3-G6 재구성
  → S4 density evidence
  → S5 7~14 Ball data + 3-Stage mapping + Stage profile contract
  → S5-G4 Frame / Stage World / Shift
  → S6 FX tiers / cut-in / audio readability
  ├─ S7 Item Box data → physics → gateway → presentation → optional effects
  └─ Main/Pause/Settings UI + Stage Restart snapshot + Result integration
      → run_epoch stale-event rejection + terminal L3 / typed Final Result
  → S9 Web visual evidence
```

## 12. Lock and Ownership Rules

- Presentation은 자신의 Owned Files만 구현한다.
- `project.godot`, `scenes/main/main.tscn`, `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`는 Integration-owned다.
- 다른 lane의 API가 필요하면 Goal/contract request를 먼저 작성한다.
- dynamic Play Field처럼 여러 lane이 만나는 기능은 별도 Integration Goal과 file lock을 사용한다.
- 한 번에 Presentation lane `IN PROGRESS` Goal은 최대 하나다.

## 13. Recommended Next Presentation Goal

현재 전체 next Goal은 Core `S2-G2`다. 다음 Presentation Goal은 `S2-G5`이며 Core S2-G3의 최종 Merge/event 계약과 VERIFIED S2-G4 formatter를 확인한 다음, 사용자가 runtime 구현을 명시적으로 승인했을 때만 시작한다.

V4 채택으로 Presentation은 keyframe/state sheet 제작을 진행할 수 있지만 runtime Goal의 의존 순서는 바뀌지 않는다. 특히 Merge numeric popup은 authoritative amount event가 없으면 제외한다.
