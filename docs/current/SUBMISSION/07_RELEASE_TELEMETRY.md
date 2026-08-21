# Release Telemetry Record

S9-G1은 Stage 시간을 임의로 제한하거나 수치를 추정해 조정하지 않는다. 이 문서는 실제 플레이 표본을 기록하고, 다음 tuning 결정을 재현 가능하게 만든다.

## 측정 계약

한 표본은 Title에서 Start를 누른 뒤 Result 또는 Retry/Main까지의 한 Run이다. 다음 값은 gameplay state를 변경하지 않는 read-only 관찰로 기록한다.

| Field | Source | Meaning |
|---|---|---|
| environment | Browser/OS/device, build identifier | 결과를 비교할 실행 환경 |
| stage_index / stage_name | `StageManager.stage_changed` | Stage 구분 |
| playing_dwell_seconds | `StageManager.get_runtime_snapshot().run_time_seconds`의 Stage 전후 차 | Shift, Pause, Result 체류 시간은 제외 |
| cashouts_total | `BallSimulationManager.cashout_completed` | 해당 Stage의 Active Cashout 횟수 |
| cashouts_by_local_level | Cashout `global_level`을 현재 `StageDefinition.local_ball_levels`에서 lookup | local Lv0~4 별 Cashout 횟수 |
| time_bonus_total_seconds | `StageDefinition.time_bonus_by_local_level[local_level]` 합계 | Cashout으로 실제 획득한 시간 |
| start_time / end_time | `StageManager.get_runtime_snapshot()` | Stage timer 변화와 Time Up/Score Clear 맥락 |
| active_ball_peak / candidates_peak / grid_cells_peak | `simulation_metrics_updated` | late-game 밀도와 병목 맥락 |
| terminal_reason | `stage_state_changed`와 terminal snapshot | Score Clear, Time Up, Black Hole finale 또는 Run End |

`global_level`이 현재 Stage chain에 없으면 그 표본은 data/runtime 오류로 중단한다. 계산용 local level 사본이나 gameplay event를 만들지 않는다.

## 현재 데이터 기준선 — 변경 없음

| Stage | Base time | Clear score | Spawn rate | Time bonus (local Lv0→4) |
|---|---:|---:|---:|---|
| Ground | 45 s | 4e8 | 6/s | 0, 0.25, 0.5, 1, 2 s |
| Planetary | 40 s | 4e25 | 15/s | 0, 0.25, 0.5, 1, 2 s |
| Galactic | 35 s | N/A | 35/s | 0, 0.25, 0.5, 1, 2 s |

현재 기준선에는 time cap이 없다. 이번 Goal에서 새로운 cap이나 StageDefinition 값 변경은 하지 않는다. 최소 두 개의 자연 플레이 표본에서 Stage 체류·Cashout·획득 시간 분포를 비교한 뒤에만 별도 tuning 제안을 만든다.

## 기록 표

| Run | Environment/build | Stage | Dwell | Cashouts L0/L1/L2/L3/L4 | Bonus time | Peak balls | Candidate/grid peak | Terminal | Notes |
|---|---|---|---:|---|---:|---:|---:|---|---|
| 1 | Godot 4.7.1 Desktop, Primary runtime | Ground | 40.37 s | 70/6/7/2/4 | 15.00 s | 44 | 19/42 | Time Up → Settlement Clear | 45 + 15 − 40.37 = 19.63 s |
| 1 | Godot 4.7.1 Desktop, Primary runtime | Planetary | 26.75 s | 122/25/10/2/4 | 21.25 s | 87 | 45/83 | Score Clear | 40 + 21.25 − 26.75 = 34.50 s |
| 1 | Godot 4.7.1 Desktop, Primary runtime | Galactic | 34.63 s | 235/89/23/6/5 | 49.75 s | 153 | 109/147 | Run End | 35 + 49.75 − 34.63 = 50.12 s |
| 2 | Godot 4.7.1 Desktop, Primary runtime | Ground | 45.88 s | 67/18/7/2/4 | 18.00 s | 44 | 16/42 | Score Clear | 45 + 18 − 45.88 = 17.12 s |
| 2 | Godot 4.7.1 Desktop, Primary runtime | Planetary | 37.28 s | 195/40/13/1/4 | 25.50 s | 85 | 47/85 | Score Clear | 40 + 25.50 − 37.28 = 28.22 s |
| 2 | Godot 4.7.1 Desktop, Primary runtime | Galactic | 32.08 s | 188/77/16/6/7 | 47.25 s | 156 | 115/149 | Run End | 35 + 47.25 − 32.08 = 50.17 s |

## Tuning conclusion — 2026-08-21

- Ground는 Debug Clear 없이 Time Up → Settlement Clear 1회와 즉시 Score Clear 1회로, Planetary는 즉시 Score Clear 2회로 다음 Stage에 진입했다. 두 Scale Shift가 자연 플레이에서 재현됐고, Stage 종료/Shift 시점의 timer는 Ground `17.12–19.63s`, Planetary `28.22–34.50s`였다.
- Galactic은 두 Run 모두 Run End까지 도달했고, Time Bonus가 종료 timer를 `50.12s`/`50.17s`까지 연장했지만 실제 PLAYING dwell은 `34.63s`/`32.08s`였다. Black Hole finale가 timer와 별도로 Run을 닫으므로 time cap을 추가할 근거가 없다.
- 최고 active ball은 `156`, candidate peak는 `115`, grid cell peak는 `154`였다. 이는 현재 일반 플레이 peak 가정 `300` 및 Web 성능 Gate `500`보다 낮다. 이 두 Desktop 표본만으로 performance tuning을 변경하지 않는다.
- 결론: `base_time`, `clear_score`, `spawn_rate`, `time_bonus_by_local_level`과 no-time-cap 기준을 **변경하지 않는다**. Web browser telemetry와 release QA는 S9-G2에서 별도로 수행한다.

## 실행 절차

1. clean Web release build 또는 Desktop build와 브라우저/장치 정보를 기록한다.
2. Title에서 Start하고 일반 조작으로 플레이한다. Debug clear 키와 강제 score 주입은 tuning 표본에 사용하지 않는다.
3. `tests/release/s9_g1_release_telemetry_runner.tscn`을 실행한 뒤 일반 조작으로 플레이한다. runner는 `S9_G1_TELEMETRY_SAMPLE` JSON을 Godot output에 출력한다. 각 Stage 종료 또는 Result 뒤 그 값을 위 표에 옮긴다. Pause/Shift/Result 시간은 dwell에서 제외한다.
4. 같은 build에서 최소 두 Run을 기록한다. late-game 표본은 500 logical balls 성능 Gate와 혼동하지 않고 별도 수치로 남긴다.
5. 수치 변경이 필요하면 원본 표본, 변경 가설, 재측정 결과를 함께 기록한다. 변화가 없으면 기준선 유지 자체를 결과로 기록한다.

## 자동 검증 범위

`tests/release/s9_g1_release_telemetry_verification.tscn`은 Main의 기존 read-only Cashout, Stage, simulation metric API에서 전달받는 값을 기록하는 계산 규칙을 검증한다. Main wiring이나 gameplay state는 바꾸지 않는다.

- global level에서 현재 Stage의 local level과 data-defined Time Bonus를 일관되게 계산한다.
- `PLAYING` 시간만 dwell에 누적하고, Pause/Shift 상태는 제외한다.
- 최대 활성 공·candidate·grid cell metric을 누적한다.
- 실제 플레이 수치나 브라우저 FPS를 만들어 내거나 주장하지 않는다.

`tests/release/s9_g1_release_telemetry_runner.tscn`은 Main을 자식으로 열고 기존 `stage_changed`, `stage_state_changed`, `cashout_completed`, `simulation_metrics_updated`, `get_runtime_snapshot()`만 읽는다. dwell은 renderer delta가 아니라 Core가 `PLAYING` tick에서만 누적한 `run_time_seconds`의 Stage 전후 차로 계산한다. Result UI, gameplay rules, Stage data, 저장 데이터는 변경하지 않는다.

Stage 종료 timer는 다음 Stage 진입 뒤의 base time을 읽지 않도록 Clear/Time Up/Run End lock이 발생한 순간에 고정한다.

최신 Main에서 Primary runtime은 runner ready → Ground sample → Planetary entry까지 console output을 확인했다. 이 확인에는 debug Score Clear를 사용했으므로 표본 값은 runner 기능 확인용이며 tuning 표에는 기록하지 않는다. tuning 표에는 위 실행 절차의 자연 플레이 표본만 기록한다.
