# Requirements Traceability

| 계약 | 소유 Goal | 주요 검증 |
|---|---|---|
| 중앙 배열과 슬롯 재사용 | S1-G1, S4-G2 | 활성/비활성 수, 재사용 index |
| 같은 global level만 Merge | S2-G2/G3 | 동일/상이 레벨 충돌 |
| 점수 데이터 폭증·formatter | S2-G1/G4 | 고레벨 값 표시 |
| Stage local Time Bonus | S3-G1/G2 | 같은 global ball의 Stage별 보너스 |
| Cashout이 같은 tick Time Up 구조 | S3-G3 | Q-S3 시나리오 1 |
| local Lv4 비종료·Time Up 중재 | S3-G7 | Q-S3 시나리오 2 |
| Settlement snapshot/idempotence | S3-G4 | Q-S3 시나리오 3/5 |
| stage/run score source-of-truth | S3-G2/G4 | Q-S3 시나리오 4 |
| Scale Shift는 Settlement 뒤 | S5-G2 | 상태/신호 순서 로그 |
| Scale Shift는 사용자 `Next Stage` 확인 뒤 | S5-G6/S5-G6I | Q-S3 시나리오 6과 stale/duplicate 요청 |
| Stage Score gauge | S3-G8 | reset/overflow/Galactic `clear_score<=0` HUD 검증 |
| Galactic 투명 배경 합성 | S5-G7 | Native/Web L2/L3 screenshot과 alpha 검사 |
| 고등급 최초 생성 CUT-IN 6종 | S6-G2 | Stage별 local Lv3/Lv4 1회·재생 순서 검증 |
| Spatial Grid, no O(N²) | S4-G1/G3 | 후보 수·FPS 기록 |
| Core/Optional item 분리 | S7-G1 | 아이템 on/off 비교 |
| 마지막 Stage Result | S8-G2/G4 | Clear→Result, Retry |
| Public Web 제출 | S9-G2/G3 | 브라우저/URL Evidence |
