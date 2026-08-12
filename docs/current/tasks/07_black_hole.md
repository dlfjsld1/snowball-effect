# Task 07 — Galactic Black Hole Map Gimmick

## 목적

마지막 Galactic Stage의 최종 국면에서 물리 규칙을 바꿔 기존 조준법을 흔든다. Black Hole은 별도 Stage나 Ball이 아니라 Galactic 안에서 발동하는 이동 맵 기믹이다.

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
Final Snowball (working title)
```

Lv14 최종 공은 Black Hole 기믹과 다른 눈덩이 계열 공이다. `black_hole_phase_enabled`는 Galactic 안에서 최종 국면을 활성화할 수 있는지를 뜻하며, 정확한 발동 조건은 S8 데이터 계약에서 확정한다.

## Black Hole Phase Transition

- 발동 시 Stage는 바뀌지 않고 `Galactic`을 유지한다.
- spawn·timer·input을 전환 중에만 잠근다.
- Frame과 실제 Play Field가 L2 `920`에서 L3 `1080`으로 함께 좌우 대칭 확장한다.
- Presentation 완료와 동일한 `phase_id`를 확인한 뒤 새 logical Rect를 활성화하고 gameplay를 재개한다.
- 이 전환은 terminal presentation이 아니며 Final Result로 직접 이동하지 않는다.

---

## 블랙홀 이동

- 화면 상단에서 좌우 왕복
- 사인파 또는 부드러운 Tween
- 이동 속도와 범위는 Stage 데이터
- 논리 위치와 시각 중심 일치

---

## 인력

모든 활성 공에 약한 가속도.

요구:

- 거리에 따라 강해짐
- 최소 거리와 최대 힘 제한
- 패들 반사 후에도 영향
- 공이 경계 밖으로 영구 이탈하지 않음

게임용 근사치 사용.

---

## 게임 감각

- 블랙홀이 왼쪽이면 궤도가 왼쪽으로 휨
- 이동하면서 공 무리가 따라 움직임
- 같은 레벨이 모여 연쇄 합체 가능
- 높은 공을 의도한 곳에 보내기 어려워짐
- 혼돈이지만 패들 조작은 여전히 의미 있음

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
- 중력이 강해도 게임이 계속 진행
- 공이 블랙홀에 영구 고정되지 않음
- Galactic 최종 국면의 생성량에서 성능 확인
- Lv14 최종 공 생성과 결과 화면 정상
- Black Hole Phase 발동 후 L3 Frame/Play Field에서 Galactic gameplay가 정상적으로 재개됨


---

## Stage 디자인

`DESIGN/02_STAGE_ART_DIRECTION.md`를 따른다.

- 좌우 Stage World에서 거대한 블랙홀을 표현
- 회전 링 / 별 왜곡 / 우주 먼지
- 아케이드 기계는 과부하 상태처럼 보임
- 계기 글리치는 장식이며 실제 HUD 가독성을 깨지 않음
- 논리 블랙홀 위치와 시각 중심은 가능한 한 일치
