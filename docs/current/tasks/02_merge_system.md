# Task 02 — Merge System

## 선행 조건

Task 01이 실행 가능해야 한다.

---

## 목적

같은 레벨 공끼리 접촉하면 상위 공으로 합쳐지는 핵심 규칙을 추가한다.

---

## 포함

- BallDefinition 데이터
- global_level
- 레벨별 반지름·색·점수
- 같은 레벨 근접 판정
- merge lock
- 합체 요청 큐
- 상위 공 생성
- 최고 레벨 기록
- 간단한 합체 플래시 또는 원형 파편
- 점수 formatter의 초기 구조

---

## 제외

- Spatial Grid 최적화 완성
- Stage Shift
- 아이템
- 고급 파티클
- 블랙홀

Task 02에서는 공 수를 제한하고 단순 후보 검사로 기능을 먼저 검증할 수 있다.  
다만 전수 비교 코드는 임시임을 명확히 표시하고 Task 03에서 제거한다.

---

## 초기 공 카탈로그

초기 콘텐츠 목표는 `global_level 0~14`의 총 15종이다. 각 Stage는 세계관에 맞는 local 공 4~5종을 사용하고, 이전 Stage의 최고 공을 다음 Stage의 기본 공으로 공유한다. 정확한 Stage별 배분과 이름은 Content 데이터에서 관리하며, 플레이테스트에서 종류가 과도하다는 피드백이 나오면 축소할 수 있다.

아래 값은 점수 곡선과 초기 테마를 잡기 위한 seed이며 전체 15종의 확정 목록이 아니다.

```text
0 Snowflake       1
1 Snowball        100
2 Big Snowball    10,000
3 Giant Snowball  1,000,000
4 Lunar Snowball  100,000,000
5 Earth Snowball  50,000,000,000
6 Solar Snowball  10,000,000,000,000
```

나머지 global level도 각 Stage의 Ground / Planetary / Galactic / Black Hole 콘셉트가 읽히도록 이름, visual key, 반지름과 점수를 데이터로 정의한다. 값은 코드에 하드코딩하지 않는다.

---

## 합체 규칙

- 같은 global_level만 합체
- 다른 special_type은 Task 02에서 NORMAL뿐
- 같은 프레임에 한 공이 두 합체에 참여 금지
- 결과 레벨 정의가 없으면 더 합체하지 않음
- 새 공은 다음 물리 프레임부터 합체 가능

합체 위치:

```text
(position_a + position_b) / 2
```

합체 결과 velocity는 아직 미정이다. 두 입력 speed의 평균/최대/별도 계산, 새 등급의 base speed 사용 여부, 방향과 cap을 S2의 별도 Merge velocity 계약에서 확정한 뒤 구현한다.

---

## 완료 조건

- 같은 레벨 두 공이 하나의 상위 공으로 합쳐짐
- 공 수가 2 감소 후 1 증가
- 중복 합체 없음
- 다른 레벨은 통과
- 합체 후 렌더 외형과 점수가 바뀜
- 바닥 회수 시 정의된 점수 사용
- 최고 생성 레벨 HUD 표시
- 재시작 시 기록 초기화

---

## 개발 치트

디버그 키 또는 함수:

- 특정 global_level 공 두 개를 가까이 생성
- 활성 공 모두 제거
- 생성 레벨 변경

릴리스 입력에는 노출하지 않는다.

---

## 검증

- Lv0 두 개 → Lv1
- Lv1 두 개 → Lv2
- Lv0 + Lv1 → 합체 안 함
- 세 개가 동시에 겹쳐도 하나의 합체만 발생
- 새 공이 즉시 같은 프레임 재합체하지 않음
- 고레벨 점수 표시가 K/M/B/T로 정상
