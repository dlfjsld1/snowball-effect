# Snowball Effect — Screen Composition

## 1. 핵심 계약

**16:9 전체 화면을 플레이 영역으로 사용하지 않는다.**

실제 게임 플레이는 화면 중앙의 세로로 긴 `Play Field` 안에서만 일어난다.

```text
┌──────────────────────────────────────────────────────┐
│          │                              │            │
│ STAGE    │      CENTRAL PLAY FIELD      │   STAGE    │
│ WORLD    │                              │   WORLD    │
│          │  balls / merges / paddle     │            │
│          │                              │            │
└──────────────────────────────────────────────────────┘
```

좌우 공간은 단순 빈 여백이 아니라 **현재 Stage 세계와 아케이드 기계 본체**다.

전체 화면은 짙은 남청·청록·회청·검은 보라와 낡은 금속색을 기본으로 한 어두운 픽셀 기계 내부처럼 보인다. 중앙 Play Field는 주변보다 한 단계 더 눌린 톤으로 두고, Snowball·점수·경고·핵심 충돌만 제한적인 밝은 회백, 노랑, 주황~빨강, 청록 CRT 발광으로 읽힌다.

---

## 2. Play Field 역할

중앙에서만 발생:

- 기본 공 스폰
- 공 이동
- 벽 반사
- 머지
- 아이템 낙하
- 패들
- 바닥 점수 회수
- 블랙홀의 게임플레이 영향에 필요한 논리 좌표

Play Field 경계를 넘어 실제 공이 Stage World 영역을 돌아다니게 하지 않는다.

---

## 3. Stage World 역할

좌우/후방:

- 현재 세계 규모 전달
- 아케이드 기계 프레임
- 계기판
- 장치
- 단계별 환경 변화
- 장식 파티클
- 블랙홀 시각
- Cut-in이 지나갈 전체 화면 배경

Stage World는 게임 규칙을 가리는 장식이 아니라 Scale Shift를 읽게 만드는 핵심 구성이다.

---

## 4. 레이어 구조

권장 개념:

```text
Background Stage World
        ↓
Arcade Machine / Frame
        ↓
Central Play Field background
        ↓
Gameplay Balls / Paddle / Items
        ↓
Gameplay Effects
        ↓
HUD
        ↓
Global Dimmer
        ↓
CUT-IN / Scale Shift Presentation
```

CUT-IN 때는 현재 장면 전체가 freeze되고,
`Global Dimmer`가 중앙 Play Field와 좌우 Stage World를 **같이** 어둡게 한다.

---

## 5. 초기 구현값

기준 해상도:

```text
1600 × 900
```

중앙 Play Field의 정확한 폭은 아트와 플레이테스트로 결정한다.

초기 프로토타입에서는 대략 화면 폭의 40~50%를 중앙 Play Field로 사용해도 된다.
이 값은 **밸런스 확정값이 아니라 레이아웃 테스트용 값**이다.

중요한 것은:

- 좌우 Stage World가 충분히 보일 것
- 패들 조작 공간이 지나치게 답답하지 않을 것
- 낙하 공이 서로 합쳐질 공간이 확보될 것

이다.

---

## 6. 프레임

Play Field 주변은 두꺼운 픽셀 기계 프레임을 둔다.

후보 요소:

- 볼트
- 패널 이음새
- 작은 경고등
- 7-segment/CRT 계기판
- 단계 표시
- 최고 공 표시
- 점수 미터
- 과부하 표시등

모든 정보를 채우지 않는다.
장식 계기판과 실제 HUD를 구분한다.

프레임과 HUD는 깨끗한 flat panel이나 둥근 모바일 카드가 아니라 old terminal / CRT / arcade machine의 일부처럼 보인다. 작은 픽셀 테두리, 제한된 청록 계기 발광, 7-segment 또는 거친 레트로 숫자를 사용하되 HUD의 실제 정보 가독성을 희생하지 않는다.

---

## 7. HUD 위치

HUD는 중앙 Play Field를 최소한으로 침범한다.

추천:

좌상/우상 Stage World:

- SCORE
- TIME
- PAUSE

프레임 또는 외곽:

- 현재 활성 아이템
- 현재 Stage 공 족보
- 작은 장식 계기

HUD의 기본 정보 계약은 점수, 시간, 현재 아이템, 일시정지, 공 족보다. Stage 이름, 최고 공, Clear Target 같은 추가 정보가 필요하면 이 항목들의 가독성을 해치지 않는 보조 표시로만 검토한다.

공 족보는 현재 Stage의 local 공 5~6종을 작은 픽셀 아이콘으로 낮은 단계부터 높은 단계까지 한 줄 또는 한 열로 배열한다. 인접한 아이콘의 순서만으로 `같은 공 2개 → 다음 공` 관계가 읽혀야 하며, 예시 이미지처럼 별도의 `NEXT` Spawn 예고 영역은 두지 않는다. Play Field를 가리지 않도록 Stage World 또는 기계 프레임 공간에 배치한다.

중앙 위:

- 특별 발표 텍스트만 잠깐 사용

점수 팝업은 실제 공 위치 근처에서 발생하되 별도 UI/프레젠테이션 레이어에서 처리한다.

---

## 8. 가독성

실제 공:

- 명확한 외곽선
- 장식 눈보다 높은 대비
- Stage가 바뀌어도 배경에 묻히지 않음

Stage World:

- 멋있어도 중앙보다 시각적 우선순위가 낮음
- 강한 움직임은 중요 이벤트 때만
- 밝은 파스텔 배경이나 넓은 soft bloom으로 중앙 공의 대비를 빼앗지 않음

프레임:

- 게임의 개성을 주되 Play Field 내부를 침범하지 않음

---

## 9. Web Resize

16:9 기준으로 설계한다.

브라우저에서는:

- 전체 게임 화면 비율 유지
- 중앙 Play Field 비율 보존
- 좌우 Stage World가 잘려 게임 인상이 사라지지 않도록 함
- 작은 창에서도 입력 가능한 최소 크기 확인

단순히 중앙 Play Field만 확대해 좌우 디자인을 잘라내는 대응은 피한다.
