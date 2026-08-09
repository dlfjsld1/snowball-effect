# Snowball Effect — Game Planning v2

## 0. 게임 한 줄 정의

> **레트로 픽셀 아케이드 실험기계 안에서 눈송이를 패들로 튕겨 합체시키고,  
> 고등급 공을 더 키울지 지금 Cashout할지 선택하며,  
> 눈덩이 → 행성 → 은하 → 블랙홀 → 우주 규모까지 폭주시키는 3분 내외 액션 머지 아케이드 게임.**

핵심은 단순히 큰 공을 만드는 것이 아니다.

플레이어는 계속 다음 선택을 한다.

```text
이 공을 계속 살려서 한 단계 더 머지할까?
vs
지금 일부러 떨어뜨려 점수와 시간을 확보할까?
```

이 선택이 Snowball Effect의 핵심 게임성이다.

---

# 1. 핵심 재미

Snowball Effect의 재미는 네 가지가 겹치는 데서 나온다.

1. **패들 조작**
   - 어디에서 받을지
   - 어느 방향으로 보낼지

2. **머지**
   - 같은 단계 공끼리 부딪히게 만들어 상위 공 제작

3. **Cashout 판단**
   - 높은 공을 더 키울지
   - 지금 떨어뜨려 점수 + 시간을 받을지

4. **Scale Shift**
   - 이전 Stage에서 최고 등급이었던 공이
   - 다음 Stage에서는 기본 공으로 쏟아짐

즉:

```text
Control
→ Merge
→ Greed or Cashout
→ More Time
→ Bigger Merge
→ Stage Clear
→ Scale Shift
→ Everything gets absurd
```

---

# 2. 기본 조작

## 이동

- `A / D` : 패들 좌우 이동

## 각도

- `← / →` : 패들 각도 조절

이동과 각도 변경은 동시에 가능하다.

패들 조작은 두 가지 역할을 한다.

### 살리기

공 아래로 이동해 받아서 다시 위로 튕긴다.

### 버리기

일부러 공 아래에서 비켜나 고등급 공을 Cashout한다.

따라서 `A/D`는 단순 생존 조작이 아니라
**보유 / 현금화 판단을 실행하는 조작**이다.

---

# 3. 공과 머지

같은 `global_level`의 공 두 개가 접촉하면:

```text
Level N + Level N
→
Level N+1
```

다른 레벨 공은 MVP에서 서로 통과할 수 있다.

---

## 3.1 머지 가치

머지는 단순 합산이 아니다.

상위 공은 이전 공의 합보다 훨씬 큰 가치를 가진다.

예:

```text
Snowflake       1
Snowball        100
Big Snowball    10,000
Giant Snowball  1,000,000
...
```

점수는 실질적으로 지수함수처럼 폭증한다.

따라서:

> 높은 공을 만드는 것 자체가 압도적으로 이득이다.

하지만 높은 공을 무조건 끝까지 들고 있는 것이 항상 정답은 아니다.

그 이유가 Cashout의 **TIME BONUS**다.

---

# 4. Cashout

공이 패들 아래 Score Zone으로 떨어지면 제거되며
해당 공의 보상을 즉시 획득한다.

```text
Cashout
=
Score
+
Time Bonus
```

바닥은 실패 구역이 아니다.

---

## 4.1 Cashout의 의미

높은 공을 계속 보유:

```text
장점
→ 다음 머지 가능
→ 점수 가치가 훨씬 더 커질 수 있음

위험
→ Stage 시간이 부족해질 수 있음
```

지금 Cashout:

```text
장점
→ 현재 점수 확정
→ Time Bonus 확보
→ 더 오래 플레이 가능

대가
→ 그 공으로 다음 머지를 할 수 없음
```

이 때문에 플레이어는 계속:

> 욕심을 더 낼지, 지금 현금화할지

판단한다.

---

# 5. Time Bonus

각 Stage는 공의 local level별 `time_bonus` 값을 가진다.

같은 global ball이 다음 Stage에서 다른 local level이 될 수 있으므로
Time Bonus를 BallDefinition의 고정값으로 저장하지 않는다.

시간 증가는 점수처럼 폭발적으로 커지지 않는다.

목적은:

- 고등급 Cashout에 의미 부여
- 플레이 시간을 조금 연장
- 추가 머지 기회 제공
- 시간 압박과 욕심의 균형 생성

이다.

초기 테스트 방향:

| Stage 내 상대 등급 | Time Bonus 예시 |
|---|---:|
| 기본 공 / Local Lv0 | 0s |
| Local Lv1 | 소량 |
| Local Lv2 | 의미 있는 시간 |
| Local Lv3 | Stage Clear |

정확한 값은 플레이테스트로 조정한다.

---

## 5.1 중요한 규칙

직접 Cashout:

```text
Score + Time Bonus
```

Time Up 후 화면에 남은 공 정산:

```text
Score Only
```

**최종 정산에서는 Time Bonus를 주지 않는다.**

그래야 플레이 중 일부러 높은 공을 떨어뜨릴 이유가 생긴다.

---

# 6. Stage 구조

각 Stage는 독립적인 짧은 라운드다.

현재 Stage:

1. Ground
2. Planetary
3. Galactic
4. Black Hole

각 Stage에는:

- 기본 공
- 중간 공
- 최고 공
- 제한 시간
- Clear Score
- Spawn Rate

가 있다.

---

# 7. Stage Clear 조건

Stage를 통과하는 방법은 두 가지다.

---

## 7.1 최고 공 제작 — 즉시 Clear

현재 Stage의 최고 공을 만들면 즉시 Stage Clear.

예:

```text
Ground

Snowflake
→ Snowball
→ Big Snowball
→ Giant Snowball

Giant Snowball 생성
→ STAGE CLEAR
```

점수 조건은 보지 않는다.

이것이 가장 좋은 클리어 방식이다.

---

## 7.2 Time Up — Score Clear

최고 공을 만들기 전에 시간이 0이 되면:

```text
TIME UP
```

그 순간:

```text
기존 Cashout Score
+
화면에 남아 있는 모든 공의 현재 Score Value
=
Final Stage Score
```

화면 공은 자동 정산한다.

Time Bonus는 발생하지 않는다.

그 후:

```text
Final Stage Score >= Clear Target
```

이면 다음 Stage로 진출.

부족하면 Run 종료.

---

# 8. Stage 종료 흐름

## 최고 공으로 Clear

```text
Top Ball Created
↓
STAGE CLEAR
↓
남은 공 Final Settlement
↓
Score 정산
↓
SCALE SHIFT
↓
Next Stage
```

## 시간 종료로 Clear

```text
TIME UP
↓
남은 공 Final Settlement
↓
Final Stage Score 계산
↓
Clear Target 판정
├─ PASS → SCALE SHIFT
└─ FAIL → RUN END
```

---

# 9. Final Settlement

Stage 종료 시 화면에 남은 모든 공을 한 번에 정산한다.

연출:

- 공들이 점수판 또는 화면 중심으로 빨려 들어감
- 공마다 점수 숫자가 빠르게 누적
- 마지막에 Stage Score 확정

중요:

- 실제로 남은 공끼리 다시 머지시키지는 않음
- 현재 각 공의 기본 `score_value`를 합산
- Time Bonus는 적용하지 않음
- Active Cashout 전용 modifier는 적용하지 않음

---

# 10. SCALE SHIFT

다음 Stage로 넘어갈 때 발생하는 핵심 연출.

중요한 규칙:

> 이전 Stage의 최고 공이 다음 Stage의 기본 공이 된다.

예:

```text
Ground의 최고
Giant Snowball
↓
Planetary의 기본 공
Giant Snowball
```

따라서:

> “방금 그렇게 힘들게 만든 게 이제 비처럼 떨어진다.”

라는 경험을 만든다.

---

## 10.1 Scale Shift에서 바뀌는 것

동시에 변경:

- Stage World
- 기본 공
- Spawn Rate
- 공의 화면상 Scale 기준
- 파티클 밀도
- 사운드
- 계기판 상태
- 일부 물리 규칙

---

# 11. Stage 구성

## Stage 0 — Ground

```text
Snowflake
→ Snowball
→ Big Snowball
→ Giant Snowball
```

배경:

- 밝은 초원
- 언덕
- 집
- 나무

기계:

- 정상
- 여유로운 계기판

Spawn:

- 초기 약 6/s

---

## Stage 1 — Planetary

```text
Giant Snowball
→ Lunar Snowball
→ Earth Snowball
→ Solar Snowball
```

배경:

- 지구
- 달
- 위성
- 우주 구조물

Spawn:

- 초기 약 15/s

---

## Stage 2 — Galactic

```text
Solar Snowball
→ Nebula Snowball
→ Galaxy Snowball
→ Black Hole Snowball
```

배경:

- 성운
- 은하
- 우주 먼지
- 별무리

Spawn:

- 초기 약 35/s

기계:

- 과부하 징후
- 경고등
- 일부 글리치

---

## Stage 3 — Black Hole

```text
Black Hole Snowball
→ Big Bang Snowball
→ Universe Snowball
→ Multiverse Snowball
```

배경:

- 거대한 블랙홀
- 회전 링
- 별 왜곡

Spawn:

- 초기 약 80/s

물리:

- 이동하는 블랙홀이 공을 약하게 끌어당김

기계:

- 우주급 현상을 더 이상 감당하지 못하는 느낌

---

# 12. Black Hole Stage 종료

마지막 Stage이므로 다음 Stage는 없다.

## Multiverse 완성

```text
Multiverse Snowball
→ PERFECT / MAX SCALE CLEAR
→ Final Settlement
→ Result
```

## Time Up

```text
TIME UP
→ Final Settlement
→ Result
```

마지막 Stage에서는 다음 Stage 진출용 Score Cut은 필요하지 않다.

최종 점수 경쟁으로 끝낸다.

---

# 13. 화면 구조

16:9 전체가 Play Field가 아니다.

```text
[ STAGE WORLD ] | [ CENTRAL PLAY FIELD ] | [ STAGE WORLD ]
```

중앙 세로 영역:

- 공
- 머지
- 패들
- 아이템
- Cashout

좌우:

- Stage 세계
- Retro Pixel Arcade Machine
- 계기판
- 장치
- 배경 연출

---

# 14. 디자인 컨셉

## 메인 방향

> **Retro Pixel Arcade Machine × Cosmic Escalation**

초반:

> 작은 눈덩이 실험기계

후반:

> 우주급 현상을 억지로 담고 있는 과부하 아케이드 장치

키워드:

- pixel
- chunky
- industrial
- arcade
- mechanical
- rough
- cosmic
- absurd

---

# 15. 일반 머지 연출

Vampire Survivors처럼 화면 곳곳에서 계속 보상이 터지는 느낌.

저등급:

- 작은 눈가루
- 작은 플래시
- 짧은 효과음

중등급:

- 얼음 파편
- 링
- 점수 숫자

고등급:

- 큰 파티클
- 화면 흔들림
- 히트스톱
- 특별 사운드

---

# 16. 고등급 CUT-IN

중요한 공 또는 특수 효과는 짧은 CUT-IN을 사용할 수 있다.

일반 동작:

```text
중요 이벤트 확정
↓
현재 게임 화면 freeze
↓
Play Field + Stage World 전체 dim
↓
픽셀 기계 패널 진입
↓
공 이름 / 이미지 / VALUE
↓
빠르게 퇴장
↓
게임 즉시 재개
```

초기 시간:

```text
0.45 ~ 0.70초
```

1초 이상은 기본적으로 피한다.

---

## 16.1 CUT-IN과 Scale Shift

최고 공은 곧 Stage Clear를 발생시키므로
일반 CUT-IN과 Scale Shift를 연속해서 중복하지 않는다.

예:

```text
Big Snowball
→ CUT-IN 가능

Giant Snowball
→ SCALE SHIFT
```

Planetary:

```text
Earth Snowball
→ CUT-IN 가능

Solar Snowball
→ SCALE SHIFT
```

Galactic:

```text
Galaxy Snowball
→ CUT-IN 가능

Black Hole Snowball
→ SCALE SHIFT
```

---

# 17. 아이템

## Blizzard

일정 시간 Spawn Rate 증가.

## Magnet

같은 단계 공끼리 약하게 끌어당겨 머지를 유도.

## Fire Core

패들이 일정 시간 Fire 상태.

맞은 공:

```text
Fire Snowball
```

특징:

- 같은 단계 일반 공과 머지 가능
- Fire 상태 전파
- Cashout Score 배수
- 눈 + 불꽃 파티클

---

# 18. 게임의 전략 구조

게임의 실질적인 판단은 다음과 같다.

```text
낮은 공
→ 가능한 한 머지

높은 공
→ 더 머지할 것인가?
→ Cashout할 것인가?
```

시간이 충분하면:

```text
KEEP
→ 더 높은 단계 노림
```

시간이 부족하면:

```text
CASHOUT
→ 점수 확보
→ 시간 확보
→ 새 공들로 추가 머지
```

따라서 가장 높은 점수를 노리는 플레이는 단순히:

> 모든 공을 계속 살린다

가 아니다.

---

# 19. 밸런스에서 확인할 것

정확한 수치는 구현 후 플레이테스트한다.

특히:

### Time Economy

평균적으로 Cashout으로 얻는 시간이
플레이에 소비되는 시간보다 지나치게 많으면
Stage가 사실상 끝나지 않는다.

### Clear Score

최고 공을 못 만들더라도
충분히 잘 머지한 플레이어는 Score Clear가 가능해야 한다.

반대로 기본 공만 계속 Cashout해서
쉽게 Clear Target을 넘으면 안 된다.

### Player Agency

초반에는 패들 조작을 잘한 플레이어가
가만히 있는 플레이어보다 확실히 빠르게 성장해야 한다.

후반에는 Snowball Effect답게
자동 연쇄 머지 비중이 늘어도 된다.

---

# 20. 플레이 경험 곡선

## Stage 초반

- 공 적음
- 조작 정확성 중요
- 머지 목표가 명확

## Stage 중반

- 공 증가
- Cashout 판단 시작
- 높은 공과 낮은 공이 동시에 존재

## Stage 후반

- 시간 압박
- 높은 공 Cashout 유혹
- 최고 공 제작 경쟁

## Scale Shift

- 모든 기준 리셋
- 이전 최고 공이 기본 공으로 등장
- 플레이어가 즉시 스케일 상승 체감

---

# 21. MVP 핵심

반드시:

- A/D 이동
- 방향키 각도
- 같은 단계 머지
- 지수적 점수 폭증
- Cashout
- Stage local level별 Time Bonus
- Time Up Final Settlement
- 최고 공 즉시 Stage Clear
- Score Cut Stage Clear
- Scale Shift
- 이전 최고 → 다음 기본
- Stage별 Spawn 증가
- 중앙 Play Field + 좌우 Stage World
- 픽셀 아케이드 기계
- 고등급 연출
- Web Export
- Result

---

# 22. 일정 부족 시 제거 순서

1. Magnet
2. 복잡한 Fire 전파
3. Black Hole 화면 왜곡 Shader
4. 일부 CUT-IN 종류
5. 개별 고급 공 애니메이션
6. 추가 배경 디테일

제거하지 않음:

- 머지
- Cashout
- Time Bonus
- Stage Clear 두 방식
- Final Settlement
- Scale Shift
- 이전 최고 → 다음 기본
- 패들 이동 + 각도

---

# 23. 현재 게임의 핵심 한 문장

> **더 큰 공을 만들수록 점수는 폭발하지만,  
> 그 공을 언제 떨어뜨려 점수와 시간을 확보할지 결정해야 하는  
> 스케일 폭주형 액션 머지 게임.**
