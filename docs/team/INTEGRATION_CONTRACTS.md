# Integration Contracts

> **STATUS: INITIAL / DRAFT**

정확한 Godot signal signature는 해당 Goal에서 확정한다. 아래는 소유 영역을 넘는 최소 계약이다.

| Producer | Contract | Consumer | 사용 목적 |
|---|---|---|---|
| Core Stage runtime | `stage_time_changed(time_left)` | Presentation HUD | 남은 시간 표시 |
| Core score ledger | `score_changed(stage_score, run_score)` | Presentation HUD | 점수 표시 |
| Core simulation | `cashout_completed(score_amount, local_level, world_position)` | Presentation, Integration | popup과 Stage Time Bonus 반영 |
| Core simulation | `ball_merged(result_level, world_position)` | Presentation | Merge FX |
| Core Stage runtime | `stage_clear_decided(reason)` | Presentation, Integration | Clear 표시와 상태 잠금 |
| Core Settlement | `final_settlement_started/finished(amount)` | Presentation, Integration | 정산 연출과 완료 중재 |
| Integration StageManager | `stage_changed(stage_definition)` | Core, Presentation | data 적용과 Stage World 변경 |
| Content screens | `start_requested`, `retry_requested`, `pause_requested`, `resume_requested`, `settings_requested`, `main_menu_requested` | Integration GameManager | 시작, Pause modal 행동과 화면 전환 요청 |
| Content ItemManager | `item_planet_damaged(item_type, current_hits, required_hits, world_position)` | Presentation | hit별 균열·픽셀 파편 단계 표현 |
| Content ItemManager | `item_planet_broken(item_type, world_position)` | Presentation, Integration | 최종 파괴 FX, CUT-IN과 1회 activation 중재 |
| Content ItemManager | `active_items_changed(read_only_snapshot)` | Presentation HUD | 현재 활성 아이템 표시 |
| Presentation | `stage_shift_presentation_finished` | Integration StageManager | 다음 Stage 진입 허용 |

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
