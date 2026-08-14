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
| Core Settlement | `final_settlement_started(amount)`, `final_settlement_finished(amount)` | Presentation, Integration, Content AudioManager | 정산 연출·완료 중재·audio event 선택 |
| Integration StageManager | `stage_changed(stage_definition)` | Core, Presentation | data 적용과 Stage World 변경 |
| Content screens | `start_requested`, `retry_requested`, `pause_requested`, `resume_requested`, `settings_requested`, `main_menu_requested` | Integration GameManager | 시작, Pause modal 행동과 화면 전환 요청 |
| Content ItemManager | `item_planet_damaged(item_type, current_hits, required_hits, world_position)` | Presentation | hit별 균열·픽셀 파편 단계 표현 |
| Content ItemManager | `item_planet_broken(item_type, world_position)` | Presentation, Integration | 최종 파괴 FX, CUT-IN과 1회 activation 중재 |
| Content ItemManager | `active_items_changed(read_only_snapshot)` | Presentation HUD | 현재 활성 아이템 표시 |
| Integration StageManager | `stage_shift_started(next_definition, shift_id)` | Presentation | `SHIFTING` 진입 뒤 Stage World/HUD 연출 시작 요청. Presentation은 gameplay state를 직접 변경하지 않는다. |
| Presentation | `stage_shift_presentation_finished(shift_id)` → `StageManager.accept_stage_shift_presentation_finished(shift_id)` | Integration StageManager | matching `shift_id`일 때만 다음 Stage 진입 허용. 중복·stale 완료는 무시한다. S5-G3는 이 Presentation 완료 계약을 전제로 먼저 구현됐다. S5-G4 전 Main의 임시 adapter가 같은 API를 deferred 한 번 호출하며, Presentation 연결 시 Integration이 adapter를 제거한다. |
| Core Stage runtime | `black_hole_phase_started(phase_id, from_rect, to_rect)` | Integration, Presentation | 첫 Lv14→Black Hole 전환과 Galactic 내부 L2→L3 국면 시작; 새 Stage가 아님 |
| Presentation | `black_hole_phase_presentation_finished(phase_id)` | Integration StageManager | matching phase에서 logical L3 Rect 활성화와 Galactic gameplay 재개 허용 |
| Core simulation / Stage runtime | `black_hole_finale_started(contact_snapshot)` → `black_hole_finale_locked(result_snapshot)` | Integration, Presentation, Content/Systems | 두 Black Hole의 earliest contact를 simulation이 한 번 잠그고, Stage runtime이 `contact_position`, 두 Black Hole의 position/velocity/radius, `stage_index`, `stage_score`, `run_score`를 읽기 전용 final result snapshot으로 확정한다. Integration은 이 신호 뒤 gameplay commit을 재개하지 않는다. |

## S6 audio ownership

- Content/Systems는 S6-G3과 S6-G4를 함께 소유한다. `assets/audio/**`, `resources/audio/**`, `scripts/presentation/audio_manager.gd`가 대상이다.
- Content AudioManager는 기존 gameplay event를 read-only로 구독하고 S6-G3 catalog의 event key를 재생한다. 점수·타이머·Stage 상태를 변경하거나 새 gameplay signal을 만들지 않는다.
- Presentation은 S6-G1에서 시각 FX의 event tier만 확정한다. tier-to-audio-key 매핑, priority/polyphony, Web 첫 입력 이후 audio 활성화는 Content가 구현한다.
- S6-G1이 완료되기 전에는 필수 audio key 목록을 확정하거나 S6-G3/G4를 `IN PROGRESS` 또는 완료로 변경하지 않는다.

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
