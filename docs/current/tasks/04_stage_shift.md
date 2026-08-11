# Task 04 — Stage Shift

## 목적

게임의 핵심 정체성인 스케일 상승을 구현한다.

---

## 구현 스테이지

1. Ground
2. Planetary
3. Galactic


## 필수 규칙

- 스테이지마다 base_global_level과 top_global_level이 있음
- 최고 공 최초 생성 시 Stage Clear; Settlement 완료 후 다음 스테이지
- 이전 최고 공 = 다음 기본 공
- 생성량 증가
- 화면상 크기 정규화
- StageDefinition의 `visual_radius_scale`로 렌더 크기 보정
- 새 기본 레벨보다 낮은 공 정리
- 좌우 Stage World 배경 전환
- HUD 공 족보를 새 Stage의 local 공 5~6종으로 교체
- Retro Pixel Arcade Machine의 Stage 상태 변화
- `SCALE SHIFT` 발표
- Time Up Score Clear 후에도 동일한 Scale Shift 진입

---

## 초기 데이터

```text
Ground:
base 0, top 4, spawn 6/s

Planetary:
base 4, top 9, spawn 15/s

Galactic:
base 9, top 14, spawn 35/s
```

---

## 전환 순서

1. Stage Clear 결정 (Top Ball 또는 Score Clear)
2. 중복 전환 잠금
3. Final Settlement 완료 확인
4. 시뮬레이션 짧게 감속
5. `SCALE SHIFT`
6. Stage 데이터 변경
8. 렌더 크기 스케일 재설정
9. 배경 전환
10. 새 Stage 공 족보 갱신
11. 새 생성량 적용
12. 시뮬레이션 정상화

---

## 주의

- 최고 공이 생성되자마자 바닥으로 떨어져도 Stage는 전환됨
- 같은 최고 공이 여러 개 생겨도 한 번만 전환
- 전환 중 새 전환 요청 무시
- 전환 후 기존 고레벨 공 인덱스와 정의가 깨지지 않음
- `run_score`, 통계, 최고 기록은 유지
- 새 Stage의 `stage_score`는 0, `stage_time`은 해당 Stage의 `base_time`으로 초기화
- 새 기본 공이 화면상 너무 커 보이지 않게 정규화

---

## 완료 조건

- Ground → Planetary
- Planetary → Galactic
- 배경과 생성량 변화
- 새 기본 공 생성
- 이전 저레벨 공 정리
- Scale Shift 연출
- 강제 전환 디버그 기능
- 재시작 시 Ground로 복귀


---

## 디자인 계약

`DESIGN/02_STAGE_ART_DIRECTION.md`를 따른다.

- Ground는 일부러 소박하고 평화롭게 시작
- Planetary는 천체 규모의 급격한 확대
- Galactic은 화면/계기 밀도 증가
- 후반 기계는 과부하처럼 보여도 실제 HUD와 조작 가독성은 유지
- 이전 최고 공의 화면상 크기는 새 Stage 기준으로 재정규화
- 재정규화는 Stage 데이터가 소유하며 BallDefinition의 물리 반지름을 변경하지 않음
