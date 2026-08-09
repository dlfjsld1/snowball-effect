# Task 06 — Items

## 목적

패들이 직접 먹는 아이템으로 짧은 폭발 구간과 뇌절 변형을 만든다.

---

## 공통 규칙

- 아이템은 상단에서 낙하
- 공과 충돌하지 않음
- 패들과 충돌하면 획득
- 놓치면 제거
- 지속 효과는 HUD 표시
- 같은 효과 재획득 시 지속시간 갱신
- 다른 효과 동시 유지 가능

---

## 1. Blizzard

```text
duration: 5s
spawn multiplier: ×3
```

연출:

- `BLIZZARD!`
- 장식 눈 증가
- 생성음 가속

완료 조건:

- 정확히 지속시간 동안 생성량 증가
- 종료 후 원래 Stage 생성량 복원
- 중첩 곱셈 버그 없음

---

## 2. Fire Core

```text
duration: 8s
cashout multiplier: ×10
```

- 패들이 불꽃 상태
- 닿은 공이 Fire 특성
- Fire + Normal 같은 레벨 합체 가능
- 결과는 Fire
- Fire + Fire도 Fire
- 눈+불 파티클
- ×10은 Active Cashout 전용 modifier
- Final Settlement에는 적용하지 않음
- Time Bonus에는 적용하지 않음

완료 조건:

- 특수 타입 렌더
- 점수 배수
- 합체 전파
- 지속시간 종료 후 새로 맞는 공은 Normal 유지
- 기존 Fire 공은 Fire 유지

---

## 3. Magnet

```text
duration: 7s
```

- 같은 레벨 인접 공끼리 약한 흡인
- Spatial Grid 후보 사용
- 최대 힘 제한
- 패들 조작을 무시할 정도로 강하지 않음

완료 조건:

- 연쇄 합체 증가가 체감
- N² 계산 없음
- 공이 한 점에 영구 정체되지 않음

---

## 아이템 스폰

초기:

```text
첫 아이템: 게임 시작 15~25초
이후: 12~20초 랜덤
```

Stage가 오르면 약간 자주 나올 수 있다.

---

## 디버그

키로 각 아이템 강제 활성화 가능.  
릴리스에서는 제거 또는 개발 플래그로 숨김.


---

## 아이템 CUT-IN

강한 아이템/특수 속성의 첫 적용에는 짧은 CUT-IN을 사용할 수 있다.

예:

```text
FIRE SNOWBALL
[ burning pixel snowball ]
CASHOUT ×10
```

모든 아이템 획득마다 강제로 띄우지 않는다.
일반 공 고등급 CUT-IN과 동일한 cooldown/priority 시스템을 사용한다.
