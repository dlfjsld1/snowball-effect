# Integration Contracts

> **STATUS: INITIAL / DRAFT**

정확한 Godot signal signature는 해당 Goal에서 확정한다. 아래는 소유 영역을 넘는 최소 계약이다.

| Producer | Contract | Consumer | 사용 목적 |
|---|---|---|---|
| Core Stage runtime | `stage_time_changed(time_left)` | Presentation HUD | 남은 시간 표시 |
| Core score ledger | `score_changed(stage_score, run_score)` | Presentation HUD | 점수 표시 |
| Core simulation | `cashout_completed(score_amount, global_level, world_position)` | Presentation, Integration, Content AudioManager | popup·StageRuntime local Time Bonus·audio event 선택 |
| Core simulation | `ball_merged(result_level, world_position)` — 2 arguments only | Presentation, Content AudioManager | Merge FX와 audio event 선택; score amount와 special type은 포함하지 않음 |
| Core Stage runtime / simulation | `first_contact_discovered(payload: Dictionary)` v1 | Integration S6-G2I | committed Merge 결과 중 승인된 local Lv3/Lv4 identity의 Run-scoped discovery. Presentation은 이 신호를 직접 구독하지 않는다. |
| Integration S6-G2I | `play_first_contact_cutin(payload: Dictionary) -> bool` | Presentation S6-G2 | current Run과 payload를 검증하고 gameplay pause lock을 먼저 획득한 뒤에만 visible CUT-IN을 요청한다. |
| Presentation S6-G2 | `first_contact_cutin_finished(event_id: int, run_epoch: int)` | Integration S6-G2I | exit/dim restore가 끝난 matching visible CUT-IN 완료. gameplay resume나 Black Hole Phase를 직접 실행하지 않는다. |
| Core simulation | `simulation_metrics_updated(metrics)` — read-only `active_balls/slot_capacity/free_slots/candidate_count/grid_cell_count/grid_bucket_capacity/grid_new_buckets/merges` | Presentation, Content/Systems | 성능 HUD와 release stress 측정; simulation state 수정 금지 |
| Core Stage runtime | `stage_ball_progression_changed(stage_id, ordered_global_levels, revealed_count)` | Presentation HUD | Stage 이름과 세로 5칸 공 족보의 progressive reveal |
| Core Stage runtime | `stage_clear_decided(reason)` | Presentation, Integration, Content AudioManager | Clear 표시·상태 잠금·audio event 선택 |
| Core Settlement → Integration StageManager | `final_settlement_started(amount: float)`, `final_settlement_finished(amount: float)` | Integration GameManager, Content AudioManager | SettlementService의 내부 신호를 StageManager가 한 번 전달한다. GameManager는 각각 `settlement_start`/`settlement_finish` audio event로만 매핑하며 점수·상태는 변경하지 않는다. |
| Presentation EffectManager | `final_settlement_presentation_finished()` | Presentation HUD·verification | 최대 0.5초의 batch dissolve·Stage Score count-up 완료 알림. Core `Final Settlement → CLEARED`를 지연시키거나 gameplay state를 변경하지 않는 read-only presentation completion이다. S5-G6의 확인 대기는 Settlement logic이 아니라 `CLEARED→SHIFTING` 경계에만 적용한다. |
| Integration StageManager | `stage_changed(stage_definition)` | Core, Presentation, Content Music | data 적용, Stage World와 BGM 변경 |
| Content screens | `start_requested`, `retry_requested`, `pause_requested`, `resume_requested`, `settings_requested`, `main_menu_requested` | Integration GameManager, Content Music | 시작, Pause modal 행동·화면 전환 요청과 BGM 상태 전환 |
| Content ItemManager | `item_planet_spawned(item_type: StringName, world_position, radius)` | Content S7-G2 Blizzard visual | Blizzard Item Ball의 최초 표시용 read-only 신호. spawn/score/simulation을 변경하지 않는다. |
| Content ItemManager | `item_planet_damaged(item_type: StringName, current_hits, required_hits, world_position)` | Presentation, Content S7-G2 Blizzard visual | hit별 균열·픽셀 파편 단계 표현 |
| Content ItemManager | `item_planet_broken(item_type: StringName, world_position)` | Presentation, Content S7-G2 Blizzard visual | 최종 파괴 FX. 이 신호 자체는 획득·CUT-IN·activation을 의미하지 않음 |
| Content ItemManager | `item_orb_spawned(item_type: StringName, world_position)` | Presentation, Content S7-G2 Blizzard visual | 아이템별로 구분되는 획득용 Orb 표시 |
| Content ItemManager | `item_collected(item_type: StringName, world_position)` | Presentation, Integration | Paddle 획득 뒤 CUT-IN과 1회 activation 중재 |
| Content ItemManager | `item_orb_missed(item_type: StringName, world_position)` | Presentation | 열린 하단 이탈 소멸 표현; activation 없음 |
| Content ItemManager | `active_items_changed(read_only_snapshot)` | Presentation HUD | 현재 활성 아이템 표시 |
| Integration ItemEffectGateway | `item_cutin_requested(event_id: int, item_type: StringName, world_position)` | Presentation S6-G2 | Orb 획득 뒤에만 CUT-IN을 요청한다. Item Ball 파괴는 이 요청을 만들지 않는다. |
| Presentation S6-G2 | `GameManager.accept_item_cutin_activation_cue(event_id)` 또는 `skip_item_cutin(event_id)` | Integration ItemEffectGateway | matching event만 1회 activation request로 commit한다. cue/skip 중복과 Retry 이전 stale event는 거부한다. |
| Integration ItemEffectGateway | `item_effect_activation_requested(event_id: int, item_type: StringName, world_position)` | Content S7-G2~G4 | 실제 Blizzard/Fire Core/Magnet 효과의 유일한 activation request다. Gateway는 점수·Settlement·simulation을 직접 변경하지 않는다. |
| Content S7-G2 Blizzard | `activate(item_blizzard.tres)`, `advance(delta)`, `reset_runtime()`; `spawn_multiplier_changed(multiplier)` | Integration spawn controller | matching Blizzard activation만 수락한다. Integration은 base Stage spawn rate에 multiplier를 한 번 적용하고 `1.0`에서 정확히 복구한다. 재획득은 남은 시간을 갱신할 뿐 multiplier를 누적하지 않는다. |
| Content S7-G2 Blizzard | `active_state_changed(snapshot)` | Content-owned Blizzard visual, Integration Main wiring | Blizzard 전용 `BLIZZARD!` cue와 장식 눈은 active snapshot만 read-only로 소비한다. Item Ball/Orb의 Blizzard styling은 producer events만 표시하며 activation, score, timer, spawn multiplier를 변경하지 않는다. |
| Integration StageManager | `stage_clear_ready(clear_snapshot: Dictionary, clear_id: int)` | Presentation S5-G6 | non-final `SCORE_CLEAR`의 Final Settlement 완료 뒤 `CLEARED`에서 read-only snapshot과 process-lifetime monotonic ID를 한 번 공개한다. Galactic/failure/Result에는 발행하지 않는다. |
| Presentation S5-G6 | `next_stage_requested(clear_id: int)` | Integration S5-G6I | 현재 열린 Clear의 실제 `NEXT STAGE` Button 첫 press만 request한다. Presentation은 Shift, Stage, score, timer, spawn, Paddle 또는 simulation을 변경하지 않는다. |
| Integration StageManager | `stage_shift_started(next_definition, shift_id)` | Presentation | matching `next_stage_requested(clear_id)`가 수락된 뒤 새 `shift_id`로 `SHIFTING`에 진입하고 Stage World/HUD 연출을 시작한다. Presentation은 gameplay state를 직접 변경하지 않는다. |
| Presentation | `stage_shift_presentation_finished(shift_id)` → `StageManager.accept_stage_shift_presentation_finished(shift_id)` | Integration StageManager | matching `shift_id`일 때만 다음 Stage 진입 허용. 중복·stale 완료는 무시하며 실제 Presentation producer가 연결된 현재 Main에는 임시 adapter가 없다. |
| Presentation | `visual_field_rect_changed(visual_rect: Rect2)` | Integration GameManager | Scale Shift와 Black Hole L2→L3 보간 중 프레임 내부의 장식용 Backdrop만 같은 visual rect로 갱신한다. Simulation·Paddle·Cashout logical rect와 Stage state는 이 신호로 변경하지 않는다. |
| Core Stage runtime | `black_hole_phase_started(phase_id, from_rect, to_rect)` | Integration, Presentation | 첫 Lv14→Black Hole 전환과 Galactic 내부 L2→L3 국면 시작; 새 Stage가 아님 |
| Presentation | `black_hole_phase_presentation_finished(phase_id)` | Integration StageManager | matching phase에서 logical L3 Rect 활성화와 Galactic gameplay 재개 허용. 현재 Main은 실제 S8-G5 producer를 사용하며 임시 adapter가 없다. |
| Presentation | `black_hole_finale_presentation_finished()` | Integration GameManager | S8-G5의 Black Hole 공전·폭발 overlay가 끝난 뒤 Result UI를 한 번만 표시할 수 있게 한다. Integration은 terminal snapshot을 보존하고 이 완료 전에는 Result 표시·Retry/Main 입력을 열지 않는다. |
| Core simulation / Stage runtime | `black_hole_finale_started(contact_snapshot)` → `black_hole_finale_locked(result_snapshot)` | Integration, Presentation, Content/Systems | 두 Black Hole의 earliest contact를 simulation이 한 번 잠그고, Stage runtime이 `contact_position`, 두 Black Hole의 position/velocity/radius, `stage_index`, `stage_score`, `run_score`, `optional_stats.merge_count`, `optional_stats.run_time_seconds`를 읽기 전용 final result snapshot으로 확정한다. Integration은 이 신호 뒤 gameplay commit을 재개하지 않는다. |

### FIRST_CONTACT discovery·CUT-IN 계약

#### 권위와 API

- Integration `GameManager`가 process lifetime에서 단조 증가하는 `run_epoch`를 발급한다. Initial Start, Retry Run, Main에서 새 Start는 각각 새 epoch를 사용한다. Main 이동은 현재 epoch를 즉시 무효화하며 다음 Start 전에는 active Run이 없다.
- Core는 `begin_first_contact_run(run_epoch: int) -> bool`로 새 Run을 열고 `invalidate_first_contact_run(run_epoch: int) -> bool`로 matching Run만 닫는다. Stage 변경은 Run을 닫거나 seen set을 초기화하지 않는다. 같은 값·더 작은 값의 begin, wrong/stale invalidate는 `false`이며 현재 state를 바꾸지 않는다.
- Core의 `event_id`는 FIRST_CONTACT namespace 안에서 process lifetime monotonic이며 Retry/Main에서 되감지 않는다. Item CUT-IN `event_id`, `clear_id`, `shift_id`, S8 `phase_id`와 별도 namespace다.
- Integration public acceptance는 `accept_first_contact_discovery(payload: Dictionary) -> bool`와 `accept_first_contact_cutin_finished(event_id: int, run_epoch: int) -> bool`다. 둘 다 current epoch와 active/head event exact match에서만 state를 바꾼다.

#### payload v1

`first_contact_discovered(payload)`는 새 Dictionary/value copy로 전달하며 다음 필드를 모두 가진다. 필드 누락, type 불일치, 알려지지 않은 `schema_version`, roster/level 불일치는 거부한다.

| 필드 | Godot type | v1 의미 |
|---|---|---|
| `schema_version` | `int` | 항상 `1` |
| `event_id` | `int` | FIRST_CONTACT process-lifetime monotonic ID |
| `run_epoch` | `int` | 현재 authoritative Run generation |
| `stage_index` | `int` | Ground `0`, Planetary `1`, Galactic `2` |
| `stage_id` | `StringName` | `ground`, `planetary`, `galactic` |
| `global_level` | `int` | 실제 committed Merge 결과의 global level |
| `local_level` | `int` | 승인 대상인 `3` 또는 `4` |
| `world_position` | `Vector2` | Merge 결과가 commit된 world 위치 |
| `first_contact_id` | `StringName` | 아래 roster의 안정된 Presentation/중복 억제 identity |
| `handoff_kind` | `StringName` | `RESUME_PLAYING` 또는 `BLACK_HOLE_PHASE` |
| `black_hole_entity_ordinal` | `int` | 일반 identity는 `0`, 첫 Black Hole만 `1` |

| `first_contact_id` | Stage/global/local | `handoff_kind` |
|---|---|---|
| `ground_giant_snowball` | Ground / `3` / `3` | `RESUME_PLAYING` |
| `ground_moon` | Ground / `4` / `4` | `RESUME_PLAYING` |
| `planetary_supernova` | Planetary / `8` / `3` | `RESUME_PLAYING` |
| `planetary_galaxy` | Planetary / `10` / `4` | `RESUME_PLAYING` |
| `galactic_event_horizon` | Galactic / `13` / `3` | `RESUME_PLAYING` |
| `galactic_black_hole` | Galactic / `14` / `4` | `BLACK_HOLE_PHASE` |

Black Hole payload에는 mutable entity position/velocity, `phase_id`, `from_rect`, `to_rect`를 복사하지 않는다. 첫 entity가 이미 commit됐다는 `black_hole_entity_ordinal=1`과 handoff 의도만 전달한다. 실제 entity state와 field rect는 기존 S8 source가 소유하고, `phase_id`와 rect handoff는 matching CUT-IN 완료 뒤 기존 `begin_black_hole_phase(from_rect, to_rect)`가 생성한다.

#### producer 순서와 중복 보장

```text
Merge result/entity commit
→ ball_merged(result_level, world_position)
→ eligible + unseen이면 event_id 할당과 first_contact_discovered(payload)
→ tick의 나머지 Cashout/종료 중재 완료
→ Integration arbitration
→ pause lock accepted
→ play_first_contact_cutin(payload)
```

- Core는 current Run의 `first_contact_id` seen set을 source of truth로 사용한다. 한 Run에서 같은 identity는 Merge 수와 무관하게 한 번만 emit하고, 새 epoch에서만 다시 eligible하다.
- Moon과 Galaxy가 다음 Stage local Lv0로 재등장해도 emit하지 않는다. roster 밖 global/local 조합과 direct spawn/debug injection은 해당 Goal verification에서 명시적으로 허용한 committed discovery 경로가 아니면 emit하지 않는다.
- 같은 tick에 서로 다른 identity가 생기면 deterministic Merge commit 순서로 `event_id`를 할당한다. Integration은 distinct current-run event를 event-id FIFO로 보관하고 head event 완료만 수락한다. queue는 승인 roster 여섯 identity보다 커질 수 없다.
- 기존 `ball_merged`는 stage/local/run/id가 없는 FX/audio 신호라 FIRST_CONTACT source로 추론하지 않는다. `top_ball_created`는 local Lv3를 표현하지 못하고 Black Hole 경로에서 생략될 수 있으므로 역시 source가 아니다.
- 첫 entity의 기존 `black_hole_phase_requested`는 S8 readiness로 남길 수 있지만 GameManager가 이를 직접 Phase 시작으로 소비하던 경로는 S6-G2I에서 supersede한다. readiness가 먼저 와도 matching CUT-IN finish 전에는 `begin_black_hole_phase`와 `black_hole_phase_started`가 0회여야 한다.

#### pause·resume·무효화 lifecycle

Integration은 discovery signal callback 안에서 즉시 Panel을 보이지 않는다. 같은 physics tick의 Merge/Cashout/`SCORE_CLEAR`/`TIME_UP` 중재를 끝낸 뒤 다음 visible frame 전에 current state를 다시 확인한다.

| 상황 | Integration 동작 | Presentation / 다음 상태 |
|---|---|---|
| current epoch + `PLAYING` + valid head | timer, spawn, simulation commit, Paddle physics/gameplay input을 잠근 뒤 호출 | 그 뒤에만 visible CUT-IN 시작 |
| 일반 5종 matching finish | queue 다음 event가 있으면 lock 유지, 없으면 lock 해제 | 같은 Stage `PLAYING` 재개 |
| 첫 Black Hole matching finish | CUT-IN lock을 풀어 gameplay를 한 frame 재개하지 않고 S8 Phase lock으로 이전 | 기존 `begin_black_hole_phase` 1회, 이후 S8-G4 `phase_id` 흐름 |
| wrong/stale/duplicate finish | `false`, queue/lock/state 불변 | resume·Phase·signal 재발행 없음 |
| 같은 tick 뒤 `CLEAR_LOCKED`, `TIME_UP_LOCKED`, `FAILED`, `RUN_ENDED`, Result/Shift | discovery를 visible queue에 수락하지 않음 | CUT-IN/Panel 없음; authoritative outcome 우선 |
| Retry / Main / fresh Run | old epoch와 queue/active lock 무효화, gameplay freeze 해제, `reset_first_contact_cutin(old_epoch)` | Tween/Panel hide, stale completion 없음; fresh Run은 새 epoch |

pause lock은 SceneTree 전체 pause가 아니다. CUT-IN Tween/CanvasLayer와 Retry/Main cleanup handler는 계속 동작하고, timer·spawn·simulation commit·Paddle physics/gameplay input을 막는다. 중첩 Pause/Resume, Result/Failure UI, Stage Clear Panel, Scale Shift는 이 lock에서 시작하지 않는다. Galactic에서는 Event Horizon과 첫 Black Hole identity만 유효하다.

#### Presentation 경계

- Presentation은 Integration이 전달한 payload의 `first_contact_id`로 공통 background 하나와 공별 title/portrait layer만 조립한다. Core/Stage/Simulation 노드를 조회하거나 seen set·phase state를 계산하지 않는다.
- `play_first_contact_cutin(payload) -> bool`는 이미 active/completed인 `(run_epoch, event_id)`, wrong schema/identity, reset된 epoch를 거부한다. `first_contact_cutin_finished(event_id, run_epoch)`는 정상 exit/dim restore 뒤 한 번만 emit한다.
- `reset_first_contact_cutin(run_epoch)`은 matching 또는 이전 visual을 즉시 숨기고 Tween/callback을 취소하지만 completion을 만들지 않는다. reduced-effects는 모션만 줄이고 identity와 completion semantics를 유지한다.
- 이 FIRST_CONTACT 계약은 S7 Item Orb CUT-IN의 activation cue/skip namespace를 변경하지 않는다. 공 discovery 완료 signal을 item activation으로 전달하지 않는다.

### S5-G6 / S5-G6I Clear 확인 계약

- 성공 순서는 `SCORE_CLEAR → CLEAR_LOCKED → SETTLING → CLEARED (awaiting matching Next Stage) → SHIFTING`이다. Clear 판정과 Settlement는 즉시 처리하고 Scale Shift 시작만 확인 뒤로 미룬다.
- `clear_snapshot` 필드는 `stage_index`, `stage_display_name`, `stage_score`, `run_score`, `outcome=&"CLEARED"`, `is_final_stage=false`다. Integration이 Settlement 뒤 authoritative outcome을 새 Dictionary/deep-copy value로 제공하며 Presentation은 다시 deep copy한다.
- `clear_id`는 정산 완료 Clear request/acceptance용이다. `shift_id`는 그 요청이 수락된 뒤 Scale Shift presentation completion용으로 발급한다. 별도 namespace이므로 같은 값이어도 의미상 일치로 취급하지 않는다.
- future Integration consumer의 `request_next_stage(clear_id) -> bool`는 current state가 `CLEARED`, pending ID가 exact match, 아직 미소비, next Stage가 존재할 때만 `true`다. wrong/stale/duplicate request는 state, pending snapshot과 두 ID sequence를 바꾸지 않는다.
- `CLEAR_LOCKED`부터 다음 Stage 진입까지 timer, spawn, Paddle, simulation과 gameplay input은 잠긴다. UI는 SceneTree pause와 분리해 실제 Button focus와 keyboard/mouse/Web input을 계속 받는다.
- Panel public API는 `show_stage_clear(snapshot, clear_id)`, `hide_stage_clear(clear_id)`, `reset_for_new_run()`, `set_reduced_effects(enabled)`다. hidden input, stale callback과 이미 발행한 active ID는 signal을 다시 내지 않는다.
- Scale Shift 시작 시 matching `hide_stage_clear(clear_id)`를 호출한다. Retry/Main Screen/fresh Run은 pending Clear를 무효화하고 `reset_for_new_run()`을 호출한다. numeric clear ID sequence는 process lifetime에서 재사용하지 않는다.
- Galactic, `FAILED`, Time Up Result, Black Hole finale와 Result UI에는 Panel을 열지 않는다. reduced-effects는 motion/pulse만 제거하고 snapshot 내용, focus와 1회 request를 유지한다.
- 2026-08-20 automatic `Final Settlement → CLEARED → SHIFTING` wiring evidence는 당시 계약의 역사로 남지만 최신 완료 근거가 아니다. S5-G6I는 이 계약에 맞는 Integration 구현과 회귀가 끝날 때까지 `PENDING`이다.

### S8-G4 Integration 연결 계약

- S6-G2I 연결 뒤 `GameManager`는 첫 Black Hole의 matching `first_contact_cutin_finished(event_id, run_epoch)` 전에는 `begin_black_hole_phase`를 호출하지 않는다. 완료 수락 시 CUT-IN lock을 S8 Phase lock으로 직접 이전하고 그때 발급된 `phase_id`부터 아래 기존 S8-G4 계약을 사용한다.
- `GameManager`는 `black_hole_phase_started(phase_id, from_rect, to_rect)`를 실제 `PresentationManager.play_black_hole_phase(...)`에 전달하고, matching `black_hole_phase_presentation_finished(phase_id)`만 `StageManager`에 수락시킨다.
- Presentation의 `visual_field_rect_changed(Rect2)`는 전환 중 장식 Backdrop만 동기화한다. logical L3 Rect는 matching phase 완료 뒤 Core/Integration 경로에서 한 번 활성화한다.
- `black_hole_finale_locked(result_snapshot)`은 Integration이 terminal snapshot을 보관하고 S8-G5 finale를 시작하는 입력이다. no-argument `black_hole_finale_presentation_finished()` 뒤에만 같은 snapshot을 S8-G3 Result에 한 번 전달한다.
- Presentation은 run generation과 active/completed 상태로 canceled Tween, duplicate phase ID, duplicate terminal snapshot을 차단한다. Integration은 별도로 terminal snapshot publish-once 잠금을 유지한다.
- Retry와 Main Screen handler는 `PresentationManager.reset_black_hole_presentation()`을 호출한다. 이 API는 Presentation Tween/visual/generation만 초기화하며 Core·Stage·Result state를 변경하지 않는다.
- 기존 S8-G4 `VERIFIED` evidence는 `black_hole_phase_started` 이후의 downstream과 finale/Retry를 계속 증명한다. FIRST_CONTACT 이전 Phase 금지는 S6-G2I가 별도 검증하며 과거 evidence에 소급하지 않는다.

## S6 FX·audio ownership

- Content/Systems는 S6-G1, S6-G3, S6-G4, S6-G5를 소유한다. S6-G1의 대상은 `scripts/presentation/effect_manager.gd`, `scenes/effects/**`, `assets/particles/**`, `tests/content/s6_g1_**`이며, S6-G3/G4/G5의 대상은 `assets/audio/**`, `resources/audio/**`, `scripts/presentation/audio_manager.gd`다.
- Content AudioManager는 기존 gameplay event를 read-only로 구독하고 S6-G3 catalog의 event key를 재생한다. 점수·타이머·Stage 상태를 변경하거나 새 gameplay signal을 만들지 않는다.
- Content/Systems는 S6-G1에서 시각 FX의 event tier와 budget을 확정한다. tier-to-audio-key 매핑, priority/polyphony, Web 첫 입력 이후 audio 활성화도 Content/Systems가 구현한다. Presentation은 S6-G2 CUT-IN과 화면 연출을 소유한다.
- S6-G1이 완료되기 전에는 필수 audio key 목록을 확정하거나 S6-G3/G4를 `IN PROGRESS` 또는 완료로 변경하지 않는다.

### S6-G1 FX priority contract

- 일반 Merge/Cashout의 tier source of truth는 `BallDefinition.fx_tier`다. 두 이벤트는 같은 budget 경로를 사용하고 gameplay score/state를 변경하지 않는다.
- Cashout gameplay event의 원본 `world_position`은 유지하되, 시각 effect anchor는 완전히 열린 하단 경계를 지난 고등급 공도 popup이 보이고 하단 cabinet과 겹치지 않도록 viewport 하단 96px 안쪽으로 제한한다.
- gameplay priority는 tier 0~4 순서로 `10/25/40/55/65`, 동시 active 상한은 `12/8/4/2/1`, 한 render frame spawn 상한은 `4/4/3/2/1`이다. 전체 gameplay FX active 상한은 `24`다.
- 상태 이벤트 우선도는 Final Settlement `70`, Stage Clear `80`, Scale Shift `85`, Black Hole Phase `90`, Stage Fail/Run End `95`, Black Hole Finale `100`이다.
- Transition 숫자는 동시 표현 충돌과 gameplay FX 정리에 쓰며 상태 진행을 재정렬하지 않는다. 따라서 권위 있는 Stage source의 `Stage Clear(80) → Final Settlement(70) → Scale Shift(85)`는 숫자가 단조 증가하지 않아도 작성된 상태 순서대로 모두 전달한다. 단조 승격 규칙은 Terminal 잠금에 적용한다.
- `EffectManager.priority_event_reserved(event_key, priority)`는 상위 Presentation에 표현 slot이 예약됐음을 알리는 read-only 신호다. S6-G1은 CUT-IN·Scale Shift·Black Hole finale 자체를 실행하지 않는다.
- Transition 예약은 낮은 gameplay FX를 정리하고 새 Merge/Cashout FX를 억제한다. `resume_gameplay_fx()` 후에만 다시 허용한다. Terminal 예약은 일반 resume으로 해제되지 않고, 비-Terminal 이벤트나 낮거나 같은 Terminal 이벤트가 덮어쓰지 못한다. 더 높은 Terminal만 승격할 수 있다. 권위 있는 Stage source가 Terminal 뒤 `PLAYING`으로 재진입하면 `EffectManager`가 FX와 Run 단위 진단 카운터를 초기화한다. 또한 `stage_changed`의 Stage index가 이전과 같거나 낮아지는 Retry/Restart도 동일하게 초기화한다. 더 높은 index로 이동하는 일반 Stage Shift와 `stage_changed` 없이 같은 Galactic을 재개하는 Black Hole Phase는 카운터를 유지한다.
- S6-G3/G4는 이 priority/tier를 audio key와 polyphony 정책의 입력으로 사용하되 시각 budget 수치를 오디오 재생 수로 그대로 복제하지 않는다.

### S6-G5 BGM contract

- Content Music은 기존 `stage_changed`, Content screen request, `black_hole_phase_started`, `black_hole_finale_locked`와 terminal/Main Menu/Retry 흐름을 read-only로 소비한다. 새로운 gameplay signal이나 Integration-owned 파일 변경을 요구하지 않는다.
- music channel에는 `bgm_title`, `bgm_ground`, `bgm_planetary`, `bgm_galactic`, `bgm_pause`, `bgm_result` 중 하나만 활성화한다. Pause는 현재 Stage BGM을 정지하고 track key·재생 위치를 저장하며, Resume는 저장 위치에서 동일 track을 재개한다.
- Black Hole Phase는 `bgm_galactic`을 정지하고 기존 `black_hole_loop`만 활성화한다. Final Result, Retry, Main Menu, terminal reset은 이전 BGM/loop를 정리하고 authoritative 상태의 track만 선택한다.
- Web 첫 사용자 입력 전에는 BGM을 자동 재생하지 않는다. unlock 뒤 현재 상태의 track을 시작하거나 재개하며, BGM은 점수·타이머·Stage state를 변경하지 않는다.

## Integration Goal 조건

다음 중 하나라도 해당하면 별도 Integration lane을 사용한다.

- Integration-owned 파일 변경
- 두 Owner 이상의 결과를 한 scene/state flow에 연결
- Signal signature 또는 호출 순서 변경
- Retry가 여러 runtime state를 초기화
- StageDefinition을 runtime과 Presentation에 동시에 연결
- Settlement 완료와 Scale Shift presentation을 중재

## Lock

- 활성 Integration Goal과 대상 파일은 `docs/goals/STATUS.md`에 기록한다.
- 잠긴 파일은 다른 lane이 직접 수정하지 않는다.
- Integration 검증이 끝나면 lock을 해제하고 Evidence를 남긴다.
- 이 규칙은 초기안이며 병목이 생기면 파일을 더 작은 coordinator로 분리할 수 있다.
