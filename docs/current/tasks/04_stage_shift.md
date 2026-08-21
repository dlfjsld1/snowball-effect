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
- Ground/Planetary의 최고 공 최초 생성은 FIRST CONTACT discovery/CUT-IN만 요청하며 Stage Clear하지 않음
- 이전 최고 공 = 다음 기본 공
- 생성량 증가
- gameplay 공 크기 재정규화: 새 Stage local Lv0의 visual/collision 반지름을 `4`로 초기화
- 같은 Stage 안에서는 local level에 따라 visual/collision 반지름을 `4 → 8 → 16 → 32 → 64`로 사용
- 새 기본 레벨보다 낮은 공 정리
- 좌우 Stage World 배경 전환
- HUD 공 족보를 새 Stage의 local 공 5종 세로 목록으로 교체하고 첫 공만 공개
- Stage 이름(`Ground`/`Planetary`/`Galactic`)을 persistent HUD에 갱신
- Retro Pixel Arcade Machine의 Stage 상태 변화
- `SCALE SHIFT` 발표
- non-final Stage의 clear score 도달 직후 Clear 잠금과 Final Settlement를 완료하고, 축하 UI의 matching `NEXT STAGE(clear_id)` 요청 뒤 Scale Shift 진입

---

## 초기 데이터

```text
Ground:
base 0, top 4, spawn 6/s

Planetary:
levels [4, 5, 6, 8, 10], spawn 15/s

Galactic:
levels [10, 11, 12, 13, 14], spawn 35/s
```

---

## 전환 순서

1. non-final Stage의 clear score 도달 → Clear 잠금과 Final Settlement
2. 중복 전환 잠금
3. Final Settlement 완료 확인
4. `CLEARED` 축하 UI와 `NEXT STAGE` 표시; matching `clear_id` 요청까지 입력·timer·spawn 잠금 유지
5. matching 요청을 한 번 수락하고 별도 `shift_id` 발급
6. 시뮬레이션 짧게 감속
7. `SCALE SHIFT`
8. Stage 데이터 변경
9. 렌더 크기 스케일 재설정
10. 배경 전환
11. 새 Stage 이름과 공 족보 갱신; 세로 5칸에서 첫 공만 공개
12. 새 생성량 적용
13. 시뮬레이션 정상화

---

## 주의

- local Lv4 생성만으로 Stage를 전환하지 않음
- `clear_id`와 Shift 연출 완료용 `shift_id`를 섞지 않음
- 전환 중 새 전환 요청 무시
- 전환 후 기존 고레벨 공 인덱스와 정의가 깨지지 않음
- `run_score`, 통계, 최고 기록은 유지
- 새 Stage의 `stage_score`는 0, `stage_time`은 해당 Stage의 `base_time`으로 초기화
- 새 공을 처음 만들 때만 해당 Stage 족보의 다음 아이콘·이름을 공개하고 이미 공개된 항목은 중복 갱신하지 않음
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
- 이전 최고 공은 새 Stage의 local Lv0가 되며 visual/collision 반지름 모두 `4`로 재정규화
- runtime 크기의 source of truth는 현재 Stage의 ordered `local_ball_levels`이고, BallDefinition의 전역 `radius`는 catalog/fallback seed로만 사용
