# Task 07 — Galactic Black Hole Map Gimmick

## 목적

마지막 Galactic Stage에서 첫 Lv14 Black Hole Ball을 이동 기믹으로 전환해 물리 규칙을 바꾸고, 두 번째 Black Hole과의 충돌로 Run을 끝낸다. Black Hole Phase는 별도 Stage가 아니다.

---

## 스테이지 데이터

```text
base_global_level: 10
top_global_level: 14
local_ball_levels: [10, 11, 12, 13, 14]
spawn_rate: 35/s
black_hole_phase_enabled: true
```

공:

```text
Galaxy
Galaxy Cluster
Quasar
Event Horizon
Black Hole Ball (Lv14)
```

Lv14 `Black Hole`은 catalog의 최종 BallDefinition이다. 첫 Lv14가 생성되는 순간 그 Ball은 일반 Snowball 상태를 떠나 이동 Black Hole runtime entity로 전환되고, 이것이 Galactic 내부 최종 국면의 발동 조건이다.

## Black Hole Phase Transition

- 첫 Lv14 생성은 Run 내 최초 FIRST CONTACT CUT-IN 뒤 Black Hole Phase를 요청하며 Clear/Result를 발생시키지 않는다.
- 발동 시 Stage는 바뀌지 않고 `Galactic`을 유지한다.
- spawn·timer·input을 전환 중에만 잠근다.
- Frame과 실제 Play Field가 L2 `880`에서 L3 `1040`으로 함께 좌우 대칭 확장한다.
- Presentation 완료와 동일한 `phase_id`를 확인한 뒤 새 logical Rect를 활성화하고 gameplay를 재개한다.
- 이 전환은 terminal presentation이 아니며 Final Result로 직접 이동하지 않는다.

---

## 블랙홀 이동

- Play Field 안을 공처럼 이동한다.
- Black Hole 외형을 유지하되 gameplay footprint는 사람 기준 Galactic 3단계 공 Quasar(`local_level = 2`) 크기를 기준으로 한다.
- 이동 속도와 범위는 tuning 데이터다.
- 논리 위치와 시각 중심을 일치시킨다.
- 하단 Cashout 대상에서 제외한다.
- 다른 공과 달리 일반 Play Field 하단에서 반사한다.
- 흡수해도 성장하지 않으며 일반 공과 Merge하지 않는다.

---

## 인력

주변 활성 공에 제한된 가속도를 적용하고, 모든 일반 Snowball은 접촉 시 흡수한다.

요구:

- 거리에 따라 강해짐
- 최소 거리와 최대 힘 제한
- 패들 반사 후에도 영향
- 공이 경계 밖으로 영구 이탈하지 않음
- 흡수된 공을 일반 Cashout·Merge·Settlement에 중복 반영하지 않음

초기 플레이테스트 seed:

```text
influence_radius = 480 world units
maximum_pull_acceleration = 1200 world units/s²
total_pull_cap = 1500 world units/s²
black_hole_mutual_pull_max = 450 world units/s²
pull_falloff = (1 - distance / influence_radius)²
```

반경 밖의 pull은 0이며 기존 Ball runtime speed cap을 유지한다. 두 Black Hole이 존재하면 일반 공은 두 pull vector의 합을 받되 합산 cap을 한 번 적용한다. 같은 방향에서는 강해지고 두 Black Hole 사이에서는 일부 상쇄될 수 있으므로 항상 정확히 2배가 되는 것은 아니다. Black Hole끼리는 전용 mutual pull로 서로를 끌어당기며 접촉 후 terminal 연출로 전환한다. 수치는 tuning data다.

흡수는 실제 contact에서만 발생한다. 첫 Black Hole 등장 시점 Run Score를 한 번 baseline으로 저장하고, 흡수된 공의 Active Cashout 가치 `12.5%`와 baseline `25%` 중 작은 값을 stage/run score에서 각각 차감한다. 전액 차감으로 첫 Galaxy 흡수 즉시 Run이 끝나던 문제를 피하면서, 고가 공 반복 손실은 여전히 치명적으로 유지하기 위한 첫 플레이테스트 seed다. Stage score는 0에서 clamp하고, Run score가 0 이하가 되면 0으로 고정한 뒤 즉시 Game Over/Run End한다. Time Bonus와 Cashout popup은 없다.

---

## 게임 감각

- 블랙홀이 왼쪽이면 궤도가 왼쪽으로 휨
- 이동하면서 공 무리가 따라 움직임
- 모든 일반 공은 가까워지면 흡수됨
- 높은 단계 공도 궤도를 잃거나 흡수될 위험 속에서 Merge를 계속 노릴 수 있음
- 두 번째 Black Hole 재료를 의도한 곳에 보내기 어려워짐
- 혼돈이지만 패들 조작은 여전히 의미 있음

---

## 두 번째 Black Hole과 최종 시퀀스

Black Hole Phase 중 두 번째 Lv14를 만들면 두 번째 이동 Black Hole entity로 전환한다. 두 Black Hole이 접촉하면 일반 Merge 대신 terminal sequence를 한 번만 실행한다.

```text
contact lock
→ mutual pull / orbit
→ finale explosion
→ gameplay UI hide
→ SNOWBALL EFFECT title
→ CLEAR SCORE (final run score)
→ MAIN MENU
→ RUN END
```

첫 Lv14 생성 즉시 Result로 이동하던 이전 계약은 폐기한다. 두 Black Hole 접촉 이후에는 추가 Stage Shift가 없다. `MAIN MENU`는 메인 화면 복귀를 요청한다.

---

## 시각

우선순위:

1. 회전 링과 별 파티클
2. 곡선 잔상
3. 저음 환경음
4. 가능하면 화면 왜곡 셰이더

셰이더가 일정에 부담이면 생략 가능하다.

---

## 완료 조건

- 블랙홀 위치에 따라 공 궤도가 명확히 변함
- 모든 일반 공이 실제 Black Hole contact에서 흡수됨
- Black Hole이 하단 Cashout되지 않음
- Black Hole 하단 반사, 비성장, 일반 Merge 제외
- 인력이 강해도 두 번째 Black Hole 제작 gameplay가 계속 가능
- 흡수 패널티가 Cashout 가치 `12.5%`와 phase-entry Run Score `25%` 상한으로 계산되어 stage/run에서 차감되고, run score가 0이 되면 즉시 Game Over
- Galactic 최종 국면의 생성량에서 성능 확인
- 첫 Lv14가 Black Hole entity로 정확히 한 번 전환됨
- 두 번째 Black Hole 접촉 시 회전·폭발·UI 제거·타이틀·Clear Score·Main Menu Run End가 한 번만 발생
- Black Hole Phase 발동 후 L3 Frame/Play Field에서 Galactic gameplay가 정상적으로 재개됨


---

## Stage 디자인

`DESIGN/02_STAGE_ART_DIRECTION.md`를 따른다.

- gameplay Black Hole과 좌우 Stage World의 환경 반응을 함께 표현
- 회전 링 / 별 왜곡 / 우주 먼지
- 아케이드 기계는 과부하 상태처럼 보임
- 계기 글리치는 장식이며 실제 HUD 가독성을 깨지 않음
- 논리 Black Hole 위치와 시각 중심은 가능한 한 일치
