# 12. Pixel Design Guidelines

Status: ADOPTED DESIGN STANDARD — runtime asset production remains Goal-gated
Owner: Presentation
Source reviewed: `C:\Users\gktjd\Downloads\PIXEL_DESIGN_GUIDELINES.md`
Purpose: 서로 다른 크기와 Stage의 에셋이 같은 픽셀 문법과 detail density를 유지하도록 제작·검수 기준을 정의한다.

## 1. Adoption Review

원본 지침의 핵심 방향은 Snowball Effect에 합당하다. 특히 다음 원칙을 그대로 채택한다.

- 픽셀 일관성은 모든 에셋의 해상도를 같게 만드는 것이 아니라 logical pixel과 detail density를 일관되게 유지하는 데서 나온다.
- 같은 Ball도 표시 크기가 크게 달라지면 단순 축소하지 않고 크기별 LOD를 별도로 제작한다.
- Ball·HUD icon·FX·Background는 같은 최소 픽셀 문법을 공유하되 기능과 우선순위에 맞는 밀도를 사용한다.
- AI pseudo-pixel-art는 production-ready 판정 없이 그대로 runtime asset으로 사용하지 않는다.

다음 표현은 기존 프로젝트 계약에 맞게 보정해 채택한다.

- `1600×900`은 **layout authoring 및 native review 기준**이지 모든 Web viewport의 고정 출력 크기가 아니다.
- source sprite, icon, 개별 UI 요소는 nearest filtering과 정수 좌표·정수 크기를 우선한다. 그러나 전체 Web viewport의 fractional fit까지 금지하지 않는다.
- `1 logical pixel`은 최소 장식 표현 단위다. 충돌 경계·focus·필수 HUD 구분선 등 기능 경계는 기준 화면에서 최소 2px을 사용한다.
- FX와 particle 수치는 production 시작값이다. event tier와 density budget 검증 없이 모든 효과에 절대 규칙으로 강제하지 않는다.
- 이 문서는 에셋 제작 계약이며 현재 runtime radius, physics, renderer 또는 Goal 상태를 변경하지 않는다.

## 2. Core Pixel Grammar

> 공의 크기는 우주까지 커져도, 그 세계를 그리는 픽셀의 시각적 문법은 바뀌지 않아야 한다.

- 기준 authoring canvas: `1600×900`.
- 최소 장식 표현 단위: `1 logical pixel`.
- 주요 그래픽 덩어리: `2×2px` 이상을 우선한다.
- UI 배치 간격: `4px` 배수.
- 기능적 UI 경계: 최소 `2px`.
- 주요 Frame 경계: `4px / 8px / 12px` 계층.
- icon master size: `16×16px / 24×24px / 32×32px`.
- 보조 글자: `14px` 이상.
- 일반 gameplay 글자: `16px` 이상.
- Time·Score·Stage 이름: `18px` 이상에서 시작한다.
- pixel texture import는 nearest filtering을 사용한다.
- source asset과 개별 UI 요소에 bilinear 축소, 비정수 transform, 임의 sharpen을 사용하지 않는다.
- Web viewport fit에서 fractional scale이 필요한 경우 전체 composition의 가독성을 우선하고 720p/768p/900p/1080p capture로 검증한다.

## 3. Ball Size and Stage-local LOD

현재 runtime visual/collision radius는 각 Stage의 ordered chain 안에서 local level로 다시 시작한다.

| Local level | Runtime radius | 기본 sprite 지름 |
|---:|---:|---:|
| 0 | 4 | `8×8px` |
| 1 | 8 | `16×16px` |
| 2 | 16 | `32×32px` |
| 3 | 32 | `64×64px` |
| 4 | 64 | `128×128px` |

기본 Stage chain은 Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`다. 따라서 같은 global Ball도 Stage Shift 뒤 다른 표시 LOD를 사용할 수 있다.

| 사례 | 사용 LOD |
|---|---:|
| Ground top Moon | `128×128px` hero LOD |
| Planetary base Moon | `8×8px` symbolic LOD |
| Planetary top Galaxy | `128×128px` hero LOD |
| Galactic base Galaxy | `8×8px` symbolic LOD |

### Ball drawing rules

- 작은 Ball outline은 `1px`, 중·대형 Ball outline은 `2px`에서 시작한다.
- 크기에 비례해 outline을 계속 굵게 만들지 않는다.
- highlight와 shadow의 기본 pixel block은 `1~2px`로 유지한다.
- 큰 Ball은 미세 질감을 늘리기보다 대표 motif의 수, 간격, 면적을 확장한다.
- glow 없이도 silhouette, 크기, palette, 대표 motif로 등급이 구분되어야 한다.
- hero LOD를 축소해 symbolic LOD로 사용하지 않는다. 각 master size에서 직접 다시 그린다.
- 서로 다른 LOD는 palette와 대표 motif를 공유하되 detail density는 표시 크기에 맞춘다.

## 4. FX and Particle Grammar

- 일반 particle: `1px / 2px / 3px`.
- 중요 effect의 핵심 파편: 기준 화면에서 약 `4px`까지를 시작값으로 사용한다.
- 높은 Tier는 particle 한 개를 계속 키우기보다 수량, burst 반경, cluster 수와 timing을 늘린다.
- Merge ring은 매끄러운 vector circle보다 계단형 pixel ring을 우선한다.
- Ball과 Paddle은 항상 일반 particle보다 선명하고 높은 대비를 유지한다.
- blur와 glow는 silhouette을 대체하지 않고 짧은 보조 layer로만 사용한다.
- 실제 cap, duration, aggregation은 `FxBudgetProfile`과 S6 검증에서 확정한다.

## 5. Background and Stage World

- 원경 별과 작은 장식: `1~2px`.
- 기계 panel detail: `2~4px`.
- Frame과 기능 경계: `4px` 이상 계층.
- Ground, Planetary, Galactic은 정보량과 motif가 달라도 최소 pixel block 크기를 바꾸지 않는다.
- 후반 Stage는 detail 개수와 밀도를 늘릴 수 있지만 더 미세한 photographic texture를 도입하지 않는다.
- Background는 Ball, Paddle, 필수 HUD보다 낮은 대비를 유지한다.
- 1280×720 축소 capture에서도 별과 장식이 gameplay object처럼 보이지 않아야 한다.

## 6. HUD, CRT, and Icon

- HUD도 World와 같은 logical pixel 기준을 공유한다.
- UI 내부에는 `2px` edge와 `4px` spacing 체계를 사용한다.
- gameplay Ball sprite를 HUD icon 크기로 단순 축소하지 않는다.
- `16px / 24px / 32px` icon LOD를 별도로 제작한다.
- bitmap/pixel font는 정수 font size와 정수 좌표를 사용한다.
- 개별 UI 요소에 fractional scale transform을 적용하지 않는다.
- CRT scanline과 반복 장식은 1px 두께를 유지한다. NinePatch의 반복 행을 세로로 stretch해 굵은 띠를 만들지 않는다.
- 9-slice/tile asset의 corner, edge, repeatable center를 handoff sheet에 기록한다.
- 기능 텍스트와 label은 bitmap에 bake하지 않고 Godot UI에서 출력한다.

## 7. AI-generated Image Policy

AI 생성 이미지는 concept reference, silhouette exploration, palette exploration, composition keyframe으로 사용할 수 있다. 다음 조건을 모두 통과하기 전에는 production pixel asset으로 간주하지 않는다.

### Allowed workflow

1. AI 결과에서 silhouette, palette, motif, composition 아이디어를 선택한다.
2. 목표 크기 `8 / 16 / 24 / 32 / 64 / 128px` grid에 맞춰 다시 그리거나 수작업으로 pixel-cleanup한다.
3. palette index, outline, highlight, shadow와 transparent edge를 직접 정리한다.
4. 필요한 모든 LOD를 각각 제작한다.
5. Godot nearest import와 실제 Web viewport에서 검증한다.

### Rejected workflow

- 1024px AI 이미지를 단순 축소해 production asset으로 사용.
- bilinear resize 뒤 sharpen만 적용.
- 일부 큰 에셋에만 photographic texture 또는 sub-pixel detail 사용.
- 같은 family가 서로 다른 pixel block 크기와 light direction 사용.
- antialiasing fringe, 반투명 matte, 불필요한 색상 증가를 검수 없이 허용.

AI source를 사용한 경우 handoff sheet에 생성 도구, 원본 위치, cleanup 담당자, 최종 palette와 검증 결과를 기록한다.

## 8. Before / After Review Pattern

Moon 또는 Galaxy처럼 Stage 사이에서 hero와 symbolic LOD를 모두 사용하는 Ball을 대표 비교 대상으로 삼는다.

### Before — reject

`128×128px` hero 이미지를 `8×8px`로 단순 축소해 crater, highlight와 outline이 뭉개지고 축소된 고해상도 이미지처럼 보인다.

### After — approve candidate

`128×128px` hero LOD와 `8×8px` symbolic LOD를 별도로 제작한다. 두 버전은 같은 palette와 대표 motif를 공유하지만 각 크기에 맞는 silhouette과 detail density를 가진다.

## 9. Production Validation

각 asset family는 다음을 확인한다.

- native-size sheet에서 family 전체의 logical pixel과 light direction이 일관된다.
- nearest 1×/2×/4× 확대에서 outline이 변형되지 않는다.
- 1280×720, 1366×768, 1600×900, 1920×1080 capture에서 기능 detail과 텍스트가 읽힌다.
- transparent edge에 dark/white matte bleed가 없다.
- palette에 승인되지 않은 중간색과 antialiasing color가 불필요하게 늘지 않는다.
- Ball hero/symbolic LOD가 label 없이도 같은 정체성으로 인식된다.
- Background와 particle이 Ball/Paddle/HUD보다 높은 대비를 차지하지 않는다.
- CRT, panel, Frame의 반복 영역이 늘어나도 line thickness와 motif 간격이 유지된다.

## 10. Intentional Exclusions

- 현재 runtime renderer 또는 import setting 변경.
- Ball physics, collision radius, Merge와 Stage 규칙 변경.
- 최종 Ball palette와 개별 motif 확정.
- S6 전 FX particle cap과 duration 확정.
- 새로운 runtime asset 생성 또는 기존 proxy 교체 승인.
