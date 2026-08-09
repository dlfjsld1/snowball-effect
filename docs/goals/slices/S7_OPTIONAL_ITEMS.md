# S7 — Optional Items

원문: [`../../current/tasks/06_items.md`](../../current/tasks/06_items.md)

## 결과

아이템을 켜거나 제거해도 Core 상태 흐름과 Settlement 계약이 바뀌지 않는다.

## Goals

### S7-G1 Item gateway 통합

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `scripts/core/item_effect_gateway.gd`
- Integration Point: Content item effect를 Core의 제한된 cashout modifier/simulation command API에 연결.
- Dependencies: S5 완료; Core와 Content가 modifier/effect contract 제시.
- Verification: item 전체 off에서 Core 회귀 결과 동일; Core 문서와 Settlement에 item 이름이 없음.
- Do Not Modify: Core 계산 내부와 개별 item 구현.

### S7-G2 Blizzard

- Owner: Content/Systems
- Owned Files: `scripts/gameplay/item_blizzard.gd`, `resources/items/**`, `tests/content/**`
- Integration Point: S7-G1 gateway의 제한된 spawn/movement command 사용.
- Dependencies: S7-G1 API.
- Verification: 정의된 범위/시간에만 효과, 종료 후 완전 복구, Core 파일 직접 변경 없음.
- Do Not Modify: Ball simulation 내부와 StageManager.

### S7-G3 Fire Core

- Owner: Content/Systems
- Owned Files: `scripts/gameplay/item_fire_core.gd`, `resources/items/**`, `tests/content/**`
- Integration Point: S7-G1의 Active Cashout score modifier만 사용.
- Dependencies: S7-G1 API와 S3 Settlement 회귀 테스트.
- Verification: Active Cashout ×10, Time Bonus 변화 없음, Settlement base score 유지.
- Do Not Modify: Settlement service, score ledger, StageManager.

### S7-G4 Magnet

- Owner: Content/Systems
- Owned Files: `scripts/gameplay/item_magnet.gd`, `resources/items/**`, `tests/content/**`
- Integration Point: S7-G1 gateway의 제한된 force command 사용.
- Dependencies: S7-G1과 S4 performance metric API.
- Verification: 범위/세기 제한, 종료 복구, 1,000공 budget 회귀 없음.
- Do Not Modify: simulation loop와 Spatial Grid.

## Exit Gate

Q-S7와 Integration Gate. S7 자체는 release 필수가 아니다.
