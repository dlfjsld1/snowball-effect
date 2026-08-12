# Task 03 — Mass Simulation and Spatial Grid

## 목적

공 수가 증가해도 웹에서 실행 가능한 구조로 바꾼다.

---

## 필수 변경

- 공 데이터 SoA 배열
- free index 재사용
- active index 효율적 순회
- Uniform Grid / Spatial Hash
- 같은 레벨 후보만 검사
- 합체 큐
- 디버그 성능 HUD
- 스트레스 테스트 씬 또는 모드

---

## 금지

- 모든 쌍 전수 비교를 남겨두고 단순히 공 수 제한
- 공마다 Node 생성
- Dictionary와 Array를 매 프레임 과도하게 새로 생성
- 성능을 위해 합체 규칙 삭제

---

## 그리드 요구

- 플레이 영역 기준 고정 열/행
- 셀 등록 시 기존 버퍼 재사용
- 자기 셀과 인접 셀만 검사
- 쌍 중복 방지
- 레벨 필터
- 고레벨 큰 공은 필요한 만큼 더 넓은 셀 범위 검사

---

## 측정 항목

```text
FPS
physics_ms
active_balls
spawn_rate
candidate_checks/frame
merges/frame
max_active_balls
```

---

## 스트레스 시나리오

1. 합체 비활성, 기본 공 100/500개
2. 합체 활성, 500개
3. stretch/torture: 합체 비활성/활성 1,000개
4. 생성량 80/s, 30초
5. 패들 이동·회전 지속
6. 점수 구역에서 대량 제거
7. 재시작 후 메모리와 공 수 정상화

---

## 완료 조건

- 전수 비교 제거
- 실제 Web build의 동시 활성 논리 공 500개에서 최저 30 FPS 이상
- 500개에서 가능하면 60 FPS에 근접
- 1,000개 stretch/torture 결과와 병목 기록(30 FPS 미달은 필수 Gate 실패로 취급하지 않음)
- Web Export와 실제 브라우저에서 측정
- 반복 생성·제거에서 프레임 스파이크가 지속되지 않음
- 후보 검사 수가 N²보다 현저히 적음
- 결과가 Task 02 규칙과 동일

---

## 최적화 우선순위

1. 불필요한 객체 생성 제거
2. 후보 검사 감소
3. 렌더 배치
4. 업데이트 빈도 분리
5. 저수준 RenderingServer

처음부터 5번으로 가지 않는다.

현재 동시 활성 공 규모의 초기 가정은 일반 플레이 peak 약 300개, release 검증 500개다. 후반 Stage·Merge·FX·Black Hole이 실제로 연결되면 telemetry로 peak를 다시 측정하며, 이 수치는 Spawn 총량이 아니라 한 frame에 살아 있는 active ball 수를 뜻한다.
