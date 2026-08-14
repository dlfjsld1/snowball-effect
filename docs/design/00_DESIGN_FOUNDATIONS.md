# 00. Design Foundations

Status: APPROVED VISUAL FOUNDATION — runtime and remaining asset decisions stay Goal-gated  
Owner: Presentation  
Purpose: 모든 Presentation + UI 산출물이 공유할 시각 언어를 정의한다.

## 1. North Star

> 좁고 어두운 90년대 아케이드 캐비닛 안에서 시작한 작은 공이, Stage를 끝낼 때마다 기계와 플레이 공간을 밀어내며 우주적 규모로 확장한다.

화면은 어둡지만 침침해서는 안 된다. Background와 machine은 gameplay hierarchy를 받치는 저채도 레이어이고, Ball·Paddle·결정적인 feedback은 즉시 구별되는 고대비 레이어다.

## 2. Invariants and Variables

### 반드시 유지

- 90년대 픽셀 아케이드의 실루엣, 계기판, 제한된 팔레트, 짧고 명확한 모션.
- 어두운 배경과 대비되는 Ball·Paddle·Cashout·중요 UI.
- 1px/2px 단위로 읽히는 선 굵기 계층과 nearest 계열 texture filtering.
- gameplay object와 decorative particle의 명확한 분리.
- 정보보다 먼저 게임 공간과 위험·성공 상태가 읽히는 계층.

### 범위 안에서 자유롭게 재설계

- 기존 meadow/planet/galaxy 장면의 구체적 일러스트.
- Frozen Enamel 재질 계층 안의 버튼, 배선, 안테나, 패널 패턴.
- Stage별 장식 캐릭터와 배경 서사.
- 최종 폰트와 개별 Ball 팔레트.

## 3. Layer Hierarchy

| 우선순위 | 레이어 | 밝기·채도 원칙 | 예시 |
|---:|---|---|---|
| 0 | Void | 가장 어둡고 정적 | 전체 바탕, letterbox |
| 1 | Stage World | 저대비·저채도 | 별, 기계 내부, 원경 |
| 2 | Cabinet / Frame | 중간 대비 | 경계, 패널, HUD housing |
| 3 | Play Field guides | 낮은 대비지만 기능적 | 상·좌·우 반사 경계, Cashout cue |
| 4 | Gameplay objects | 항상 높은 대비 | Ball, Paddle, item |
| 5 | Critical feedback | 순간적으로 최고 대비 | Clear, high-tier Merge, failure |
| 6 | Persistent UI | gameplay보다 낮거나 같은 대비 | time, score, target 후보 슬롯 |

장식은 4~5 레이어의 실루엣을 침범하지 않는다. 대량 공 상황에서는 Stage World와 일반 particle의 밝기를 추가로 낮춘다.

## 4. Approved V4 Palette Seeds

V4 제작에 사용할 의미 기반 시작값이다. 최종 runtime export 전 contrast와 Web color를 검증할 수 있지만 역할과 재질 계층은 유지한다.

| Token | Seed | 용도 |
|---|---|---|
| `void_950` | `#050709` | 전체 우주 배경 |
| `enamel_deep` | `#172225` | 캐비닛 그림자, 깊은 housing |
| `enamel` | `#223033` | 도장 강판 기본면 |
| `enamel_light` | `#344345` | 융기·활성 panel |
| `bare_steel` | `#8F9992` | 노출 금속, 기능 edge |
| `steel_dark` | `#4C5755` | 금속 그림자 |
| `oxide_trace` | `#456F69` | 제한된 산화·마모 흔적 |
| `ice` | `#C9F3F5` | 성애, 냉기, title accent |
| `paper_050` | `#F4F5E8` | Paddle, 기본 텍스트, 최고 대비 |
| `signal_cyan` | `#48DDEC` | navigation, system-ready, result boundary |
| `merge_pink` | `#FF5B9F` | Merge 계열 |
| `score_amber` | `#FFC857` | score/cashout/attention |
| `hazard_red` | `#FF554D` | time pressure/failure |

Item Box rarity seed는 Common=`bare_steel/paper_050`, Rare=`signal_cyan`, Epic=`merge_pink`를 사용한다. 최종 palette는 Ball/Stage contrast board에서 조정하며 rarity는 색뿐 아니라 capsule core shape, border notch, crack pattern으로도 구분한다.

에나멜 도장이 캐비닛 면적의 대부분을 차지한다. 녹은 별도 primary token으로 만들지 않고 bolt·edge의 제한된 wear에만 사용한다. 성애·고드름·눈은 Main marquee와 외곽 frame에 집중하고 Play Field 내부에는 응결 흔적만 허용한다.

색만으로 상태를 전달하지 않는다. 텍스트, icon silhouette, outline pattern, motion 중 최소 하나를 함께 사용한다.

## 5. Pixel Language

세부 제작·LOD·AI 생성물 검수 기준의 단일 source of truth는 [12_PIXEL_DESIGN_GUIDELINES.md](12_PIXEL_DESIGN_GUIDELINES.md)다.

- 1600×900을 layout authoring 기준으로 삼는다.
- 캐릭터·Ball·Frame sprite는 같은 장면 안에서 texel density가 흔들리지 않게 제작한다.
- pixel asset은 nearest filtering을 사용하되 전체 Web viewport를 강제로 정수 배율에 맞추지는 않는다.
- 1px detail은 축소 해상도에서 사라질 수 있으므로 기능 경계는 기준 화면에서 최소 2px를 사용한다.
- glow·blur는 sprite의 모양을 대체하지 않고 외곽 보조로만 쓴다.
- 회전·확대가 필요한 pixel sprite는 단계형 frame animation이나 shader quantization을 검토한다.

Godot의 strict integer scaling은 pixel art를 선명하게 유지하는 데 유리하지만, 1600×900을 720p/1080p로 옮기면 분수 배율이 발생한다. 이 프로젝트는 고정 viewport 정수 배율보다 공의 실루엣과 UI 가독성을 우선한다. 참고: [Godot — Multiple resolutions](https://docs.godotengine.org/en/latest/tutorials/rendering/multiple_resolutions.html).

## 6. Typography

최종 폰트는 미확정이다. 선택 조건은 다음과 같다.

- Display: 90년대 arcade 인상을 주는 bitmap/pixel 계열 1종.
- Numeric: 시간·점수가 폭 변화에도 흔들리지 않는 tabular numeral 지원.
- Body/Help: 작은 크기에서도 Web 브라우저에서 읽히는 단순한 폰트.
- 1600×900 기준 gameplay 필수 텍스트는 **최소 16px**, 보조 정보와 상태 label은 **최소 14px**를 사용한다. HUD의 Time·Score·Stage 이름처럼 즉시 읽어야 하는 값은 18px 이상에서 시작한다.
- 14px 미만 텍스트는 읽을 정보가 아닌 장식용 기계 각인에만 허용하며, 제거해도 조작·상태·규칙 이해가 달라지지 않아야 한다.
- outline/shadow는 어두운 배경과 밝은 오브젝트 양쪽에서 읽히도록 제한적으로 사용한다.
- 런타임 한국어 지원 여부가 정해질 때 glyph coverage와 fallback font를 다시 확정한다.

## 7. Spacing and Shape

- 기본 spacing unit: 4px.
- 주요 panel inset: 16/24/32px 단계.
- Frame outline: 시각적 중요도에 따라 4/8/12px 단계로 시작.
- 모서리는 완전한 modern rounding보다 직각, chamfer, stepped corner를 우선한다.
- 카드형 floating panel의 남용을 피하고 machine panel에 정보가 새겨진 것처럼 구성한다.
- Pause는 중앙의 단일 machine panel을 사용하고 menu card를 여러 장 중첩하지 않는다.
- 1600×900 기준 좌우 bezel은 약 190px 고정 폭 시드로 제작하고 Stage Shift에서 폭 대신 위치를 바꾼다.
- Item Box는 일반 선물상자가 아니라 각진 궤도 화물 캡슐 silhouette을 사용한다.

## 8. Accessibility Baseline

- 일반 텍스트는 가능한 한 배경 대비 4.5:1, 큰 텍스트는 3:1 이상을 목표로 한다.
- Paddle, Ball, 선택 focus, 기능적 boundary 등 비텍스트 요소도 인접 색 대비 3:1을 목표로 한다.
- flashing은 필수 정보 전달 수단으로 사용하지 않는다. secondary flash/particle가 없는 정지 reference에서도 같은 상태가 읽혀야 한다.
- 화면 흔들림·hit-stop·glow 강도는 개별 effect tier에서 제한한다.

V4의 Merge/Item/Milestone에는 secondary motion을 줄이는 reduced recipe를 함께 만든다. 현재 scope에는 플레이어용 `Reduced Effects` 설정, 저장 UI, runtime toggle을 포함하지 않으며 향후 필요하면 별도 Goal과 Owner를 만든다.

참고: [Xbox Text Display](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/101), [Xbox Contrast](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/102), [WCAG Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast).

## 9. Foundation Deliverables

1. 채택된 V4 1600×900 north-star와 Main/Playing/Pause keyframe.
2. 초기 + 확장 1·2·3단계 비교 strip.
3. grayscale hierarchy board.
4. semantic color token board.
5. typography/number readability board.
6. full-density gameplay screenshot paint-over.

## 10. Intentional Exclusions

- 정확한 Stage balance 값.
- Core physics와 event 발생 조건.
- Audio composition과 최종 asset 구매/라이선스 결정.
- Runtime shader·scene·script 구현.
