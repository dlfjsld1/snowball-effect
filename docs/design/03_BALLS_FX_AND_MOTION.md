# 03. Balls, FX, and Motion

Status: APPROVED PLAN — runtime values remain Goal-gated  
Owner: Presentation  
Immediate Goal anchor: S2-G5 Merge FX + score presentation

## 1. Gameplay Readability First

Ball은 장식 입자가 아니라 규칙 상태다. 화면에 공이 많아져도 각 Ball의 위치·크기·등급이 particle보다 먼저 읽혀야 한다.

- 크기와 실루엣이 level의 1차 cue다.
- 색은 2차 cue, 내부 pattern/shine은 3차 cue다.
- glow가 꺼져도 Ball 등급이 구분되어야 한다.
- Paddle은 모든 Stage와 effect 위에서 가장 안정적인 shape/contrast를 유지한다.
- particle은 Ball silhouette 안쪽을 장시간 가리지 않는다.

## 2. Ball Visual Bible Deliverable

전역 Merge 성장 사슬은 0~14의 15종으로 디자인한다. runtime Resource 15개는 존재하고 Lv14 Black Hole은 일치하지만, 2026-08-12 최신 Lv6/Lv7/Lv9/Lv10 명칭과 아직 일치하지 않아 S2-G1이 재검증 `PENDING`이다. 실제 runtime asset 수정은 해당 Goal의 Owned Files가 승인된 뒤 제작한다.

| Global level | Concept |
|---:|---|
| 0 | Snowflake |
| 1 | Snowball |
| 2 | Big Snowball |
| 3 | Giant Snowball |
| 4 | Moon |
| 5 | Earth |
| 6 | Sun |
| 7 | Red Giant |
| 8 | Supernova |
| 9 | Nebula |
| 10 | Galaxy |
| 11 | Galaxy Cluster |
| 12 | Quasar |
| 13 | Event Horizon |
| 14 | Black Hole |

현재 runtime Resource는 Lv14 `Black Hole`/`black_hole`에는 이미 맞지만 Lv6/Lv7/Lv9/Lv10이 최신 catalog와 다르며 `docs/goals/STATUS.md`의 S2-G1 contract drift를 따른다. Lv14 Ball은 어두운 중심과 compact accretion ring을 사용하되 gameplay outline과 작은 이동 object 크기를 유지한다. 이동 Black Hole 맵 기믹은 화면 규모의 lensing·field grid distortion·환경 label로 구분한다.

1. 15개 global level을 담은 1× silhouette row.
2. dark/light stress background 위 outline comparison.
3. 100%, 75%, 50% 표시 크기 비교.
4. normal, just-merged, top-ball 상태. `merge-ready`는 future design proxy로만 둘 수 있으며 S2 runtime state가 아니다.
5. color-vision grayscale check.
6. S2 전에는 합성 100/500/1000 density mock, S4-G3 이후에는 실제 runtime capture.

### v1 Stage Plan — Plan 1

v1은 3개 Stage에 5등급씩 배치하며 Stage 경계 Ball 한 종을 공유한다.

| Stage | Local grade 1→5 | `local_ball_levels` |
|---|---|---|
| Ground | Snowflake → Snowball → Big Snowball → Giant Snowball → Moon | `[0, 1, 2, 3, 4]` |
| Planetary | Moon → Earth → Sun → Supernova → Galaxy | `[4, 5, 6, 8, 10]` |
| Galactic | Galaxy → Galaxy Cluster → Quasar → Event Horizon → Black Hole | `[10, 11, 12, 13, 14]` |

Plan 1은 13종을 기본 런에서 사용한다. `Red Giant`와 `Nebula`도 15종 visual bible에는 제작하지만 기본 StageDefinition에서는 비활성이다.

### Catalog Sandbox

Lv7 `Red Giant`와 Lv9 `Nebula`를 포함한 15종 전체 연결은 개발용 catalog sandbox에서 검토한다. 이것은 별도 Stage나 release UI mode가 아니다. 기본 Run의 StageDefinition은 진행 순서대로 정렬된 `local_ball_levels`로 활성 사슬을 정하며, 같은 local grade의 두 Ball이 합쳐지면 숫자상 `global_level + 1`이 아니라 현재 목록의 다음 항목이 결과가 된다. 플레이테스트에서 종류 수를 조정하더라도 global identity와 sprite key를 재번호화하지 않는다.

## 3. Visual Hierarchy Rules

| 속성 | 낮은 level | 높은 level | Top Ball |
|---|---|---|---|
| 크기 | 작고 단순 | 단계적으로 증가 | Stage의 최고 실루엣 |
| outline | 공통 최소 두께 | 두께/이중선 제한적 증가 | 확실한 crown/ring cue |
| 내부 detail | 0~1 motif | 1~2 motif | 고유 motif 1개 |
| glow | 없음 또는 매우 약함 | event 순간만 강화 | clear lock 동안 강화 |
| animation | 1~2 frame idle | 느린 pulse 후보 | clear에서만 특별 motion |

## 4. Event Tier Matrix

정확한 maximum concurrent count, render-frame spawn cap과 기본 duration은 S6-G1 Entry Gate에서 확정한다. 위치 aggregation을 실제로 도입할 경우에만 별도 threshold를 승인한다.

| Tier | Event 예시 | 목적 | 보존 정책 |
|---:|---|---|---|
| T0 | 반복 collision, ambient | 촉감 보조 | 가장 먼저 throttle/drop |
| T1 | 일반 Merge, Item Box damage, 소액 score | 원인-결과 확인 | density에 따라 축소 |
| T2 | 고레벨 Merge, 의미 있는 Cashout, Common/Rare Box break | 진행 성취 | core burst 보존 |
| T3 | Top Ball, Stage Clear, Epic Box break, failure lock | 상태 전환 | 반드시 표시 |
| T4 | Scale Shift, Final Result | run의 대표 순간 | 전용 budget, 중복 금지 |

하위 tier가 상위 tier의 silhouette·text·audio를 덮지 않는다. VFX는 보상 장식만이 아니라 event 중요도와 다음 행동을 전달하는 디자인 언어로 사용한다. 참고: [GDC — VFX as a Game Design Language](https://media.gdcvault.com/GDC%2B2022/Speaker%2BSlides/VFXasagamedesignlanguage_Nguyen_An-Tim.pdf).

## 5. Merge Feedback and Score Sources

V4에서 `Compression Bloom`의 visual direction과 700ms keyframe seed를 채택했다. 목업의 `+0240`은 contract fixture이며 아래 authoritative source 규칙보다 우선하지 않는다. 세부 beat와 reduced recipe는 [09_APPROVED_VISUAL_DIRECTION_V4.md](09_APPROVED_VISUAL_DIRECTION_V4.md)를 따른다.

현재 canonical event 역할을 분리한다.

| Consumer behavior | Authoritative input | Payload | Rule |
|---|---|---|---|
| world-space Merge FX | Core `ball_merged` | 최소 `result_level, world_position` | 위치와 등급만 표현 |
| persistent score slot 갱신 | Core ledger `score_changed` | `stage_score, run_score` | Content formatter로 문자열화 |
| world-space numeric score popup | Core score event | `event_id, amount, world_position` | 실제 반영된 amount만 표시 |

현재 `ball_merged`에는 score amount가 없으므로 result Ball의 잠재 `score_value`를 획득 점수처럼 표시하지 않는다. 여러 Merge가 같은 tick에 생길 때 `score_changed`를 world position과 추측으로 결합하지도 않는다.

S2-G5에서 numeric popup을 요구한다면 Core가 `score_event_committed(event_id: int, source_type: StringName, amount: float, world_position: Vector2)`처럼 amount와 위치가 원자적으로 묶인 authoritative event를 제공하고 Integration contract/Goal을 먼저 갱신한다. Merge 자체가 점수를 지급하지 않는 게임 계약이면 Merge 숫자 popup은 만들지 않고 level-up text만 사용한다.

### Merge feedback stack

S2의 2-argument `ball_merged(result_level, world_position)`으로 가능한 일반 Merge stack은 다음으로 제한한다.

1. `world_position` 중심의 짧은 pixel burst/ring.
2. `result_level`에 따른 burst tier/크기 선택.
3. level-up/event text — 점수 amount를 의미하지 않는 경우만 사용.
4. audio key — S6-G3 catalog 이후.

동일 Merge에 effect instance가 두 번 생기지 않는다. Presentation은 `ball_merged(result_level, world_position)`과 read-only score/formatter 출력을 서로 다른 channel로 소비하고 결과 level이나 score를 계산하지 않는다.

두 source Ball의 contraction이나 result Ball renderer pop은 source/result slot ID 또는 position snapshot이 없으므로 S2 runtime 범위에서 제외한다. 향후 필요하면 Core event payload와 Goal contract를 먼저 확장한다.

## 6. Cashout and Settlement

- Active Cashout은 하단 열린 경계로 이동한 결과를 짧게 보여준다.
- Time Bonus가 0이면 time popup을 만들지 않는 현재 계약을 따른다.
- Final Settlement는 active ball snapshot의 base score만 시각화하고 추가 Merge처럼 보이게 하지 않는다.
- Settlement visualization은 중복 호출에도 한 번만 끝나는 흐름을 가져야 한다.
- Cashout, Settlement, failure가 같은 시각 언어를 쓰지 않도록 방향과 motion을 구분한다.

## 7. Item Box Contract and Feedback

현재 게임 규칙의 획득 경로는 Ball 충돌 기반 `Item Ball`이다. 디자인에서는 같은 gameplay entity의 외형/표시명을 각진 `Item Box` 또는 `궤도 화물 캡슐`로 제안하며, S7 구현 전 canonical runtime 명칭과 visual key만 한 번 확정한다.

### Object and visibility

- Item Box는 상단에서 내려오는 각진 `궤도 화물 캡슐`이다.
- 낙하 중에는 Common/Rare/Epic 희귀도만 palette, border notch, core shape로 표시한다.
- 실제 item icon/name은 파괴 순간까지 숨긴다.
- 정확한 HP 숫자는 gameplay UI에 표시하지 않고 균열 3단계와 hit flash로 상태를 전달한다.

### Initial data

| Rarity | Durability | Initial item mapping |
|---|---:|---|
| Common | 3 | Magnet |
| Rare | 6 | Blizzard |
| Epic | 10 | Fire Core |

희귀도는 `ItemDefinition`의 고정 속성이고 hardcode하지 않는다. 아이템이 늘거나 효과가 재조정되면 rarity, durability, spawn weight를 data에서 바꾼다.

| Stage-local ball grade | Damage |
|---:|---:|
| 1 | 0 |
| 2 | 1 |
| 3 | 2 |
| 4 | 3 |
| 5 | 5 |

Local grade는 현재 StageDefinition의 정렬된 Ball 목록 안에서 정한다. 활성 목록을 4종으로 조절해도 global level이나 damage를 Presentation이 추론하지 않는다.

### Collision and lifecycle

- 모든 Ball은 캡슐 표면에서 contact normal 기준으로 완전 반사하고 충돌 직전 runtime speed를 유지한다.
- grade 1도 반사되지만 damage는 0이며 lock-shaped pixel과 dull impact로 비자격 상태를 알린다.
- 캡슐의 fall velocity/path는 Ball 충돌로 변하지 않는다.
- 같은 physics tick의 모든 유효 hit damage를 합산하되 `box_id`별 break와 reward는 정확히 한 번만 commit한다.
- physics ordering의 collision 구간에 Box hit/reflect를 포함하고, 그 뒤 기존 Merge commit·Cashout·terminal precedence를 유지한다.
- 하단 open Cashout boundary를 통과하면 짧은 miss cue 뒤 무벌점 제거한다.
- Pause에서는 fall, damage, timer, FX를 동결한다.
- Settlement, Scale Shift, Result, full Retry에서는 남은 Box를 보상 없이 정리한다.
- Stage Restart에서는 Stage entry snapshot의 Box/효과 상태로 복원하고 현재 Stage에서 얻은 item은 제거한다.

### Feedback sequence

```text
impact/reflect
→ durability crack update
→ break commit
→ radial pixel fragments + capsule opening
→ hidden item symbol reveal
→ HUD effect slot로 pixel trail
→ authoritative effect activation/refresh
```

Motion grammar는 `Merge=수렴`, `Cashout=하강`, `Box Break=방사형 파편과 개방`으로 분리한다. Item Box가 깨져도 Presentation이 effect를 직접 시작하지 않는다.

V4 `Salvage Burst`의 1000ms keyframe seed를 채택한다. 파편 50% 감소·정적 beam·획득 정보 보존은 reduced/density-degradation reference이며 사용자 설정 구현 승인은 아니다.

## 8. Motion Language

- Input/collision: 즉각적이고 짧다.
- Merge future direction: source/result snapshot이 제공되는 향후 계약에서는 안쪽으로 모인 뒤 한 번 팽창할 수 있다. S2 default는 result-position burst/ring만 사용한다.
- Cashout: 아래 방향으로 빠져나가며 하단 cue에 흡수된다.
- Clear: 움직임이 잠기고 중심/Top Ball로 시선이 모인다.
- Shift: 좌우 대칭 확장, 이후 world reveal.
- Item Box damage: 짧은 반사 impact와 균열 증가; 공의 궤적 변화가 먼저 읽힌다.
- Item Box break: 바깥 방사 후 중앙 item reveal; Merge의 수렴 motion과 혼동하지 않는다.
- Failure: 확장 반대 방향의 collapse를 남용하지 않고 control loss를 명확히 알린다.

모든 duration은 tuning 상태다. 중요한 연출도 플레이를 오래 빼앗지 않으며, repeated event가 hit-stop을 중첩하지 않는다.

### Future candidate — Black Hole tidal deformation

Black Hole force로 궤도가 휘는 일반 Snowball은 향후 Black Hole 방향으로 늘어나고 직교 축으로 눌리는 transient deformation을 사용할 수 있다. 이는 일반 Snowball의 MultiMesh 본체에서 instance transform 또는 shared shader custom data로 표현하는 Presentation 후보이며, Item Ball과 Black Hole 본체의 전용 렌더러에는 같은 계약을 강제하지 않는다.

Gameplay collision은 nominal 원형 radius를 유지한다. deformation은 Merge/Paddle/벽/흡수 판정을 바꾸지 않고, Core의 read-only Black Hole 위치·영향 상태를 시각화하기만 한다. 정확한 비율·falloff·두 Black Hole 합성·흡수 직전 과장 정도는 S8/S6 플레이테스트 전까지 미결정이다.

**STATUS: FUTURE PRESENTATION CANDIDATE — IMPLEMENTATION NOT APPROVED.**

## 9. Density Degradation

공 수와 event burst가 증가하면 다음 순서로 품질을 낮춘다.

1. ambient particle emission 감소.
2. T0 trail/collision particle 제거.
3. T1 burst particle 수 감소.
4. popup 동시 수 제한 및 aggregation 검토.
5. Stage World transient light 감소.

T2의 핵심 burst, T3/T4 state transition, Paddle/Ball outline, 필수 HUD는 보존한다. 논리 공과 장식 particle pool은 분리한다.

### Runtime budget architecture

- 현재 승인된 S6-G1 runtime source of truth는 단일 소비자인 `EffectManager`의 tier별 priority, active cap, render-frame spawn cap, 전체 active cap 상수다. 정확한 값과 상태 이벤트 우선도는 `docs/team/INTEGRATION_CONTRACTS.md`를 따른다.
- 별도 data-driven `FxBudgetProfile`, 위치 기반 aggregation, reusable Node pool은 reduced-effects profile이나 복수 tuning profile이 실제로 필요해질 때 분리하는 후속 최적화다. 현재 Goal의 완료 조건으로 소급하지 않는다.
- T0/T1은 pool/budget이 가득 차면 drop/throttle할 수 있다. 같은 tick·인접 위치 aggregation은 후속 후보로 유지한다.
- T2는 T0/T1보다 엄격한 별도 active·spawn cap을 사용한다.
- T3/T4 상태 전환은 gameplay FX보다 높은 별도 priority reservation을 사용하며 낮은 이벤트가 덮어쓰지 못한다. gameplay Merge/Cashout의 high tier는 낮은 active effect를 eviction할 수 있다.
- runtime은 active Node/Tween/popup 수가 event 수에 따라 무제한 증가하지 않게 한다.
- 현재 cap은 S6-G1 initial production 값으로 승인한다. 전체 S6 통합 뒤 Q-S6 Web burst에서 같은 환경의 Presentation-on 수치를 측정하고, 실제 가독성·frame-time 근거가 있을 때만 재조정한다.

## 10. Cut-in and Camera

- CUT-IN은 T3/T4에 제한하고 중복 queue 정책을 가진다.
- camera shake는 위치 판단을 방해하지 않는 축·진폭으로 제한한다.
- Scale Shift는 camera zoom으로 폭 증가를 위장하지 않는다. 실제 Frame/Field edge가 이동해야 한다.
- secondary shake/flash/particle을 제거한 reference에서도 state text/outline만으로 전환이 읽혀야 한다.

현재 release scope에는 사용자용 reduced-effects setting이나 runtime toggle이 없다. 해당 기능은 별도 Goal이 생기기 전까지 구현 요구사항이 아니다.

V4 `Cabinet Score Lock`의 1200ms keyframe seed를 Score Milestone 방향으로 채택한다. gameplay를 pause하거나 중앙 action area를 덮지 않으며, threshold와 current run score는 authoritative data에서 받는다. 목업의 `10K`는 fixture다.

## 11. Verification

- Merge 한 번에 feedback stack이 한 번만 발생한다.
- grayscale에서도 Ball level group과 Paddle이 배경에서 분리된다.
- S4-G3 이후 실제 1000-ball stress scene에서 high-tier event와 HUD 후보 영역이 읽힌다. 그 전에는 합성 mock만 evidence로 사용한다.
- FX off에서도 gameplay state를 이해할 수 있다.
- FX throttle이 score/state/event count를 변경하지 않는다.
- 15종 silhouette을 label 없이 순서화했을 때 참가자의 80% 이상이 성장 방향을 맞힌다.
- Stage별 인접 등급 혼동 쌍은 2개 이하이고 grayscale에서도 공통 outline/size grammar가 남는다.
- Box rarity 세 단계, damage 0/1/2/3/5, durability 3/6/10, simultaneous break once-only를 확인한다.
- 공이 Box에서 완전 반사한 뒤 speed magnitude가 허용 오차 안에서 유지된다.
- Box miss, Pause, Settlement, Shift, Stage Restart, full Retry마다 reward 중복과 stale FX가 없다.

## 12. Intentional Exclusions

- Ball physics, merge 조건, velocity inheritance.
- score 계산과 formatter implementation.
- final particle count, duration, audio asset.
- scene/shader/script 구현.
- Item Box spawn 주기와 spawn weight 최종 balance.
- 4개 이상 동시 active item용 HUD production layout.
