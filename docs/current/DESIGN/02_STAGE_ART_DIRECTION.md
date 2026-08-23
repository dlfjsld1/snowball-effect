# Snowball Effect — Stage Art Direction

## 전체 규칙

Stage 변화는 계절 변화가 아니라 **관측 스케일의 폭증**이다.

이전 최고 공이 다음 Stage의 기본 공이 되는 게임 규칙과
배경의 세계 규모가 같은 순간 재기준화되어야 한다.

---

# Stage 0 — Ground

## 목표 감정

> 작고 평화롭다.

초반이 소박해야 후반 뇌절이 강해진다.

## 배경

- 밝은 초원
- 언덕
- 작은 집
- 나무
- 가벼운 구름
- 단순한 픽셀 원경

## 기계 상태

- 정상
- 깨끗함
- 계기판도 여유로움
- 경고등 거의 없음

## 공

- Snowflake
- Snowball
- Big Snowball
- Giant Snowball
- Moon

눈송이는 몇 픽셀 수준의 작은 조각으로 시작한다.

---

# Stage 1 — Planetary

## 목표 감정

> 방금까지 거대했던 눈덩이가 이제 작은 천체처럼 취급된다.

## 배경

- 지구
- 달
- 인공위성
- 우주 구조물
- 대기권/별

## 기계 상태

- 일부 계기 수치 상승
- 패널에 새로운 경고등
- 더 큰 스케일을 측정하는 느낌

## 공

- Moon
- Earth
- Sun
- Supernova
- Galaxy

---

# Stage 2 — Galactic

## 목표 감정

> 화면이 본격적으로 감당하기 어려워진다.

## 배경

- 별무리
- 성운
- 은하
- 우주 먼지
- 느린 원경 움직임

## 기계 상태

- 과부하 경고
- 깜빡이는 계기
- 일부 화면 노이즈 또는 전기 스파크
- 프레임의 작은 떨림 가능

## 공

- Galaxy
- Galaxy Cluster
- Quasar
- Event Horizon
- Black Hole Ball (Lv14)

이 단계부터 파티클 포화가 눈에 띄게 증가한다.

---

## Galactic 최종 국면 — Black Hole 맵 기믹

## 목표 감정

> 기계가 정상 물리의 통제권을 잃었다.

## 배경

- 거대한 블랙홀
- 회전 링
- 별 왜곡
- 중력 렌즈 느낌
- 불안정한 공간

## 게임플레이

블랙홀은 별도 Stage가 아니다. 첫 Lv14 Black Hole Ball이 이동 runtime 기믹으로 전환되며 단순 배경이 아니라 실제 gameplay entity가 된다.

- Play Field 안을 3단계 공 정도의 gameplay footprint로 이동
- 실제 공 궤도를 약하게 끌어당김
- 실제 contact한 모든 일반 Snowball 흡수
- 하단에서 반사하며 성장·Merge하지 않음
- 두 번째 Black Hole과 충돌하면 서로 회전·폭발하며 최종 타이틀 연출로 연결

## 기계 상태

- 심한 과부하
- 계기 숫자 폭주
- 일부 라벨 오류/글리치
- 프레임이 우주 현상을 억지로 담고 있는 느낌

## 공

- Galaxy
- Galaxy Cluster
- Quasar
- Event Horizon
- Black Hole Ball (Lv14)

첫 Lv14 생성 시 Frame과 실제 Play Field가 L2에서 L3로 함께 확장되고, 전환 뒤 같은 Galactic gameplay를 재개한다. 전환된 Black Hole은 compact accretion ring과 고대비 outline을 유지하되 주변 field distortion·grid lensing으로 일반 공과 구분한다. 두 Black Hole의 최종 폭발 뒤 gameplay HUD/UI를 제거하고 `SNOWBALL EFFECT` 제목을 화면의 최종 초점으로 사용한다. 제목 아래에는 `CLEAR SCORE`와 최종 run score를 표시하고 그 아래 `MAIN MENU` 버튼을 둔다.

---

## 공의 크기 재정규화

Stage Shift 후 이전 최고 공은 다음 Stage의 기본 공이 된다. 전환 시 gameplay visual과 collision 크기를 함께 새 Stage의 local Lv0 반지름 `4`로 재정규화한다. 같은 Stage 안에서는 local level에 따라 `4 → 8 → 16 → 32 → 64`로 성장한다.

표현상으로는 공 자체가 줄어든 것이 아니라 관측 스케일이 더 멀리 이동한 것으로 연출한다. `global_level`은 공의 정체성과 점수 데이터를 유지하지만 화면 및 충돌 크기는 현재 Stage의 local level이 결정한다. `visual_radius_scale`은 향후 Scale Shift 화면 연출을 위한 예약값이며 gameplay visual과 collision을 서로 다르게 만드는 용도로 사용하지 않는다.

---

## 기계의 “붕괴”는 연출이다

후반 기계 과부하는 재미있는 프레젠테이션 요소다.

하지 말 것:

- HUD가 실제로 읽히지 않게 깨뜨림
- 입력 지연을 고장처럼 연출
- 공 식별을 방해하는 지속적 화면 글리치

기계가 망가지는 것처럼 보여도 게임은 정확히 작동해야 한다.
