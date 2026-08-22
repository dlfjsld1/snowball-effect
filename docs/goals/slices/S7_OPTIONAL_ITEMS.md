# S7 — Optional Items

원문: [`../../current/tasks/06_items.md`](../../current/tasks/06_items.md)

## 결과

아이템을 켜거나 제거해도 Core 상태 흐름과 Settlement 계약이 바뀌지 않는다.

## Goals

### S7-G1C Item Ball·Orb producer contract

- Owner: Content/Systems
- Owned Files: `scripts/gameplay/item_manager.gd`, `scripts/gameplay/item_ball.gd`, `scripts/gameplay/item_orb.gd`, `resources/items/**`, `tests/content/**`
- Integration Point: `item_planet_damaged`, `item_planet_broken`, `item_orb_spawned`, `item_collected`, `item_orb_missed`, `active_items_changed`를 read-only producer로 제공한다. Orb 획득 뒤 효과 자체는 시작하지 않는다.
- Dependencies: S5 완료와 `docs/current/tasks/06_items.md`의 Item Ball/Orb 공통 규칙.
- Verification: Stage마다 Item Ball은 최대 한 번만 생성; 현재 Stage `local_level >= 2` 공의 분리된 유효 충돌 5회에만 damage/파괴를 한 번 확정; 파괴 뒤 Item Orb 하나가 낙하; Paddle 획득과 하단 이탈 신호가 상호 배타적으로 한 번씩만 발생; Item Ball 파괴만으로 CUT-IN·효과·Core state 변경이 없음.
- Do Not Modify: `GameManager`, `StageManager`, Simulation score/settlement 계산, 실제 Blizzard/Fire Core/Magnet 효과.

### S7-G1 Item gateway 통합

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `scripts/core/item_effect_gateway.gd`
- Integration Point: Content의 `item_collected(item_type, world_position)` 이후 CUT-IN activation cue를 Core의 제한된 cashout modifier/simulation command API에 연결. `item_planet_broken`은 effect activation을 요청하지 않는다.
- Dependencies: S7-G1C producer contract와 Core modifier/effect contract.
- Verification: Item Ball 파괴만으로 효과가 적용되지 않고 Paddle의 Item Orb 획득 뒤 CUT-IN을 거쳐 한 번 적용; Orb miss 시 미적용; item 전체 off에서 Core 회귀 결과 동일; Core 문서와 Settlement에 item 이름이 없음.
- Do Not Modify: Core 계산 내부와 개별 item 구현.

### S7-G2 Blizzard

- Owner: Content/Systems
- Owned Files: `scripts/gameplay/item_manager.gd` (Blizzard visual spawn signal만), `scripts/gameplay/item_blizzard.gd`, `scripts/presentation/item_blizzard_visual.gd`, `scenes/effects/item_blizzard_visual.tscn`, `assets/particles/items/blizzard/**`, `resources/items/**`, `tests/content/s7_g2_**`
- Integration Point: S7-G1 gateway의 제한된 spawn/movement command와 ItemManager의 read-only planet/orb 이벤트, `ItemBlizzard.active_state_changed(snapshot)`을 사용한다. Content/Systems/Release 담당이 Blizzard 전용 Item Ball·Orb styling, `BLIZZARD!` cue, 장식 눈을 직접 소유하며, Main mount/신호 연결은 Integration에 요청한다.
- Dependencies: S7-G1 API.
- Verification: 정의된 범위/시간에만 효과, 종료 후 완전 복구, Blizzard 전용 Item Ball·Orb styling·`BLIZZARD!` cue·장식 눈이 active state와 함께 시작/정리, Core 파일 직접 변경 없음.
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
