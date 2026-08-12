# Snowball Effect — Product Brief

## 1. 한 줄 피치

중앙의 픽셀 아케이드 실험 챔버에서 눈송이를 패들로 튕겨 합체시키고,
**고등급 공을 더 키울지 지금 떨어뜨려 점수와 시간을 확보할지 선택하면서**
눈덩이 → 행성 → 은하 → 블랙홀 → 우주 규모까지 폭주시키는 액션 머지 아케이드 게임.

---

## 2. 핵심 게임성

Snowball Effect의 실제 판단은 다음 한 문장이다.

> **더 머지해서 압도적인 점수를 노릴 것인가, 지금 Cashout해서 점수와 시간을 확보할 것인가?**

플레이어는 패들로 공을 살리기만 하지 않는다.

- `A / D`: 어디에서 공을 받을지 결정
- `← / →`: 어느 방향으로 다시 보낼지 결정
- 일부러 패들에서 비켜남: 지금 공을 Cashout할지 결정

따라서 패들은 `Save / Aim / Cashout`을 모두 수행한다.

---

## 3. 핵심 루프

```text
Stage Start
→ 기본 공 낙하
→ 패들 반사
→ 같은 단계 머지
→ 고등급 공 생성
→ KEEP or CASHOUT
   ├─ KEEP → 더 높은 머지 / 폭발적인 점수 가치
   └─ CASHOUT → Score + Time Bonus
→ Stage 최고 공 제작?
   ├─ YES → 즉시 Stage Clear
   └─ NO → 시간 계속 진행
→ Time Up?
   ├─ 화면 공 Final Settlement (Score Only)
   ├─ clear_score 이상 → Stage Clear
   └─ 미달 → Run End
→ 성공 시 SCALE SHIFT
→ 이전 최고 공이 다음 Stage의 기본 공
```

---

## 4. 점수와 시간

점수는 의도적으로 폭증한다.

```text
1
→ 100
→ 10,000
→ 1,000,000
→ 100M
→ 50B
→ 10T
→ ...
```

합체는 가치 보존이 아니라 **가치 폭발**이다.

각 Stage에는 local level별 `time_bonus`가 있다.

`time_bonus`는 같은 global ball이라도 현재 Stage의 local level에 따라 달라지며 점수처럼 폭증하지 않는다.
높은 공을 Cashout했을 때 몇 초의 추가 기회를 주는 완만한 자원이다.

중요:

```text
Active Cashout = Score + Time Bonus
Final Settlement = Score Only
```

이 차이 때문에 공을 계속 화면에 들고 있는 것이 항상 정답이 아니다.

---

## 5. Stage Clear

한 Stage를 통과하는 방법은 두 가지다.

### Top Ball Clear

현재 Stage 최고 공을 만들면 즉시 성공.

### Score Clear

시간이 먼저 끝났다면:

```text
Cashout Score
+
화면에 살아 있던 공의 현재 Score Value
=
Final Stage Score
```

`Final Stage Score >= clear_score`면 성공.

마지막 Galactic Stage는 다음 Stage가 없으므로 Time Up 후 최종 결과로 이동한다.

---

## 6. SCALE SHIFT

성공한 Stage가 끝나면 남은 공을 정산하고 Scale Shift가 발생한다.

핵심:

> 이전 Stage의 최고 공이 다음 Stage의 기본 공이 된다.

방금 어렵게 만든 공이 다음 순간 기본 공처럼 쏟아지는 것이
Snowball Effect라는 제목을 직접 체감시키는 핵심 장치다.

동시에:

- Stage World
- 기본 공
- Spawn Rate
- visual scale
- 파티클 밀도
- 사운드
- 기계 과부하 상태
- 일부 물리 규칙

이 재기준화된다.

---

## 7. Stage 구성

### Ground
Snowflake → Snowball → Big Snowball → Giant Snowball → Moon

### Planetary
Moon → Earth → Sun → Supernova → Galaxy

### Galactic
Galaxy → Galaxy Cluster → Quasar → Event Horizon → Final Snowball (working title)

전역 Ball catalog는 `global_level 0~14`의 15종을 유지한다. 기본 Run의 Stage별 ordered chain은 Ground `[0, 1, 2, 3, 4]`, Planetary `[4, 5, 6, 8, 10]`, Galactic `[10, 11, 12, 13, 14]`이며, Lv7 `Red Giant`와 Lv9 `Nebula`는 visual catalog에는 남지만 기본 Stage chain에서는 사용하지 않는다.

Black Hole은 별도 Stage나 Lv14 Ball이 아니다. Galactic 안에서 발동하는 최종 국면 맵 기믹이며, 발동 시 네 번째 Frame profile인 `Black Hole Phase`로 확장된 뒤 같은 Galactic gameplay가 계속된다. Lv14 최종 공의 정식 명칭은 Content 합의 전까지 `Final Snowball (working title)`로 둔다.

초기 Spawn 테스트 방향:

```text
6/s → 15/s → 35/s
```

정확한 Stage 시간, `clear_score`, `time_bonus`는 플레이테스트 데이터로 조정한다.

---

## 8. 화면 정체성

전체 비주얼:

> **Retro Pixel Arcade Machine × Cosmic Escalation**

16:9 전체가 플레이필드가 아니다.

```text
[ STAGE WORLD ] | [ CENTRAL PLAY FIELD ] | [ STAGE WORLD ]
```

중앙:

- 공
- 머지
- 패들
- Cashout

좌우:

- Stage 세계
- 기계 프레임
- 계기판
- 규모 상승 연출

---

## 9. 보상 연출

일반 머지:

- Vampire Survivors처럼 빠르고 빈번한 포화형 FX

고등급 이벤트:

- 현재 플레이 화면 freeze
- 전체 dim
- Pixel Machine CUT-IN
- 약 0.45~0.70초
- 이름 / 공 이미지 / 가치 또는 효과

Stage 최고 공:

- 일반 CUT-IN과 중복하지 않고 Stage Clear / Scale Shift를 우선

Cashout:

- Score popup
- Time Bonus popup
- 고등급일수록 강한 연출

Final Settlement:

- 화면의 공들이 점수판/중앙으로 빨려 들어가는 빠른 정산 연출
- Time Bonus는 발생하지 않음

---

## 10. 플레이어 판타지

초반:

> 몇 픽셀짜리 눈송이를 조심스럽게 튕김

중반:

> 높은 공을 한 단계 더 욕심낼지 지금 팔아 시간을 벌지 고민

후반:

> 기본 공 자체가 행성/블랙홀급으로 쏟아지고 기계가 우주 현상을 감당하지 못함

최종 인상:

> 처음에는 눈송이 실험이었는데 왜 우주가 망하고 있지?

---

## 11. 디자인 기둥

1. **Active Merge** — 플레이어가 궤도를 만든다
2. **Greed vs Cashout** — 보유와 현금화 사이의 선택
3. **Explosive Value** — 머지 점수는 비정상적으로 상승
4. **Time Economy** — 좋은 Cashout은 새 기회를 산다
5. **Scale Rebaselining** — 이전 최고가 다음 기본이 된다
6. **Readable Chaos** — 후반이 미쳐도 실제 공과 패들은 읽힌다
7. **Fast Premium Moments** — 중요 연출은 강하지만 짧다

---

## 12. MVP 핵심

반드시 남긴다.

- A/D 이동
- 방향키 각도
- 같은 단계 머지
- 폭증 점수
- Cashout
- 공별 Time Bonus
- Stage별 타이머
- 최고 공 즉시 Clear
- Time Up Final Settlement
- clear_score 기반 Score Clear
- Scale Shift
- 이전 최고 → 다음 기본
- Stage별 Spawn 증가
- 중앙 Play Field + 좌우 Stage World
- Retro Pixel Arcade Machine
- Web Export
- Result
