# Task 06 — Items

## 목적

현재 Stage의 3단계 이상 Snowball로 아이템 행성을 여러 번 깨뜨려 획득하는 짧은 폭발 구간과 뇌절 변형을 만든다.

---

## 공통 규칙

- 아이템은 작은 행성 형태의 `Item Ball`에 담겨 Play Field에 등장
- Item Ball은 일반 Snowball Merge 대상이 아님
- 현재 Stage의 3단계 이상 공만 파괴 damage를 줄 수 있음
- 데이터 기준으로 `local_level >= 2`; 그보다 높은 local level도 모두 유효
- 유효 Snowball 충돌마다 damage 1회와 공용 Rescue Beacon Capsule H0~H4 damage 단계 갱신
- 동일 contact가 여러 physics frame에 걸쳐도 분리 전에는 중복 damage 없음
- 유효 hit 5회에 Item Ball 파괴 lock을 한 번만 확정하고 승인된 Rescue Beacon Capsule rupture break를 한 번만 재생
- 파괴 시 아이템 종류별로 구분되는 Item Orb를 하나 생성하며 즉시 획득·발동하지 않음
- Item Orb의 visual/collision radius와 초기 speed는 현재 Stage의 3단계 공(`local_level = 2`)과 같고 초기 velocity는 수직 아래 방향
- Paddle이 Item Orb를 받으면 획득 lock과 CUT-IN을 요청하고 activation cue 뒤 효과 시작
- Item Orb를 놓쳐 열린 하단으로 떨어뜨리면 효과 없이 소멸
- CUT-IN 실패/skip 시에도 Paddle로 획득을 확정한 아이템은 안전하게 한 번 적용
- 1~2단계 공과 Paddle은 즉시 획득 또는 파괴하지 않음
- 지속 효과는 HUD 표시
- 같은 효과 재획득 시 지속시간 갱신
- 다른 효과 동시 유지 가능
- 파괴 연출 실패나 지연이 실제 아이템 적용을 중복시키지 않음

---

## 1. Blizzard

```text
duration: 5s
spawn multiplier: ×3
```

연출:

- 장식 눈 증가
- 생성음 가속
- 활성 중 남은 시간 상태창은 표시하지 않음

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
- Fire Snowball은 본체 외곽 전체를 불꽃이 감싸되 균일한 링으로 표시하지 않는다. 좌우·하단은 공 윤곽에 밀착하고, 상단은 깊은 골이나 긴 수직 쌍뿔 없이 5~7개의 짧고 넓은 불꽃 혀가 겹치는 연속된 flame mass로 표시한다. 전체 shell은 공 중심·반지름에 비례하며 본체 texture를 가리지 않는다. 투명 외곽에는 체크 무늬 분리 과정에서 생긴 불투명 near-white/near-neutral 픽셀이 없어야 하며, alpha 0 픽셀의 RGB도 `0,0,0`으로 정규화해 texture filtering halo를 방지한다. overlay는 Snowball batch보다 위에 렌더하고 하단 본체 원호가 shell 밖으로 돌출되지 않도록 Y 정렬한다. 불꽃 내부의 포화된 밝은 노랑 highlight는 유지한다.
- ×10은 Active Cashout 전용 modifier
- Final Settlement에는 적용하지 않음
- Time Bonus에는 적용하지 않음

Core consumer boundary:

- Paddle Fire window가 활성일 때 실제 Paddle collision을 commit한 공만 `FIRE` 상태가 된다.
- Fire 상태는 simulation slot에 저장되며, Fire 입력이 하나라도 있는 same-level Merge 결과는 Fire다.
- Active Cashout이 Fire 상태를 읽어 base `score_value ×10`을 emit한다. Stage/Run ledger는
  emit된 amount를 한 번씩만 반영한다.
- window 종료는 새 접촉만 Normal로 남기며, 기존 Fire 공의 상태를 지우지 않는다.
- Item activation/CUT-IN/Main signal wiring은 Core consumer 범위 밖의 Integration 작업이다.

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
- Core는 공당 최대 2개 이웃과 최대 8개 local candidate만 검사한다. 각 pair는 range 안에서 선형 falloff를 사용하며, 합산 acceleration과 기존 runtime speed cap을 모두 넘기지 않는다.

완료 조건:

- 연쇄 합체 증가가 체감
- N² 계산 없음
- 공이 한 점에 영구 정체되지 않음

---

## 아이템 행성 스폰

Item Ball은 Stage마다 임의의 시점에 한 번만 등장한다. 정확한 등장 시간 범위는 플레이테스트 tuning 값으로 두며, 한 번 등장한 뒤 파괴하거나 Item Orb 획득에 실패해도 같은 Stage에서 다시 생성하지 않는다.

파괴에는 유효 hit 5회가 필요하다. 파괴 가능 여부는 고정 global level이 아니라 현재 Stage 기준 `local_level >= 2`로 계산한다. 낮은 단계 공과 Item Ball의 정확한 반사·통과 반응 및 Item Ball 자체의 등장 궤적은 구현 전 별도 tuning으로 남긴다.

---

## 디버그

키로 각 아이템 강제 활성화 가능.  
릴리스에서는 제거 또는 개발 플래그로 숨김.


---

## 아이템 CUT-IN

Paddle이 Item Orb를 획득하면 아이템 종류를 보여주는 짧은 CUT-IN을 재생하고 activation cue 뒤 효과를 적용한다. Item Ball이 깨진 순간에는 CUT-IN이나 효과를 시작하지 않는다.

예:

```text
FIRE ORB
[ fire orb portrait ]
CASHOUT ×10
```

일반 공 고등급 CUT-IN과 동일한 cooldown/priority 시스템을 사용한다.
