# Integration Contracts

> **STATUS: INITIAL / DRAFT**

정확한 Godot signal signature는 해당 Goal에서 확정한다. 아래는 소유 영역을 넘는 최소 계약이다.

| Producer | Contract | Consumer | 사용 목적 |
|---|---|---|---|
| Core Stage runtime | `stage_time_changed(time_left)` | Presentation HUD | 남은 시간 표시 |
| Core score ledger | `score_changed(stage_score, run_score)` | Presentation HUD | 점수 표시 |
| Core simulation | `cashout_completed(score_amount, global_level, world_position)` | Presentation, Integration, Content AudioManager | popup·StageRuntime local Time Bonus·audio event 선택 |
| Core simulation | `ball_merged(result_level, world_position)` — 2 arguments only | Presentation, Content AudioManager | Merge FX와 audio event 선택; score amount와 special type은 포함하지 않음 |
| Core simulation | `simulation_metrics_updated(metrics)` — read-only `active_balls/slot_capacity/free_slots/candidate_count/grid_cell_count/grid_bucket_capacity/grid_new_buckets/merges` | Presentation, Content/Systems | 성능 HUD와 release stress 측정; simulation state 수정 금지 |
| Core Stage runtime | `stage_ball_progression_changed(stage_id, ordered_global_levels, revealed_count)` | Presentation HUD | Stage 이름과 세로 5칸 공 족보의 progressive reveal |
| Core Stage runtime | `stage_clear_decided(reason)` | Presentation, Integration, Content AudioManager | Clear 표시·상태 잠금·audio event 선택 |
| Core Settlement → Integration StageManager | `final_settlement_started(amount: float)`, `final_settlement_finished(amount: float)` | Integration GameManager, Content AudioManager | SettlementService의 내부 신호를 StageManager가 한 번 전달한다. GameManager는 각각 `settlement_start`/`settlement_finish` audio event로만 매핑하며 점수·상태는 변경하지 않는다. |
| Integration StageManager | `stage_changed(stage_definition)` | Core, Presentation, Content Music | data 적용, Stage World와 BGM 변경 |
| Content screens | `start_requested`, `retry_requested`, `pause_requested`, `resume_requested`, `settings_requested`, `main_menu_requested` | Integration GameManager, Content Music | 시작, Pause modal 행동·화면 전환 요청과 BGM 상태 전환 |
| Content ItemManager | `item_planet_damaged(item_type: StringName, current_hits, required_hits, world_position)` | Presentation | hit별 균열·픽셀 파편 단계 표현 |
| Content ItemManager | `item_planet_broken(item_type: StringName, world_position)` | Presentation | 최종 파괴 FX. 이 신호 자체는 획득·CUT-IN·activation을 의미하지 않음 |
| Content ItemManager | `item_orb_spawned(item_type: StringName, world_position)` | Presentation | 아이템별로 구분되는 획득용 Orb 표시 |
| Content ItemManager | `item_collected(item_type: StringName, world_position)` | Presentation, Integration | Paddle 획득 뒤 CUT-IN과 1회 activation 중재 |
| Content ItemManager | `item_orb_missed(item_type: StringName, world_position)` | Presentation | 열린 하단 이탈 소멸 표현; activation 없음 |
| Content ItemManager | `active_items_changed(read_only_snapshot)` | Presentation HUD | 현재 활성 아이템 표시 |
| Integration StageManager | `stage_shift_started(next_definition, shift_id)` | Presentation | non-final Stage가 `clear_score`에 도달해 Final Settlement를 마친 직후 `SHIFTING` 진입과 함께 Stage World/HUD 연출을 시작한다. Presentation은 gameplay state를 직접 변경하지 않는다. |
| Presentation | `stage_shift_presentation_finished(shift_id)` → `StageManager.accept_stage_shift_presentation_finished(shift_id)` | Integration StageManager | matching `shift_id`일 때만 다음 Stage 진입 허용. 중복·stale 완료는 무시한다. S5-G3는 이 Presentation 완료 계약을 전제로 먼저 구현됐다. S5-G4 전 Main의 임시 adapter가 같은 API를 deferred 한 번 호출하며, Presentation 연결 시 Integration이 adapter를 제거한다. |
| Presentation | `visual_field_rect_changed(visual_rect: Rect2)` | Integration GameManager | Scale Shift와 Black Hole L2→L3 보간 중 프레임 내부의 장식용 Backdrop만 같은 visual rect로 갱신한다. Simulation·Paddle·Cashout logical rect와 Stage state는 이 신호로 변경하지 않는다. |
| Core Stage runtime | `black_hole_phase_started(phase_id, from_rect, to_rect)` | Integration, Presentation | 첫 Lv14→Black Hole 전환과 Galactic 내부 L2→L3 국면 시작; 새 Stage가 아님 |
| Presentation | `black_hole_phase_presentation_finished(phase_id)` | Integration StageManager | matching phase에서 logical L3 Rect 활성화와 Galactic gameplay 재개 허용. S8-G5 연결 전에는 Integration-owned 임시 adapter가 동일한 완료 API를 deferred 한 번 호출할 수 있으며 실제 producer 연결 시 제거한다. |
| Presentation | `black_hole_finale_presentation_finished()` | Integration GameManager | S8-G5의 Black Hole 공전·폭발 overlay가 끝난 뒤 Result UI를 한 번만 표시할 수 있게 한다. Integration은 terminal snapshot을 보존하고 이 완료 전에는 Result 표시·Retry/Main 입력을 열지 않는다. |
| Core simulation / Stage runtime | `black_hole_finale_started(contact_snapshot)` → `black_hole_finale_locked(result_snapshot)` | Integration, Presentation, Content/Systems | 두 Black Hole의 earliest contact를 simulation이 한 번 잠그고, Stage runtime이 `contact_position`, 두 Black Hole의 position/velocity/radius, `stage_index`, `stage_score`, `run_score`, `optional_stats.merge_count`, `optional_stats.run_time_seconds`를 읽기 전용 final result snapshot으로 확정한다. Integration은 이 신호 뒤 gameplay commit을 재개하지 않는다. |

### S8-G4 선행 Integration 골격

- S8-G2가 제공한 phase/finale/result schema가 확정되면 S8-G3/G5 완료 전에도 Integration-owned 파일의 signal routing과 state mediation을 구현할 수 있다.
- 임시 adapter는 실제 계약과 같은 `phase_id` 완료 API만 사용한다. Presentation 완료를 임의의 다른 상태 변경으로 우회하거나 Result UI가 표시된 것처럼 완료 증거를 만들지 않는다.
- Presentation과 Content/Systems는 각자의 Owned Files와 독립 test에서 실제 producer/consumer를 구현한다. Integration 골격 때문에 `scripts/presentation/**`, `scripts/ui/**`, `scenes/backgrounds/**`, `scenes/effects/**`를 잠그지 않는다.
- S8-G4의 최종 `IMPLEMENTED`/`VERIFIED` 판정은 임시 adapter를 제거하고 실제 S8-G3/G5 및 모든 reset API를 Main에 연결한 뒤에만 가능하다.

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
