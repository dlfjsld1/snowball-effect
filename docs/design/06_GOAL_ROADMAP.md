# 06. Goal Roadmap

Status: APPROVED PLAN — does not change Goal status  
Planning owner: Presentation  
Source of truth for actual Goal status: `docs/goals/STATUS.md`

이 문서는 Presentation 준비 순서를 설명할 뿐 Goal을 `IN PROGRESS`, `IMPLEMENTED`, `VERIFIED`로 변경하지 않는다.

기술 리뷰에서 확인된 Core + Integration 선행 계약과 Presentation 진입 게이트는 [08_TECHNICAL_REVIEW_HANDOFF.md](08_TECHNICAL_REVIEW_HANDOFF.md)를 따른다.

## 1. Current Position

- S1 minimum loop는 repository status상 완료된 기반이다.
- 전체 next slice는 S2 Merge & Score다.
- S2-G2/G3/G4는 VERIFIED다. 최신 Ball catalog와 현재 Resource가 달라 S2-G1은 재검증 `PENDING`이다.
- 다음 Presentation implementation Goal은 `S2-G5`다.
- `S2-G5`는 Core의 `S2-G3` Merge events와 `S2-G4` score formatting API에 의존한다.
- `S2-G4`는 repository status상 VERIFIED다.
- 이 디자인 문서 작성은 Goal 구현이나 상태 진행이 아니다.

## 2. Design Preparation Track

Goal lane과 별도로, 구현 전 준비할 문서/시각 산출물이다.

| Order | Deliverable | 결과 |
|---:|---|---|
| D0 | Design foundations + roadmap | 현재 문서 세트 |
| D1 | 15등급 Ball visual bible + V5 Compression Bloom sheet | Lv14 Black Hole Ball/동명 맵 기믹 식별, S2-G5 및 후속 catalog 기준; 숫자 popup은 amount 계약 대기 |
| D2 | HUD Information Contract v2 + reflow board | Stage 이름 + 세로 5칸 progressive reveal, S3-G6 scope 확정 |
| D3 | StagePlayFieldProfile cross-lane contract | dynamic bounds 구현 범위 확정 |
| D4 | V5 slim bezel Shift + Black Hole Phase storyboard와 4개 Frame keyframe | S5-G4/S8-G5 production 기준 |
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

`ball_merged(result_level, world_position)`는 Technical Design, S2 slice, Integration Contract에서 동일한 **2인자 계약**으로 확정했다. score amount와 `special_type`은 이 event에 추가하지 않는다.

추가 계약:

- Merge가 실제 점수를 지급하면 `score_event_committed(event_id, source_type, amount, world_position)`처럼 amount와 위치가 함께 있는 authoritative event를 추가한다.
- Merge가 점수를 지급하지 않으면 numeric popup을 만들지 않고 level-up text/burst만 사용한다. result Ball의 잠재 score를 획득 점수처럼 표시하지 않는다.
- 기본 Run은 global 7/9를 건너뛰므로 S5-G2 runtime은 `StageDefinition.local_ball_levels`의 다음 항목을 결과로 반환해야 한다. 기존 S2-G3 contiguous baseline evidence는 보존하되 Planetary `6→8→10`을 S5-G2에서 추가 검증한다.

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

`HUD Information Contract v2`는 디자인 기준으로 확정됐다.

- 필수: Stage name, Stage Time, Stage Score/Clear Target, current Stage Ball Progression, Run Score, active effects, Pause action.
- hierarchy: 왼쪽 Stage name→Time→Stage Score/Target→세로 Ball Progression→Run Score, 오른쪽 effect strip→Pause.
- Stage name은 `Ground`/`Planetary`/`Galactic`을 persistent하게 표시한다.
- Ball Progression은 세로 5칸 housing을 유지하고 Stage 진입 시 첫 공만 표시한다. 새 local 공의 최초 생성 event마다 다음 아이콘·이름을 한 번 공개하며 미발견 항목은 출력하지 않는다.
- Ball Count와 highest Ball은 debug/result 정보로 이동한다.
- Core/Content/Integration은 typed `RefCounted` `HUDViewState`, `BallProgressionEntry`, `ActiveEffectView`와 동등한 read-only payload를 제공한다.
- HUD는 score/time/effect duration을 계산하거나 gameplay state를 변경하지 않는다.
- discrete state는 즉시 반영하고 timer/effect countdown snapshot은 producer가 최대 10Hz로 coalesce한다.
- `run_epoch`와 monotonic `view_revision`으로 Restart 뒤 stale snapshot을 거부한다.
- 현재 S3-G6 verification이 이 목록과 다르면 구현 전에 slice/task 계약을 갱신한다.

Deliverables:

- approved left/right side-panel layout.
- Initial/L1/L2/L3 HUD reflow board; L3는 Galactic Black Hole gameplay 상태.
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

v1은 Ground/Planetary/Galactic 3개 Stage를 사용한다. Initial/L1/L2는 Stage 진입 profile이고, L3는 Galactic 안에서 Black Hole 기믹이 발동할 때 활성화되는 gameplay profile이다. Final Result를 네 번째 Frame 전환으로 취급하지 않는다.

구현 전에 다음 중 하나로 Goal을 재구성한다.

1. Content Stage profile, Core bounds application, Integration activation을 각각 작은 Goal로 추가한다.
2. 기존 S5-G1/G2/G3 계약을 수정해 각 lane의 Owned Files, API, verification을 명시한다.

권장 분해:

- Content profile Goal: `resources/stages/**`의 `StagePlayFieldProfile.active_rect: Rect2`, `profile_id`, visual keys와 `StageDefinition.play_field_profile` reference.
- Content Ball alignment: S2-G1에서 global 0~14를 최신 catalog(Lv6 Sun, Lv7 Red Giant, Lv9 Nebula, Lv10 Galaxy, Lv14 Black Hole)로 맞추고 다시 검증한다. 기존 Lv14 `Black Hole`/`black_hole` Resource는 유지하되 나머지 drift를 수정한다.
- Core bounds Goal: `scripts/core/stage_runtime.gd`를 coordinator로 두고 `scripts/simulation/ball_simulation_manager.gd`, `scripts/gameplay/paddle.gd`, `tests/simulation/**`, `tests/core/**`의 prepared/active Rect를 spawn·reflection·cashout·paddle clamp·mouse mapping에 원자적으로 적용.
- Presentation Goal: `scripts/presentation/background_manager.gd`, `scripts/presentation/presentation_manager.gd`, `scenes/backgrounds/**`, `scenes/effects/**`, 승인된 `assets/backgrounds/**`에서 Frame + displayed field animation.
- Integration Goal and lock: `scripts/core/stage_manager.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`에서 Settlement → Shift → profile activation → next Stage wiring. `project.godot` 변경이 필요하면 lock 목록에 명시.

S5-G4는 animation이 gameplay state를 직접 바꾸지 않는 원칙을 유지한다.

### Proposed cross-lane API table

| Producer | Signal/API | Consumer | Cadence / idempotency |
|---|---|---|---|
| Content StagePlayFieldProfile | `active_rect: Rect2`, `profile_id: StringName` | Core, Integration, Presentation | Stage data load 시 read-only |
| Content StageDefinition | `local_ball_levels: Array[int]`, `play_field_profile`, Galactic `black_hole_phase_profile` | Core, Integration, Presentation | Stage data load 시 read-only |
| Core `StageRuntime` | `prepare_play_field_rect(target_rect, run_epoch, shift_id)` | Integration | shift당 1회, duplicate id safe |
| Presentation `StageWorldPresenter` | `play_stage_shift(run_epoch, shift_id, from_rect, to_rect, frame_visual_key, background_key)` | Integration calls | shift당 1회; same identity 재호출은 중복 animation 금지 |
| Presentation `StageWorldPresenter` | `stage_shift_presentation_finished(run_epoch, shift_id)` | Integration | 완료 시 exactly once; stale epoch reject |
| Presentation `StageWorldPresenter` | `reset_presentation(new_epoch)` | Integration calls | Restart/Retry당 1회; 이전 Tween/callback 무효화 |
| Core `StageRuntime` | `activate_prepared_play_field_rect(run_epoch, shift_id)` | Integration | matching identity에서 once; simulation+paddle에 같은 tick 적용, mismatch reject |
| Core `StageRuntime` | `get_play_field_rect() -> Rect2` | Integration/tests | read-only verification |

이 표는 구현 전 `INTEGRATION_CONTRACTS.md`와 재구성한 S5 Goals에 복사·승인해야 효력이 생긴다.

L1/L2 완료 뒤에는 다음 Stage를 활성화한다. L3는 첫 Lv14의 Black Hole 전환 event로 활성화하며 transition 동안만 정지한 뒤 같은 Galactic에서 spawn·timer·input을 재개한다. 두 Black Hole 접촉 뒤에는 추가 Shift 없이 finale와 타이틀로 이동한다.

## 7. S6 — Game Feel

### S6-G1 Event Tiers and FX Budget

- T0~T4 matrix 확정.
- tier별 maximum concurrent count, render-frame spawn cap, duration을 Entry Gate에서 수치로 고정.
- burst 시 일반 FX throttle, critical event 보존.
- effect count와 frame-time evidence 기록.
- 현재 단일 runtime consumer인 `EffectManager`에서 bounded active/spawn cap과 critical priority reservation을 적용하고 event당 동시 Node/Tween 수가 무제한 증가하는 경로를 금지. 복수 profile이 필요해질 때만 `FxBudgetProfile`을 추출.

### S6-G2 CUT-IN and Screen Presentation

- Ground `Giant Snowball`·`Moon`, Planetary `Supernova`·`Galaxy`, Galactic `Event Horizon`·`Black Hole`의 Run 내 최초 생성 CUT-IN 6종.
- `presentation_pause_requested(duration)`와 `cutin_finished(event_id)` handoff.
- 중복/선점/취소/reset 정책.

### 확정 후속 Presentation/Integration Goals

- S3-G7: local Lv4 생성 즉시 Clear 제거와 Time Up Score Clear 단일 경로 마이그레이션.
- S3-G8: `stage_score / clear_score` read-only gauge bar.
- S5-G6/S5-G6I: Stage Clear 축하 메시지·`Next Stage` 요청 UI와 matching 요청 이후 Shift wiring.
- S5-G7: Galactic Stage World 배경 레이어의 투명 합성.

### S6-G4 Sound Tier and Readability

- Owner: Content/Systems. S6-G3 Content audio catalog 소비.
- priority/polyphony와 Web first-input audio 상태.
- late density에서 Paddle/Ball/HUD 가독성 확인.

## 8. S7 — Optional Item Layer

현재 규칙의 아이템 획득은 Ball 충돌 기반 `Item Ball`이다. 디자인은 이 entity를 각진 `Item Box`/화물 캡슐로 표현하고 durability가 0이면 획득하는 방향이다. S7-G1~G4를 시작하기 전에 canonical entity name, reflection/damage, event payload와 Owned Files를 동기화한다.

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

Lv14 `Black Hole`은 Galactic top Ball이다. 첫 Lv14는 이동 Black Hole runtime 기믹으로 전환되며 `Black Hole Phase Transition`으로 L2 `880`→L3 `1040` Frame/Play Field를 함께 확장하고 같은 Stage gameplay를 재개한다. 두 번째 Black Hole과 접촉하면 추가 Frame Shift 없이 finale와 타이틀 Run End로 간다. Presentation 구현은 S8-G5, logical phase/force는 S8-G1, wiring은 S8-G4가 소유한다.

### Main/Result UI expansion

Runtime files are Content/Systems-owned:

- `scripts/ui/title_screen.gd`
- `scripts/ui/result_panel.gd`
- `scenes/ui/title_screen.tscn`
- `scenes/ui/result_panel.tscn`

Title은 Main Screen으로 확장해 Start/Settings를 제공한다. Result의 `RETRY RUN`은 전체 reset이고 Main으로 이동할 수 있다.

Result는 typed immutable `ResultViewState(run_id, run_epoch, terminal_reason, run_score, highest_stage_id, highest_ball_id, highest_ball_visual_key, optional_stats)`를 소비한다. Presentation은 같은 `run_id` 중복 표시와 stale `run_epoch`를 거부하고 결과 값을 계산하지 않는다.

### Pause/Settings UI Goal — required

2026-08-23 확정: Pause 모달 자체는 이미 구현 완료다. 이 초안의 Settings 범위는 실행 계획의 `S10_SETTINGS`(`S10-G1`~`S10-G4`)으로 분리하며, Pause를 재구현하지 않는다.

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
  → S5 최신 0~14 Ball data + non-contiguous 3-Stage mapping + Stage profile contract
  → S5-G4 Frame / Stage World / Shift
  → S6 FX tiers / cut-in / audio readability
  ├─ S7 Item Box data → physics → gateway → presentation → optional effects
  └─ Main/Pause/Settings UI + Stage Restart snapshot + Result integration
      → S8 Black Hole Phase L3 gameplay + run_epoch stale-event rejection + typed Final Result
  → S9 Web visual evidence
```

## 12. Lock and Ownership Rules

- Presentation은 자신의 Owned Files만 구현한다.
- `project.godot`, `scenes/main/main.tscn`, `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`는 Integration-owned다.
- 다른 lane의 API가 필요하면 Goal/contract request를 먼저 작성한다.
- dynamic Play Field처럼 여러 lane이 만나는 기능은 별도 Integration Goal과 file lock을 사용한다.
- 한 번에 Presentation lane `IN PROGRESS` Goal은 최대 하나다.

## 13. Recommended Next Presentation Goal

현재 S2-G2/G3/G4는 VERIFIED이고 S2-G1은 최신 catalog 재검증이 필요하다. 다음 Presentation Goal은 `S2-G5`이며 확정된 2인자 Merge event와 VERIFIED S2-G4 formatter를 사용한다. runtime 구현은 사용자가 명시적으로 승인했을 때만 시작한다.

V5 채택으로 Presentation은 keyframe/state sheet 제작을 진행할 수 있지만 runtime Goal의 의존 순서는 바뀌지 않는다. 특히 Merge numeric popup은 authoritative amount event가 없으면 제외한다.
