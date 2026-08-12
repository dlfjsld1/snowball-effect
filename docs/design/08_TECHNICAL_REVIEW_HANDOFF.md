# 08. Technical Review and Cross-lane Handoff

Status: CONDITIONAL APPROVAL — Presentation plan is feasible; runtime entry is contract-gated  
Review date: 2026-08-11; contract update 2026-08-12
Planning owner: Presentation  
Decision owners for blockers: Core, Content/Systems, Integration, Product as listed below

이 문서는 `$plan-eng-review` 결과를 구현 가능한 handoff로 정리한다. Presentation이 Core 게임 규칙을 승인하거나 직접 구현하는 문서가 아니다. 현재 Goal 상태를 바꾸지 않으며, 아래 blocker가 source-of-truth 문서와 Goal에 승인되기 전 관련 runtime Goal을 시작하지 않는다.

## 1. Technical Verdict

현재 디자인은 Godot 4.x와 기존 중앙 배열 simulation 위에서 구현 가능하다.

- 기능 범위는 유지하되 Goal 단위 vertical slice로 구현한다.
- Presentation은 typed read-only snapshot을 렌더하고 request/finished signal만 발행한다.
- gameplay 계산과 top-level state transition은 Core/Integration에 남긴다.
- Presentation fixture 제작은 producer 구현과 병렬 가능하지만 실제 wiring은 승인된 producer contract 뒤에만 한다.
- 기존 `.gitignore`, Goal status, Integration-owned runtime files는 이 문서 작업에서 변경하지 않는다.

## 2. Blocking Handoffs

| ID | 충돌 / 누락 | Decision owner | 승인 결과 | Blocks |
|---|---|---|---|---|
| H1 | Docs RESOLVED — `N+1` 대신 Stage별 non-contiguous ordered chain 사용 | Core + Content + Product | `StageDefinition.local_ball_levels` lookup을 rules/task/slice/API에 기록; runtime은 S5-G2에서 검증 | S5-G2 |
| H2 | Docs RESOLVED — 3-Stage + Galactic Black Hole Phase L3 | Product + Core + Integration | Black Hole force를 Galactic 내부 기믹으로 유지하고 S8-G1/G4/G5로 분해 | S8 runtime/art |
| H3 | Docs RESOLVED — canonical field는 `local_ball_levels` | Content + Core | ordered global ID 5개, lookup failure 정책, progressive HUD source | S3 data, S5 Merge/HUD |
| H4 | RESOLVED — `ball_merged(result_level, world_position)` 2인자 | Core + Integration | score amount/special type을 분리하고 producer/consumer 문서 동기화 | S2-G5 fixture |
| H5 | Item Ball/Item Box 명칭과 collision/durability 세부 규칙이 분산됨 | Product + Core + Content + Integration | canonical entity name, stable contact order, hit dedupe, break tick, miss/cleanup 계약 | S7 전 Goal |
| H6 | Stage Restart가 여러 lane state를 되돌리지만 atomic restore protocol이 없음 | Core + Integration | prepare/restore/ack barrier, epoch, timeout/recovery 정책 | Pause final UI, S8-G4 |
| H7 | HUD/Result에 typed authoritative producer가 없음 | Core + Content + Integration | `HUDViewState`, `ResultViewState`, fixtures, cadence, stale policy | S3-G6, Result UI |
| H8 | S3 Integration이 기다릴 Settlement Presentation producer Goal이 없음 | Presentation + Integration | Presentation Goal, settlement identity, exactly-once/reset API | S3-G5 |

V5의 `Compression Bloom` ring/burst와 비점수 label은 확정된 2인자 `ball_merged`로 제작할 수 있다. numeric score popup은 authoritative `amount + world_position` event가 별도로 승인될 때만 사용한다.

### H1 required behavior

- global Ball identity와 sprite key를 Stage 재배치 때문에 재번호화하지 않는다.
- ordered Stage chain에 없는 level, 마지막 level, 누락된 BallDefinition 입력의 결과를 명시한다.
- 기존 S2-G1 Evidence는 역사 기록으로 유지하지만 최신 0~14 catalog와 Resource가 달라 STATUS를 PENDING으로 되돌렸다.
- Presentation은 Merge 결과를 계산하지 않고 authoritative result level만 사용한다.

### H2 approved Presentation direction

- v1 visual route는 Ground → Planetary → Galactic 3-Stage다.
- Lv14 `Black Hole`은 Galactic top Ball이고, 이동 Black Hole 최종 국면 맵 기믹은 동명 concept이지만 별도 Stage effect다.
- 기믹 발동 시 L2→L3 `Black Hole Phase Transition`을 실행하고 같은 Galactic에서 spawn, timer, input을 재개한다.
- Galactic top Ball은 Lv14 `Black Hole`이며 생성 후 추가 Frame Shift 없이 Result로 간다.

### H5 deterministic Core questions

Core 계약에는 최소 다음 답이 있어야 한다.

- `(ball_slot_id, box_id, physics_tick)`당 damage commit 최대 1회.
- 같은 tick 다중 hit의 stable order와 damage 합산 시점.
- Ball이 같은 tick에 wall/Box/다른 Box와 닿을 때 earliest contact/tie-break.
- durability가 0 이하가 된 tick의 남은 contact가 반사를 유지하는지 여부.
- `box_id`별 break/reward exactly once와 Pause/Settlement/Shift/Restart/Retry cleanup.

Presentation은 hit/break/miss snapshot을 표시할 뿐 damage, reward, item activation을 계산하지 않는다.

### H6 restart barrier proposal

```text
restart_stage_requested
  → Integration assigns run_epoch + stage_restart_id
  → restart_prepare(id) to required lanes
  → restore(stage_entry_snapshot, id)
  → restored(id) acknowledgements
  → all required acknowledgements received
  → authoritative view snapshots published
  → gameplay resumes
```

timeout 또는 restore 실패 시 gameplay는 paused 상태를 유지하고 Main Screen으로 나갈 수 있는 복구 UI를 제공한다. Presentation은 `reset_view(run_epoch, stage_restart_id)`로 이전 Tween/queue/callback을 무효화한다.

## 3. Presentation Contracts

### HUD

- typed `RefCounted` `HUDViewState`, `BallProgressionEntry`, `ActiveEffectView`를 소비한다.
- Stage 이름, Time, Stage Score/Target, ordered Ball Progression, Run Score, active effects, Pause를 표시한다.
- Ball Progression은 세로 5칸이며 reveal 1에서 시작해 새 공 최초 생성마다 2→5로 증가한다.
- discrete state는 즉시, timer/effect countdown은 최대 10Hz로 갱신한다.
- 같은 값은 Label/Icon 속성을 다시 쓰지 않는다.
- `run_epoch`와 `view_revision`으로 stale/duplicate snapshot을 거부한다.

### UI flow and Result

- Integration이 top-level `UiFlowViewState`를 소유한다.
- view는 request-only이고 `restart_stage_requested`와 full Run `retry_requested`를 분리한다.
- Result는 typed immutable `ResultViewState`만 소비하고 같은 `run_id`를 두 번 열지 않는다.

### Scale Shift

```text
play_stage_shift(run_epoch, shift_id, from_rect, to_rect, visual_keys)
  → StageWorldPresenter
      ├─ Frame track
      ├─ displayed Play Field mask track
      └─ Stage World track
  → all required tracks completed
  → stage_shift_presentation_finished(run_epoch, shift_id) exactly once
```

Restart/Retry는 `reset_presentation(new_epoch)`를 호출한다. Presenter와 Integration 양쪽이 stale epoch와 duplicate identity를 거부한다.

### Assets and FX

- V5 Frozen Enamel, slim fixed-width bezel, Compression Bloom, Salvage Burst, Cabinet Score Lock, Black Hole Phase를 visual handoff 기준으로 사용한다.
- 필수 gameplay visual은 missing texture/font/key 때 code-native 또는 approved proxy fallback을 표시한다.
- missing key warning은 key당 한 번만 기록한다.
- `FxBudgetProfile`은 T0/T1 aggregation pool, T2 limited pool, T3/T4 reserved slot을 분리한다.
- event당 무제한 Node/Tween/popup 생성 경로를 허용하지 않는다.

## 4. Verification Contract

### Coverage map

```text
HEADLESS CONTRACT                              WEB / USER FLOW
HUD snapshot                                  Playing HUD
├─ score/time boundaries                      ├─ timer 10Hz cadence
├─ effect 0/1/3 + refresh                     ├─ vertical Ball Progression reveal 1/2/5
├─ stale epoch/revision                       └─ 1280×720 compact layout
└─ proxy fallback

Pause/Result                                  Pause → Settings → Pause
├─ request exactly once                       ├─ focus trap/restore
├─ Restart vs Retry signal                    ├─ destructive confirmations
├─ Result fail/final/duplicate                └─ focus loss without auto-resume
└─ storage/fullscreen fallback

StageWorldPresenter                           Scale Shift
├─ child-track barrier                        ├─ L1/L2 control return
├─ duplicate completion                       ├─ Restart at every beat
├─ stale run_epoch                            └─ L2 → Black Hole Phase L3 → gameplay → Result
└─ proxy/missing visual key

FX budget                                     Dense Web build
├─ tier pool exhaustion                       ├─ 100/500/1000 balls
├─ T0/T1 aggregation                          ├─ Item Box break burst
└─ T3/T4 reserved slots                       └─ browser console/resize/focus
```

- 각 Presentation component는 Godot CLI/headless contract verification을 가진다.
- 3개 이상 component/service를 지나는 경로는 실제 Web export + browser E2E로 검증한다.
- stable HUD/Frame/focus 영역은 deterministic screenshot diff를 사용하고 particle/Tween/GPU-noise 영역은 mask 후 사람이 승인한다.
- visual baseline 변경에는 Goal, 이유, before/after evidence가 필요하다.

### Performance gate

- 첫 승인 S4 Core-only evidence의 장비/browser/viewport/release preset/seed를 canonical reference로 기록한다.
- 같은 환경에서 Presentation-on을 연속 측정한다.
- absolute: 1,000 logical balls 최소 30 FPS 이상.
- relative: Core-only 대비 Presentation-on p95 frame time 증가 10% 이내.
- 둘 중 하나라도 실패하면 관련 Presentation Goal을 완료로 표시하지 않는다.

## 5. Parallel Execution

| Lane | Work | Dependency |
|---|---|---|
| Core/Content/Integration | H1~H8 source contract와 Goal 재승인 | existing verified baseline |
| Presentation A | typed fixture, HUD layout/state tests | H7 fixture schema |
| Presentation B | Frame keyframes, `StageWorldPresenter` contract tests | H2/H3 profile contract |
| Presentation C | proxy assets, FX budget sheet, visual baselines | S4 Core-only baseline for runtime caps |
| Integration | real producer wiring and state transitions | lane contracts verified |
| Release | Web E2E, visual regression, performance evidence | integrated RC |

Handoff 문서 승인과 fixture 제작은 병렬 가능하다. Integration-owned 파일은 별도 Integration Goal과 `STATUS.md` lock 없이 수정하지 않는다.

## 6. NOT in Scope

- Presentation이 Merge, score, Item Box damage, Stage Restart rollback을 직접 계산하는 구현.
- 별도 4번째 Black Hole gameplay Stage의 v1 production art.
- Plan 2의 15종 전체 사용 실험.
- Black Hole Phase의 정확한 발동 밸런스 값.
- portrait/mobile과 1280×720 미만 정식 지원.
- S4 측정 전 임의 FX cap 확정.
- Reduced Effects v1 구현. 후속 항목은 [TODOS.md](TODOS.md)에 둔다.

## 7. Entry and Exit

Presentation runtime Goal entry:

1. Goal dependencies verified.
2. 관련 Handoff ID가 source rules/technical/slice/Integration contract에 승인됨.
3. producer fixture와 exact payload/correlation policy가 존재함.
4. Owned Files와 Integration lock 확인.

현재 next Presentation runtime Goal은 S2-G5이며 확정된 S2-G3 2인자 event와 S2-G4 formatter를 사용한다. 사용자의 runtime 구현 승인은 별도로 필요하다.

Review result: `DONE_WITH_CONCERNS`. Presentation 계획은 구현 가능하지만 H1~H8 중 해당 Goal blocker가 승인되기 전 runtime 진입은 차단한다.
