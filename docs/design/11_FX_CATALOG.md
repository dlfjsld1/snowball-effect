# 11. FX Catalog

Status: DESIGN BACKLOG — 개별 시각 방향과 runtime 구현은 Goal별 승인 필요
Owner: Presentation
Purpose: 분산된 gameplay feedback 요구사항을 하나의 디자인·제작 목록으로 관리한다.

## 1. 문서의 역할

이 문서는 Snowball Effect에서 디자인할 수 있는 FX 전체 목록과 우선순위를 정의한다. 이벤트 발생 조건, 점수 계산, Stage 상태와 물리 판정은 변경하지 않는다.

- `REQUIRED`: v1의 상태·보상·전환을 읽기 위해 필요한 FX.
- `CONDITIONAL`: 관련 Optional 시스템 또는 authoritative event 계약이 포함될 때만 필요.
- `OPTIONAL`: 촉감과 장식 품질을 높이지만 없어도 v1 완료 조건을 충족할 수 있음.
- `FUTURE`: 현재 구현 범위 밖의 후보.

이 문서 작성 자체는 runtime Scene·Script·Resource 제작이나 Goal 상태 변경을 승인하지 않는다. S6-G1 구현에서는 T0/T1을 렌더 프레임당 최대 4개, 활성 Merge FX를 최대 12개로 제한한다. T2 이상이 포화 상태에서 들어오면 더 낮은 등급 또는 같은 등급의 오래된 FX를 먼저 종료하며, 더 높은 등급의 FX는 밀어내지 않는다. Merge FX lifetime은 0.32초다. particle 수와 shader 사용 여부의 추가 확대는 후속 측정 대상이다.

## 2. 공통 시각·모션 계약

- 90년대 픽셀 아케이드, 어두운 배경, 고대비 gameplay object를 유지한다.
- 승인된 Ball 방향인 `Dither Forge + Corona Pressure`와 재질·픽셀 밀도를 맞춘다.
- Ball과 Paddle의 실루엣은 모든 장식 particle보다 먼저 읽혀야 한다.
- `Merge = 결과 위치 중심의 압축/확산`, `Cashout = 하강`, `Item Box Break = 방사형 파편/개방`으로 구분한다.
- T0/T1은 과밀 시 축소·통합·생략할 수 있다. T2의 핵심 burst와 T3/T4 상태 전환은 보존한다.
- 색만으로 상태를 전달하지 않는다. 실루엣, 선 형태, 텍스트, 움직임 중 하나 이상을 함께 사용한다.
- 숫자 score popup은 authoritative `amount + world_position` 이벤트가 있을 때만 표시한다. `ball_merged(result_level, world_position)`에서 점수를 추측하지 않는다.

## 3. 기본 플레이 FX — 문서화 전용 후보

> **구현 비필수:** 아래 항목은 디자인 목록에는 유지하지만 v1에서 구현하지 않을 수 있다. 일정, Web 성능, 화면 밀도 때문에 전부 생략해도 현재 핵심 플레이·S6 완료 조건을 막지 않는다. 구현하더라도 가장 먼저 throttle/drop하는 T0/T1 장식 레이어이며, gameplay 판정과 필수 정보 전달을 담당하지 않는다.

| ID | FX | Tier | 상태 | 이벤트/입력 | 모션·역할 | 구현 메모 |
|---|---|---:|---|---|---|---|
| BP-01 | 공 생성 | T0 | OPTIONAL | spawn 결과 | 짧은 1-frame 응결 또는 작은 pixel pop | 공의 실제 위치·속도를 가리지 않음 |
| BP-02 | 벽 충돌 | T0 | OPTIONAL | boundary contact | 접촉 normal 방향의 1~3px spark | 반복 밀도가 높으면 완전 생략 |
| BP-03 | Paddle 충돌 | T0 | OPTIONAL | paddle contact | Paddle 표면을 따라 짧은 line flash | 반사 방향 판독을 방해하지 않음 |
| BP-04 | 일반 Cashout 하단 cue | T1 | OPTIONAL | `cashout_completed` | 아래로 빠져나가 하단 경계에 흡수 | 점수 popup과 분리 가능 |
| BP-05 | Time Bonus popup | T1 | CONDITIONAL | authoritative local bonus | `TIME +Xs`, 짧은 상향 drift | bonus가 0이면 표시 금지 |
| BP-06 | 소액 점수 popup | T1 | CONDITIONAL | authoritative score event | 작은 숫자의 짧은 상승·소멸 | amount/위치 계약이 없으면 만들지 않음 |

## 4. Merge FX

| ID | FX | Tier | 상태 | 이벤트/입력 | 모션·역할 | 핵심 제약 |
|---|---|---:|---|---|---|---|
| MG-01 | 일반 Merge | T1 | REQUIRED | `ball_merged(result_level, world_position)` | 결과 위치의 pixel burst와 얇은 링 | event 1회당 effect 1회 |
| MG-02 | 고등급 Merge | T2 | REQUIRED | 같은 event + result level | 더 큰 ring, 파편, 짧은 압력파 | Ball silhouette 보존 |
| MG-03 | 중요 공 생성 | T3 | REQUIRED | high-tier result | 짧은 hit-stop 후보, Corona 강화 | cooldown/priority 적용 |
| MG-04 | local Lv4 최초 발견 | T3 | REQUIRED | authoritative Run-scoped discovery | FIRST CONTACT 뒤 공에 시선 집중 | 생성만으로 Clear/Shift를 요청하지 않음; Black Hole만 Phase로 handoff |
| MG-05 | Stage 고등급 공 최초 생성 CUT-IN | T3 | CONDITIONAL | 현재 Run에서 지정 공 최초 생성 | 현재 16:9 화면 위 공통 배경, `FIRST CONTACT` 문구, 공 초상 | Stage별 local Lv3·Lv4만 1회, 0.45~0.70초, 기본 1초 미만 |

MG-05 대상은 Stage마다 두 종으로 고정한다.

| Stage | local Lv3 | local Lv4 |
|---|---|---|
| Ground | Giant Snowball | Moon |
| Planetary | Supernova | Galaxy |
| Galactic | Event Horizon | Black Hole |

- 각 대상은 현재 Run에서 처음 생성됐을 때만 CUT-IN을 요청한다.
- Moon은 Ground에서, Galaxy는 Planetary에서만 대상이므로 다음 Stage의 local Lv0 재등장으로 CUT-IN을 반복하지 않는다.
- 여섯 CUT-IN은 공통 배경 하나와 공별 문구·공 초상 레이어를 조립한다.
- 이전 후보였던 Galaxy Cluster와 Quasar는 현재 MG-05 대상이 아니다.

현재 2인자 Merge 계약으로는 두 source Ball의 contraction, slot 기반 잔상, merge score 숫자를 만들지 않는다. 해당 표현이 필요하면 Core payload와 Goal 계약을 먼저 확장한다.

## 5. Item Box와 활성 아이템 FX

S7 Optional Item Layer가 release 범위에 포함될 때만 이 묶음 전체가 구현 대상이 된다.

| ID | FX | Tier | 상태 | 이벤트/입력 | 모션·역할 | 핵심 제약 |
|---|---|---:|---|---|---|---|
| IT-01 | 공격 불가 충돌 | T1 | CONDITIONAL | damage 0 hit | 둔한 impact와 lock-shaped pixel | 반사는 정상적으로 읽힘 |
| IT-02 | 유효 타격·균열 갱신 | T1 | CONDITIONAL | `item_planet_damaged` | 짧은 flash와 3단계 crack | 정확한 HP 숫자는 표시하지 않음 |
| IT-03 | Common/Rare/Epic 파괴 | T2/T3 | CONDITIONAL | `item_planet_broken` + rarity | 희귀도별 border/core 형태 유지 | 색만으로 희귀도 구분 금지 |
| IT-04 | 방사형 파편·캡슐 개방 | T2/T3 | CONDITIONAL | break commit | 바깥 방사 후 중앙 개방 | Merge의 수렴 motion과 구분 |
| IT-05 | 숨겨진 아이템 공개 | T2/T3 | CONDITIONAL | authoritative reward | 중앙 symbol reveal | 파괴 전 icon/name 노출 금지 |
| IT-06 | HUD 획득 Trail | T2 | CONDITIONAL | reward → HUD snapshot | 공개 심볼이 HUD effect slot으로 이동 | 효과 활성화를 직접 실행하지 않음 |
| IT-07 | 활성화·갱신·종료 cue | T1/T2 | CONDITIONAL | `active_items_changed` | HUD slot pulse, refresh tick, 종료 wipe | duration을 Presentation이 계산하지 않음 |
| IT-08 | Item Box Miss Cue | T1 | CONDITIONAL | 하단 이탈·무보상 제거 | 짧은 하강 dash와 dull blink | 벌점처럼 보이지 않음 |
| IT-09 | Magnet field | T1/T2 | CONDITIONAL | authoritative active state | 범위 ring과 Ball 끌림 방향 보조 | 물리 범위를 추론하지 않음 |
| IT-10 | Blizzard field | T1/T2 | CONDITIONAL | authoritative active state | 냉기 pixel, 느린 pulse | 공 outline을 덮지 않음 |
| IT-11 | Fire Core field | T2/T3 | CONDITIONAL | authoritative active state | 열기 corona와 Cashout 강조 | ×10은 Active Cashout에서만 표시 |

## 6. 점수·시간·실패 FX

| ID | FX | Tier | 상태 | 이벤트/입력 | 모션·역할 | 핵심 제약 |
|---|---|---:|---|---|---|---|
| ST-01 | Score Milestone | T3 | CONDITIONAL | authoritative threshold event | Score CRT 점등과 좌우 cabinet lock | 중앙 Play Field를 덮지 않음 |
| ST-02 | 시간 부족 경고 | T1/T2 | REQUIRED | authoritative time pressure state | Time CRT pulse, 제한된 hazard cadence | 과도한 flashing 금지 |
| ST-03 | Time Up Lock | T3 | REQUIRED | `TIME_UP_LOCKED` | 입력·상태 고정이 읽히는 frame cue | Settlement보다 앞서되 결과를 예단하지 않음 |
| ST-04 | Stage Failure | T3 | REQUIRED | authoritative failed state | control loss와 failure label | Clear/Shift motion과 구분 |

Score Milestone의 정확한 threshold와 event signature는 아직 미확정이다. 계약이 생기지 않으면 ST-01은 구현하지 않는다.

## 7. Stage 진행 FX

| ID | FX | Tier | 상태 | 이벤트/입력 | 모션·역할 | 핵심 제약 |
|---|---|---:|---|---|---|---|
| SG-01 | Stage Clear Lock | T3 | REQUIRED | `stage_clear_decided` | simulation 정지와 최고 공 강조 | gameplay 결과를 Presentation이 계산하지 않음 |
| SG-02 | Final Settlement | T2 | REQUIRED | settlement start/finish | 기존 Cashout 소멸을 재사용한 active snapshot 일괄 제거와 Stage Score count-up | 독립 대형 FX를 만들지 않으며 Clear·Failure 결과를 표현하지 않음 |
| SG-03 | Scale Shift 충전 | T4 | REQUIRED | `stage_shift_started` | 중앙에서 좌우 rail로 energy 전달 | 일반 CUT-IN보다 우선 |
| SG-04 | Frame·Play Field 확장 | T4 | REQUIRED | shift presentation | frame과 실제 field edge가 좌우로 이동 | camera zoom으로 대체 금지 |
| SG-05 | 다음 Stage World 공개 | T4 | REQUIRED | matching shift id | 새 배경 layer reveal과 HUD Stage 갱신 | 완료 signal exactly once |

### 승인 방향 — Minimal Settlement Feedback

SG-02는 새로운 전용 일러스트나 복잡한 particle family를 만들지 않는다. 상태 변화가 누락이나 버그처럼 보이지 않게 하는 최소 피드백만 사용한다.

1. `TIME_UP_LOCKED` 뒤 활성 공의 움직임을 정지한다.
2. snapshot 공을 기존 Cashout 계열의 작은 pixel dissolve로 일괄 정리한다.
3. dissolve와 함께 Stage Score를 짧게 count-up한다.
4. 전체 presentation은 약 `0.5s` 안에 끝내고 settlement 완료 상태로 전환한다.

이 시퀀스는 추가 Merge, Time Bonus, Clear, Failure, 축하 메시지, `Next Stage`를 표현하지 않는다. 수천 개 공에도 개별 고비용 Tween/Node를 생성하지 않고 batch 표현을 우선한다.

검토 목업: [`mockups/drafts/final-settlement-minimal-v1.png`](mockups/drafts/final-settlement-minimal-v1.png)

## 8. Galactic Black Hole FX

| ID | FX | Tier | 상태 | 이벤트/입력 | 모션·역할 | 핵심 제약 |
|---|---|---:|---|---|---|---|
| BH-01 | 첫 Lv14 기믹 전환 | T4 | REQUIRED | `black_hole_phase_started` | Ball에서 이동 Black Hole entity로 전환 | 새 Stage처럼 표현하지 않음 |
| BH-02 | L2 → L3 Frame 전환 | T4 | REQUIRED | phase id + target rect | Galactic 내부 최종 국면 확장 | presentation 완료 뒤 gameplay 재개 |
| BH-03 | 중력장·회전 링·곡선 잔상 | T2/T3 | REQUIRED | Black Hole read-only state | 위치와 영향 방향을 지속적으로 표시 | gameplay outline 유지 |
| BH-04 | 일반 공 궤도 휘어짐 | T2 | REQUIRED | read-only influence state | Black Hole 방향의 transient trail/deformation | collision radius는 원형 유지 |
| BH-05 | 저등급 공 흡수 | T3 | REQUIRED | authoritative absorption event | 짧은 tidal stretch 후 중심 소멸 | Cashout·Merge와 혼동 금지 |
| BH-06 | 두 번째 Black Hole 생성 | T4 | REQUIRED | second Lv14 conversion | 두 entity의 분리된 silhouette과 field | 일반 Merge FX 사용 금지 |
| BH-07 | 상호 인력·공전 | T4 | REQUIRED | finale contact approach | 두 ring의 위상 동기화와 궤도 가속 | contact 전 gameplay 가능성 보존 |
| BH-08 | Contact Lock·최종 폭발 | T4 | REQUIRED | finale event | orbit 압축 후 화면 규모 pixel explosion | terminal sequence exactly once |
| BH-09 | Gameplay UI 제거 | T4 | REQUIRED | terminal sequence | cabinet HUD를 순차 소등·퇴장 | score/state를 변경하지 않음 |
| BH-10 | Title·Clear Score 등장 | T4 | REQUIRED | final run snapshot | `SNOWBALL EFFECT`와 final score reveal | Main Menu 요청 전 완료 |

화면 왜곡 shader는 품질 후보이며 필수 구현이 아니다. 회전 링, 별·먼지 왜곡, 곡선 잔상만으로 상태가 읽히면 생략할 수 있다.

## 9. 제작 묶음과 권장 순서

| 순서 | Design family | 포함 ID | 산출물 |
|---:|---|---|---|
| 1 | Merge hierarchy | MG-01~05 | T1/T2/T3 비교 state sheet, CUT-IN storyboard |
| 2 | Item feedback | IT-01~11 | rarity/crack/break sheet, active field sheet |
| 3 | Score·Time·Failure | ST-01~04 | HUD/cabinet reaction storyboard |
| 4 | Stage 진행 | SG-01~05 | Settlement 최소 시퀀스와 Shift 독립 storyboard |
| 5 | Black Hole finale | BH-01~10 | L2→L3와 terminal sequence storyboard |
| 6 | Basic polish | BP-01~06 | 필요할 때만 저비용 sprite/particle sheet |

Item Layer가 release에서 제외되면 2번 묶음은 함께 보류한다. 기본 플레이 FX는 마지막까지 구현 승인이 없어도 된다.

## 10. 구현 전 필수 handoff

각 FX family는 다음 정보를 기록한 뒤에만 runtime 제작에 들어간다.

- target Goal, Owner, Owned Files.
- authoritative event/API와 payload.
- Tier, 예상 최대 동시 수, 보존 또는 drop 정책.
- canvas/bounds, pivot, frame rate, duration, loop 여부.
- pause/reset/shift/result 시 정리 정책.
- low-density와 burst-density recipe.
- shader 없는 fallback.
- Desktop/Web 검증 방법과 성능 수치.

## 11. 의도적 제외

- FX가 gameplay score, time, velocity, collision, Stage 결과를 계산하거나 변경하는 일.
- Audio asset 제작과 재생 정책.
- 최종 particle 수·duration·camera shake 수치의 선확정.
- 사용자용 Reduced Effects 설정과 저장 UI.
- 기본 플레이 FX를 v1 필수 구현으로 승격하는 일.
