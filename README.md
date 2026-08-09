# Snowball Effect

**Snowball Effect**는 떨어지는 공을 패들로 튕겨 같은 단계끼리 합치고, 눈송이에서 행성·은하·블랙홀까지 규모를 키우는 2D 액션 머지 게임입니다.

> 현재 상태: S0 Bootstrap과 S1 Shared Skeleton 완료. Desktop/Main과 최신 Chrome Web 수동 플레이 검증을 마쳤으며, 다음 개발 단계는 S2 Merge입니다.

## 게임 목표

- 화면 위에서 현재 Stage의 기본 공이 계속 생성됩니다.
- 패들의 위치와 각도를 조절해 공의 다음 궤도를 만듭니다.
- 같은 단계의 공 두 개를 합쳐 더 높은 단계의 공을 만드는 것이 목표입니다.
- 패들 아래로 떨어진 공은 실패가 아니라 점수가 됩니다.
- Stage 최고 공을 만들면 성공이 잠기고, 최종 정산 뒤 `SCALE SHIFT`가 발생합니다.
- Ground → Planetary → Galactic → Black Hole로 규모가 커집니다.

Merge, Scale Shift, 전체 Stage progression은 게임의 목표이며 아직 구현되지 않았습니다.

## 현재 플레이 가능한 Shared Skeleton

- Lv1 Snowball 생성과 `gravity = 0` 기반 이동
- 좌·우·상단 벽 반사와 열린 하단 Active Cashout
- Mouse/Keyboard Paddle 이동과 자유회전
- 양면 Paddle collision 및 이동·회전에 따른 타격 변화
- Stage / Run 기본 Score HUD
- Pause / Retry
- Desktop 실행과 Web Export

## 조작

| 입력 | 기능 |
|---|---|
| Mouse X | Paddle 좌우 직접 이동 |
| Mouse Wheel | Paddle 자유회전 |
| `A` / `D` | Paddle 좌우 이동 Keyboard fallback |
| `←` / `→` | Paddle 회전 Keyboard fallback |
| `Esc` | Pause / Resume |
| `R` | Retry |

이동과 회전은 동시에 사용할 수 있습니다. Paddle은 양방향으로 제한 없이 계속 회전하며, Mouse/Keyboard 위치 조작은 마지막으로 실제 사용한 입력 source를 따릅니다.

## 기술 정보

- Godot `4.7.1 stable`, GDScript
- 현재 프로젝트 설정: Compatibility renderer
- 1600×900 logical viewport
- Desktop browser Web Export
- 중앙 배열 기반 대량 Ball simulation
- 향후 spatial grid 기반 Merge 후보 탐색
- logical ball 약 1,000개에서 최소 30 FPS 목표

## 다음 단계

`Next: S2 — Ball/Score data → Merge system`

## 라이선스

라이선스는 아직 정해지지 않았습니다.
