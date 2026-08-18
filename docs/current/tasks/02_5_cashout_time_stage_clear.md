# Task 02.5 — Cashout, Time Bonus, Stage Clear

## 목적

Snowball Effect의 핵심 전략인 다음 선택을 실제 플레이 규칙으로 구현한다.

```text
KEEP for bigger merge
vs
CASHOUT for Score + Time
```

선행:

- Task 01 최소 루프
- Task 02 머지 시스템

---

## 1. 데이터

BallDefinition:

```text
score_value
```

StageDefinition:

```text
base_time
clear_score
base_global_level
top_global_level
spawn_rate
time_bonus_by_local_level
```

같은 global ball이 Stage에 따라 다른 local level이 되므로 Time Bonus를 BallDefinition에 저장하지 않는다.

초기값:

```text
Local Lv0 = +0s
Local Lv1 = +0.25s
Local Lv2 = +0.5s
Local Lv3 = +1s
Local Lv4 = +2s
```

Ground의 Moon과 Planetary의 Galaxy를 포함한 local Lv4는 생성 즉시 Stage Clear가 되지 않으며 일반 Active Cashout 대상이다. 따라서 일반 Cashout Time Bonus 최댓값은 Local Lv4의 `+2s`다. Galactic의 Black Hole은 별도 최종 국면 계약을 따른다.

초기 `base_time` 테스트 seed는 Ground 45초, Planetary 40초, Galactic 35초다. Lv14 Black Hole은 Galactic top Ball이며, 첫 Lv14는 마지막 Galactic Stage 안의 이동 Black Hole runtime 기믹으로 전환된다.
기본 Run의 ordered Stage chain은 Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`다. Lv7 `Red Giant`와 Lv9 `Nebula`는 15종 BallCatalog에 보존하지만, 최근 팀 합의에 따라 기본 Run에서는 의도적으로 제외한다. 이는 누락이나 Resource drift가 아니며 Stage별 정확히 5종의 족보를 유지하기 위한 콘텐츠 배치다.
`clear_score`는 마지막 Stage를 제외한 Stage별 데이터다. Ground는 Giant Snowball(`1e6`) 기준 `4e6`, Planetary는 Supernova(`5e17`) 기준 `2e18`을 초기값으로 사용한다. local Lv4 생성 여부와 무관하게 Time Up 뒤 Final Settlement 결과로 비교한다. 마지막 Galactic Stage는 `clear_score`를 판정에 사용하지 않으며 데이터 기본값은 `0`이다.
둘 다 플레이테스트 전 확정값이 아니다.

초기 구현에는 Stage 시간 cap을 넣지 않는다.

---

## 2. 점수 Source of Truth

모든 점수 이벤트에서:

```text
stage_score += amount
run_score += amount
```

- `stage_score`: 현재 Stage 표시와 clear 판정용 부분합
- `run_score`: 전체 Run 누적 합

Stage 종료 시 `run_score += stage_score`를 다시 수행하지 않는다.

---

## 3. 일반 Active Cashout

공이 Score Zone을 통과하면:

```text
cashout_score = calculate_cashout_score(ball)
local_level = stage.local_ball_levels.find(ball.global_level)
time_bonus = stage.time_bonus_by_local_level[local_level]

stage_score += cashout_score
run_score += cashout_score
stage_time_left += time_bonus
remove_ball_without_settlement()
```

Active Cashout 전용 item modifier는 `calculate_cashout_score()`에서만 적용한다.
Time Bonus 계산과 섞지 않는다.
`local_level == -1`이면 현재 Stage 밖의 잘못된 공이므로 보너스를 추측하지 않고 data/runtime 오류로 처리한다.

UI 예:

```text
+50B
TIME +1.0s
```

---

## 4. Physics Tick 순서와 종료 우선순위

한 physics tick은 다음 순서로 처리한다.

```text
1. stage_time_left -= delta
2. 이동 / 충돌 / Merge 처리
3. 이번 tick의 Merge 확정 및 local Lv3/Lv4 최초 생성 여부 기록
4. 이번 tick의 Active Cashout Score / Time Bonus 반영
5. 종료 판정
   - stage_time_left <= 0 → TIME_UP
   - 그 외 → PLAYING
```

따라서 시간이 잠시 0 이하가 되어도 같은 tick의 Cashout으로 양수가 되면 Time Up을 취소하고 계속 플레이한다.
같은 tick에 local Lv4 생성과 Time Up 조건이 모두 있어도 Lv4 생성은 종료 사유가 아니다. Merge/Cashout commit 뒤 Time Up 경로를 사용한다.

---

## 5. Local Lv4 최초 발견

현재 Stage 최고 `global_level` 공이 Run에서 처음 생성되면:

1. Merge 결과를 정상 commit한다.
2. Run-scoped discovery를 한 번 기록한다.
3. 해당 공의 `FIRST CONTACT` CUT-IN을 요청한다.
4. Ground/Planetary는 CUT-IN 뒤 gameplay를 재개한다.
5. Galactic의 첫 Black Hole만 CUT-IN 뒤 Black Hole Phase 전환을 이어간다.

local Lv4 생성은 Stage Clear나 Final Settlement를 직접 요청하지 않는다.

---

## 6. Time Up

tick의 Cashout까지 반영한 뒤 `stage_time_left <= 0`이면:

1. `TIME_UP_LOCKED`
2. Spawn / Input / gameplay 정지
3. Final Settlement
4. 마지막 Stage가 아니면 `stage_score >= clear_score` 판정
5. 성공 → `CLEARED` → 축하 메시지와 `Next Stage` 확인 대기
6. matching `Next Stage` 요청 → Scale Shift
7. 실패 → `FAILED` → Run End
8. 마지막 Stage → Result

---

## 7. Final Settlement

Settlement는 일반 Cashout과 다른 전용 경로다.

```text
SETTLING 진입
→ active ball index snapshot
→ snapshot 공 settlement_reserved/deactivated
→ settlement_score = 각 공의 base score_value 합
→ stage_score += settlement_score
→ run_score += settlement_score
→ 공 제거
→ settlement_applied = true
→ 정산 연출
```

금지:

- Time Bonus
- Active Cashout 전용 modifier
- 추가 Merge
- 일반 Cashout 함수 호출
- `run_score += stage_score`
- Settlement 중복 적용
- 활성 공마다 무거운 씬/Tween 생성

---

## 8. Stage 상태

```text
READY
PLAYING
CLEAR_LOCKED
TIME_UP_LOCKED
SETTLING
CLEARED
SHIFTING
FAILED
FINISHED
```

Stage 진입 시:

```text
stage_score = 0
stage_time_left = stage.base_time
settlement_applied = false
```

`run_score`, 통계, 최고 기록은 유지한다.

---

## 9. 코어와 선택 아이템 경계

코어 게임:

- Merge
- Cashout
- Time Bonus
- Stage Timer
- Settlement
- Scale Shift

선택 아이템 계층:

- Blizzard
- Fire Core
- Magnet

선택 아이템을 제거해도 이 Task의 코어 상태 흐름과 Settlement 규칙은 바뀌지 않아야 한다.

---

## 10. 검증

### Cashout 회복

- tick 시작 시 시간이 0 이하가 되어도 같은 tick의 Cashout으로 양수가 되면 PLAYING 유지
- Local Lv0 Cashout은 시간을 늘리지 않음
- Local Lv1/Lv2가 Stage 데이터의 시간만큼 증가

### 종료 우선순위

- 같은 tick의 local Lv4 + Time Up → Merge/Cashout commit 뒤 Time Up
- local Lv4 생성 후 gameplay와 Active Cashout이 계속됨

### Settlement

- snapshot의 기본 점수 합산
- Top Ball 포함
- Time Bonus 0
- Active Cashout 전용 modifier 0
- 재호출해도 점수 추가 0
- Stage Score와 Run Score가 같은 settlement amount만큼 한 번 증가

### Score Clear

- `stage_score >= clear_score` → 성공
- 미달 → 실패
- Stage 종료 시 Run Score에 Stage Score를 다시 더하지 않음

### Time Economy 계측

- 실제 Stage 플레이 시간
- Cashout 총 획득 시간
- 초당 평균 획득 시간
- local level별 Cashout 수
- 종료되지 않는 Stage 발생 여부

---

## 작업 보고

- 사용한 초기 `base_time`, `clear_score`, `time_bonus_by_local_level`
- 정상 Clear / Score Clear / Fail / Cashout 회복 테스트 결과
- 점수 중복과 Settlement 재호출 테스트 결과
- Time Economy 측정값
- 변경 파일
- Codex collaboration log 업데이트

