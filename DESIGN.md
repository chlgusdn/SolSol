# DESIGN.md — 디자인 규칙

> View와 DesignSystem을 작성·수정할 때 따르는 규칙입니다. 코드 규칙은 [`RULE.md`](RULE.md), 진입점은 [`AGENTS.md`](AGENTS.md)를 보세요.
> 토큰 값의 기준은 코드와 에셋입니다. 값을 바꾸면 이 문서도 함께 갱신합니다.

## 1. 원칙
- **돈이 먼저 보인다** — 화면에서 가장 큰 요소는 금액이다. 장식보다 숫자의 가독성을 우선한다
- **수입은 초록, 지출은 빨강** — 색만으로 의미를 전달하지 않고 `+`/`-` 부호를 항상 함께 쓴다
- **시스템을 따른다** — iOS 기본 내비게이션, `Form`, `List`, 시스템 제스처를 그대로 쓰고 필요한 부분만 스타일링한다
- **토큰만 쓴다** — 색상·폰트·간격·라운드·모션에 매직 넘버를 쓰지 않는다

## 2. DesignSystem 구조

```
Projects/DesignSystem/
├── Resources/
│   ├── Colors.xcassets          # 색상 (라이트/다크)
│   └── Moneygraphy-*.ttf        # 폰트
└── Sources/
    ├── Foundation/Tokens/       # Font+SD, SDSpacing, SDRadius, Animation+SD
    ├── Styles/                  # SDButtonStyle, SDTextFieldStyle
    ├── Modifiers/               # .sdCard(), .sdScreen()
    └── Components/              # SDAmountText
```

- 모든 컴포넌트·스타일·모디파이어는 **`SD` 접두사** (SolSol Design)
- DesignSystem은 TCA와 Domain을 모른다 — 값(`Int`, `String`, 클로저)만 받는다
- 기본 컨트롤을 감싼 새 View보다 `ButtonStyle`, `TextFieldStyle`, `ViewModifier`를 우선한다
- 두 개 이상의 Feature에서 같은 UI가 나오면 DesignSystem 컴포넌트로 올린다

## 3. 색상
Tuist가 생성한 `DesignSystemAsset.<name>.swiftUIColor`로만 쓴다. `Color.red`, `Color(hex:)`, RGB 리터럴 금지.
새 색상은 `Resources/Colors.xcassets`에 라이트/다크 두 값을 가진 colorset으로 추가하고 `tuist generate`한다.

| 이름 | 용도 | Light | Dark |
|------|------|-------|------|
| `primary` | 주요 액션, 틴트, 링크 | `#3D7BF7` | `#5B93FF` |
| `onPrimary` | `primary` 배경 위 텍스트 | `#FFFFFF` | `#FFFFFF` |
| `income` | 수입 금액, 양수 잔액 | `#1FA971` | `#3CCB8D` |
| `expense` | 지출 금액, 음수 잔액, 오류 문구 | `#E5484D` | `#FF6369` |
| `background` | 화면 배경, 입력 필드 배경 | `#F4F5F7` | `#0F1115` |
| `surface` | 카드, 셀 배경 | `#FFFFFF` | `#1B1E24` |
| `textPrimary` | 본문, 제목 | `#16181D` | `#F2F3F5` |
| `textSecondary` | 보조 설명, 라벨, 섹션 헤더 | `#6B7280` | `#9CA3AF` |
| `separator` | 구분선 | `#E5E7EB` | `#2A2E36` |

- 투명도 변형은 토큰에 `.opacity(_:)`를 붙여 만든다 (예: 보조 버튼 배경 `primary.opacity(0.12)`)
- 텍스트와 배경의 명암비는 WCAG AA(본문 4.5:1) 이상을 유지한다

## 4. 타이포그래피
`Font.sd.*` 토큰만 쓴다. 폰트는 머니그라피 Rounded이고, `Font.custom(_:size:relativeTo:)`로 만들어 **Dynamic Type에 맞춰 크기가 조정**된다.

| 토큰 | 크기 | 기준 스타일 | 용도 |
|------|------|------------|------|
| `.sd.largeTitle` | 32 | `.largeTitle` | 월 잔액 등 핵심 금액 |
| `.sd.title` | 24 | `.title` | 금액 입력 필드 |
| `.sd.bodyBold` | 17 bold | `.body` | 강조 본문, 버튼, 월 표시 |
| `.sd.body` | 17 | `.body` | 기본 본문, 셀 제목 |
| `.sd.caption` | 13 | `.caption` | 라벨, 메모, 날짜 헤더, 오류 |

- 금액에는 항상 `.monospacedDigit()`을 적용해 자릿수가 바뀌어도 흔들리지 않게 한다
- 폰트 에셋(`DesignSystemFontFamily`)은 `Font+SD.swift`에서만 접근한다
- 내비게이션 타이틀, `Form` 라벨 등 시스템 컴포넌트는 시스템 폰트를 그대로 둔다

## 5. 간격 · 라운드

| `SDSpacing` | 값 | | `SDRadius` | 값 |
|-------------|----|-|-----------|----|
| `.xxs` | 2 | | `.s` | 8 |
| `.xs` | 4 | | `.m` | 12 |
| `.s` | 8 | | `.l` | 20 |
| `.m` | 12 | | `.pill` | 999 |
| `.l` | 16 | | | |
| `.xl` | 24 | | | |
| `.xxl` | 32 | | | |

- 4pt 그리드를 따른다. 화면 좌우 여백과 카드 안쪽 여백은 `.l`(16)
- 카드 `.l`(20), 버튼 `.m`(12), 입력 필드 `.s`(8) 라운드

## 6. 모션 · 햅틱

| 토큰 | 값 | 용도 |
|------|----|------|
| `Animation.sd.quick` | snappy 0.2s | 눌림, 토글 |
| `Animation.sd.standard` | smooth 0.3s | 금액·상태 변화 |
| `Animation.sd.bouncy` | bouncy 0.4s | 추가·완료 강조 |
| `SDScale.pressed` | 0.97 | 버튼 눌림 배율 |

- 숫자가 바뀌면 `.contentTransition(.numericText(value:))` + `.animation(.sd.standard, value:)`
- 햅틱은 `.sensoryFeedback(_:trigger:)` — 저장 성공 `.success`, 삭제 `.impact`, 오류 `.error`
- "동작 줄이기(Reduce Motion)"가 켜져 있으면 장식성 애니메이션을 생략한다

## 7. 컴포넌트 · 스타일

| 이름 | 사용법 | 설명 |
|------|--------|------|
| `SDAmountText` | `SDAmountText(12_000, style: .signed, font: .sd.body)` | 금액 표시. `.plain`(기본 색) / `.signed`(부호 + 수입·지출 색), 숫자 전환 애니메이션 포함 |
| `SDButtonStyle` | `.buttonStyle(.sdPrimary)` / `.sdSecondary` | 전체 너비 버튼, 비활성 시 투명도 0.4, 눌림 배율 |
| `SDTextFieldStyle` | `.textFieldStyle(.sd)` | `background` 배경의 둥근 입력 필드 |
| `.sdCard()` | 컨테이너에 적용 | `surface` 배경, `SDRadius.l`, 안쪽 여백 `.l` |
| `.sdScreen()` | 화면 루트에 적용 | `background` 전체 배경 (safe area 포함) |

- 금액은 반드시 `SDAmountText` 또는 `Int.wonFormatted` / `signedWonFormatted`(Core)로 표시한다. 직접 포맷 금지
- 모든 공개 컴포넌트는 `#Preview`를 제공하고 **라이트 / 다크 / 큰 Dynamic Type(`.xxxLarge`)** 을 확인한다

## 8. 화면 패턴
- **화면 루트**: `NavigationStack` 안에서 `.sdScreen()` 배경, `List`면 `.scrollContentBackground(.hidden)`
- **입력 화면**: 시스템 `Form` + `Section`. 새로 만들기는 sheet(취소/저장), 수정은 push(뒤로/저장, 하단 삭제)
- **저장 버튼**: 입력이 유효하지 않거나 저장 중이면 비활성화
- **빈 상태**: `ContentUnavailableView` — 무엇이 없는지 + 다음 행동을 안내한다 ("거래 내역이 없어요" / "+ 버튼으로 첫 거래를 기록해보세요")
- **오류**: 복구 가능한 오류는 `alert`, 목록 로딩 오류는 목록 위 `caption` + `expense` 색 문구
- **목록 그룹**: 날짜(일) 단위 섹션, 최신 날짜가 위

## 9. 접근성
- 아이콘만 있는 버튼에는 `.accessibilityLabel`을 단다 (예: "거래 추가", "이전 달")
- 터치 영역은 최소 44×44pt
- 색만으로 의미를 전달하지 않는다 — 금액에는 부호, 상태에는 텍스트를 함께 쓴다
- Dynamic Type 최대 크기에서 잘리거나 겹치지 않는지 프리뷰로 확인한다

## 10. 문구 (UX Writing)
- 한국어 해요체, 짧고 친근하게 ("저장하지 못했어요", "거래 내역이 없어요")
- 금액 표기: `12,000원`, 부호가 필요하면 `+12,000원` / `-12,000원`
- 날짜 표기는 `Date.FormatStyle`을 사용해 로케일을 따른다 (직접 문자열 조합 금지)
- 버튼은 동사형 짧은 단어: "저장", "취소", "삭제"
