# DESIGN.md — 디자인 규칙

> View와 DesignSystem을 작성·수정할 때 따르는 규칙입니다. 코드 규칙은 [`RULE.md`](RULE.md), 진입점은 [`AGENTS.md`](AGENTS.md)를 보세요.
>
> **기준 원본**: 이 문서 + 「쏠쏠 UI/UX 기획서 v1.0」(2026.08.04). 프로토타입·디자인 시스템 번들과 값이 다르면 **이 문서가 우선**합니다.
> 이 문서의 토큰은 DesignSystem 코드와 1:1로 대응합니다. 값을 바꾸면 코드와 이 문서를 함께 바꿉니다.

## 1. 원칙
- **숫자가 주인공** — 금액·날짜 숫자는 Moneygraphy-Pixel로 크게. 장식보다 숫자의 가독성이 먼저다
- **그레이스케일 + 포인트 컬러** — 평상시 UI는 무채색 바탕에 텍스트·아이콘·작은 태그에만 색을 쓴다. 헤더·넓은 면을 브랜드 컬러로 채우지 않는다
- **빨강은 아껴 쓴다** — 지출은 톤다운 레드(`expense`), 고채도 레드(`danger`)는 텅장방지 **위험 단계에만** 쓴다
- **수입 그린 / 지출 레드 + 부호** — 색만으로 의미를 전달하지 않고 `+` / `-`를 함께 쓴다
- **토큰만 쓴다** — 색상·폰트·간격·라운드·그림자·모션에 매직 넘버를 쓰지 않는다
- **라이트 모드만** — 다크 토큰이 확정될 때까지 앱은 라이트로 고정한다 (`UIUserInterfaceStyle = Light`)

## 2. DesignSystem 구조

```
Projects/DesignSystem/
├── Resources/
│   ├── Colors.xcassets              # 색상 에셋
│   ├── Moneygraphy-Pixel.otf        # 디스플레이 폰트
│   └── Moneygraphy-Rounded.ttf      # 본문 폰트
└── Sources/
    ├── Foundation/
    │   ├── Tokens/                  # Font+SD, SDSpacing, SDRadius, SDShadow, SDOpacity, SDSize, Animation+SD(SDDuration, SDScale)
    │   └── SDIcon.swift             # 아이콘 → SF Symbol 매핑
    ├── Styles/                      # SDButtonStyle
    ├── Modifiers/                   # sdScreen, sdCard, sdToast, sdSheet(Style), sdShake  (sdShadow는 Tokens/SDShadow)
    └── Components/                  # SDAmountText, SDTopBar, SDCategoryChip, SDTransactionRow, SDEmptyState, SDCategoryColor, SDPageIndicator, SDProgressRing, SDCalendar
```

- 모든 컴포넌트·스타일·모디파이어는 **`SD` 접두사**
- DesignSystem은 TCA·Domain을 모른다 — 값(`Int`, `String`, `Color`, 클로저)만 받는다
- 기본 컨트롤을 감싼 새 View보다 `ButtonStyle`, `ViewModifier`를 우선한다
- 두 개 이상의 Feature에서 같은 UI가 나오면 DesignSystem 컴포넌트로 올린다
- 모든 공개 컴포넌트는 `#Preview`를 제공하고 큰 Dynamic Type(`.xxxLarge`)을 확인한다

## 3. 색상
Tuist가 생성한 `DesignSystemAsset.<name>.swiftUIColor`로만 쓴다. `Color.red`, `Color(hex:)`, RGB 리터럴 금지.
새 색상은 `Resources/Colors.xcassets`에 colorset으로 추가하고 `tuist generate`한다.

### 브랜드 · 의미
| 이름 | 값 | 용도 |
|------|----|------|
| `primary` | `#13AD5C` | BI 그린 — 오늘 날짜, 선택 상태, 링크, 텍스트 버튼 |
| `cta` | `#14AE5C` 71% | CTA 버튼 배경 |
| `income` | `#13AD5C` | 수입 금액·아이콘 |
| `expense` | `#E5484D` | 지출 금액·포인트 (톤다운). **넓은 면 채우기 금지** |
| `danger` | `#DC1010` | 텅장방지 **위험 단계 전용** |
| `warning` | `#EBA326` | 텅장방지 경고 단계 |

### 표면 · 텍스트
| 이름 | 값 | 용도 |
|------|----|------|
| `background` | `#F9F9F9` | 화면 배경 |
| `surface` | `#FFFFFF` | 카드, 시트, 셀 |
| `surfaceDark` | `#1C1C1E` | 입력·통계 헤더 (무채색 원칙) |
| `textPrimary` | `#000000` | 본문, 제목 |
| `textSecondary` | `#4A5660` | 보조 설명, 라벨 |
| `textTertiary` | `#B5BEC6` | 플레이스홀더, 비활성, 아이콘 보조 |
| `border` | `#F4F4F4` | 카드·칩 테두리, 구분선 |
| `onPrimary` | `#FFFFFF` | `cta` · `surfaceDark` 위 텍스트 |

### 차트 · 캘린더
| 이름 | 값 | 용도 |
|------|----|------|
| `chartIncome` | `#8979FF` | 차트 수입 (글로우 포함) |
| `chartExpense` | `#FF928A` | 차트 지출 (글로우 포함) |
| `calendarSunday` | `#FF8A80` | 캘린더 일요일 |
| `calendarSaturday` | `#82B1FF` | 캘린더 토요일 |

### 카테고리 팔레트 (`SDCategoryColor`)
사용자가 카테고리를 만들 때 고르는 6색. DB에는 **키 문자열**(`red`, `amber` …)로 저장하고 `SDCategoryColor(rawValue:)`로 색을 얻는다.

| 키 | 값 | | 키 | 값 |
|----|----|-|----|----|
| `red` | `#E5484D` | | `blue` | `#435798` |
| `amber` | `#EBA326` | | `purple` | `#8979FF` |
| `green` | `#67A554` | | `brand` | `#13AD5C` |

- 연한 배경(선택된 칩, 아이콘 원형 배경)은 색 토큰에 `SDOpacity.tint`(10%)를 곱해 만든다

## 4. 타이포그래피
두 가지 머니그라피 폰트만 쓴다. 시스템 폰트·Inter 금지. 모든 토큰은 `Font.custom(_:size:relativeTo:)`로 만들어 **Dynamic Type을 따른다**.
머니그라피는 굵기가 하나뿐이다 — `.bold()` / `.weight()`로 강조하지 말고 크기·색으로 강조한다.

### 디스플레이 — Moneygraphy-Pixel (금액, 제목, 날짜 숫자)
| 토큰 | 크기 | 기준 | 용도 |
|------|------|------|------|
| `.sd.displayHero` | 44 | `.largeTitle` | 입력 금액, 다이얼 D-day |
| `.sd.displayTitle` | 36 | `.largeTitle` | 화면 큰 제목("통계"), 요약 총액 |
| `.sd.displayHeadline` | 26 | `.title` | 인사이트 문구, 월 표시("2025년 1월") |
| `.sd.displayBody` | 18 | `.headline` | 카드·리스트 금액, 상단 바 제목, 빈 상태 제목 |
| `.sd.displayCaption` | 14 | `.subheadline` | 캘린더 날짜·일별 금액 |

### 본문 — Moneygraphy-Rounded
| 토큰 | 크기 | 기준 | 용도 |
|------|------|------|------|
| `.sd.title` | 20 | `.title3` | 섹션 제목, 시트 제목 |
| `.sd.headline` | 18 | `.headline` | CTA 버튼, 강조 행 |
| `.sd.body` | 16 | `.body` | 기본 본문, 입력 필드, 행 제목 |
| `.sd.callout` | 14 | `.callout` | 보조 본문, 칩 |
| `.sd.footnote` | 12 | `.footnote` | 라벨, 날짜 헤더 |
| `.sd.caption` | 11 | `.caption` | 최소 크기 — 이보다 작게 쓰지 않는다 |

- 금액에는 항상 `.monospacedDigit()`을 붙인다
- 폰트 에셋(`DesignSystemFontFamily`)은 `Font+SD.swift`에서만 접근한다

## 5. 간격 · 라운드 · 그림자 · 크기

### `SDSpacing` (4pt 그리드)
| `.xxs` | `.xs` | `.s` | `.m` | `.l` | `.xl` | `.xxl` | `.xxxl` | `.huge` |
|---|---|---|---|---|---|---|---|---|
| 2 | 4 | 8 | 12 | 16 | 20 | 24 | 32 | 48 |

- 화면 좌우 여백 `SDSpacing.page` = 24, 카드 사이 간격 `SDSpacing.cardGap` = 8

### `SDRadius`
| 토큰 | 값 | 용도 |
|------|----|------|
| `.xs` | 4 | 칩, 태그, 차트 막대 |
| `.s` | 8 | CTA 버튼, 리스트 행, 입력 필드 |
| `.m` | 12 | 일반 카드, 토스트 |
| `.l` | 16 | 메인 카드 (요약, 캘린더) |
| `.sheet` | 24 | 바텀시트 상단 |
| `.drawer` | 28 | 통계 화이트 시트 상단 |
| `.pill` | 999 | 원형, 알약형 |

### `SDShadow`
| 토큰 | 값 | 용도 |
|------|----|------|
| `.card` | y 2, blur 12, 검정 5% | 일반 카드 |
| `.floating` | x 2, y 16, blur 19, 검정 9% | 캘린더 카드, 떠 있는 요소 |
| `.glow(color)` | y 9, blur 18, 색 40% | 차트 선·막대 글로우 |

### `SDSize` · `SDOpacity`
| 토큰 | 값 | | 토큰 | 값 |
|------|----|-|------|----|
| `SDSize.ctaHeight` | 54 | | `SDOpacity.disabled` | 0.45 |
| `SDSize.touchTarget` | 44 | | `SDOpacity.dim` | 0.4 (시트 딤) |
| `SDSize.iconS / M / L` | 16 / 20 / 24 | | `SDOpacity.toast` | 0.85 |
| `SDSize.iconXL / XXL` | 40 / 48 | | `SDOpacity.tint` | 0.10 (연한 배경) |
| `SDSize.borderThin / Thick` | 1 / 1.5 | | | |
| `SDSize.toastBottomOffset` | 150 | | | |

- 터치 영역은 최소 44×44 (캘린더 셀은 열 너비 기준 예외). 뒤로가기는 16pt 아이콘 + 44 영역
- 아이콘 크기는 `.font(.system(size: SDSize.iconX))`로 정한다 (SF Symbol 크기 지정용 — 텍스트에는 시스템 폰트 금지)

## 6. 모션 · 햅틱

| 토큰 | 값 | 용도 |
|------|----|------|
| `Animation.sd.quick` | snappy 0.2s | 눌림, 선택 |
| `Animation.sd.standard` | easeOut 0.25s | 시트·토스트 등장(fadeUp), 금액 변화 |
| `Animation.sd.shake` | 0.5s | 금액 상한 초과 흔들림 (`.sdShake(trigger:)`) |
| `SDDuration.toast` | 2.2s | 토스트 자동 소멸 |
| `SDDuration.saveToNavigate` | 0.65s | 저장 토스트 후 화면 이동 지연 |

- 숫자가 바뀌면 `.contentTransition(.numericText(value:))`
- 햅틱은 `.sensoryFeedback(_:trigger:)`로만 한다. 기획서의 UIKit 용어는 아래처럼 옮긴다

| 기획서 | SwiftUI | 사용처 |
|--------|---------|--------|
| `selectionChanged` | `.selection` | 날짜 선택, 탭 전환, 슬라이드, 차트 마커 인덱스 변경 |
| `impactOccurred(.light)` | `.impact(weight: .light)` | 키패드, 월 이동, 모듈 카드 |
| `impactOccurred(.medium)` | `.impact(weight: .medium)` | 온보딩 시작 CTA |
| `notificationOccurred(.success)` | `.success` | 저장 완료 |
| `notificationOccurred(.warning)` | `.warning` | 텅장방지 경고 단계 진입 (1회) |
| `notificationOccurred(.error)` | `.error` | 금액 초과, 위험 단계 진입 (1회) |

- 연속 입력(차트 드래그)은 **값이 바뀔 때만** 햅틱을 낸다

## 7. 아이콘 (`SDIcon`)
디자인의 Lucide 스타일 아이콘은 SF Symbol로 대응한다. 직접 `Image(systemName:)`을 쓰지 말고 `SDIcon`을 쓴다 (`SDIcon.plus.image`).

| 디자인 | SDIcon | SF Symbol |
|--------|--------|-----------|
| ArrowLeft (뒤로) | `.back` | `chevron.left` |
| ChevronRight | `.chevronRight` | `chevron.right` |
| Plus | `.plus` | `plus` |
| Close | `.close` | `xmark` |
| CheckBold | `.check` | `checkmark` |
| Calendar | `.calendar` | `calendar` |
| BarChart | `.barChart` | `chart.bar` |
| TrendingUp | `.trendingUp` | `chart.line.uptrend.xyaxis` |
| PieChart | `.pieChart` | `chart.pie` |
| Settings | `.settings` | `gearshape` |
| Tag | `.tag` | `tag` |
| Clock | `.clock` | `clock` |
| DollarSign | `.money` | `wonsign` |
| Info | `.info` | `info.circle` |
| AlertTriangle | `.alert` | `exclamationmark.triangle` |
| Pocket (텅장방지) | `.budget` | `shield.lefthalf.filled` |
| RefreshCw (고정 지출) | `.repeat` | `arrow.clockwise` |
| Receipt (고정 지출 카드) | `.receipt` | `list.bullet.rectangle` |
| 카테고리: 식비 / 카페 / 교통 / 쇼핑 / 레저 | `.food` / `.cafe` / `.transport` / `.shopping` / `.leisure` | `fork.knife` / `cup.and.saucer` / `bus` / `bag` / `figure.walk` |

- 카테고리 아이콘은 Domain `TransactionCategory.iconKey`에 **case 이름**으로 저장하고 `SDIcon(key:)`로 찾는다 (모르는 키는 `.tag`)

## 8. 컴포넌트

| 이름 | 사용법 | 규격 |
|------|--------|------|
| `SDButtonStyle` | `.buttonStyle(.sdPrimary)` / `.sdPrimaryCompact` / `.sdSecondary` / `.sdText` | primary: `cta` 배경 + `onPrimary` 글자, 전체 너비, 높이 54, `SDRadius.s`, `.sd.headline`. compact: 내용 너비, 높이 44. secondary: `surface` + `border` 테두리. text: 배경 없음, `primary` 글자. 비활성 `SDOpacity.disabled` |
| `SDAmountText` | `SDAmountText(12_000, style: .signed, font: .sd.displayBody)` | `.plain` / `.signed`(부호 + 수입·지출 색) / `.income` / `.expense`. Pixel 폰트, 숫자 전환 애니메이션 |
| `SDTopBar` | `SDTopBar(title:, style: .light/.dark, onBack:, trailing:)` | 뒤로가기 44 영역 + 가운데 제목 + 우측 액션. `.dark`는 `surfaceDark` 배경 |
| `SDCategoryChip` | `SDCategoryChip("식비", color: .red, isSelected:)` | 색 점 + 라벨, `SDRadius.pill`, 선택 시 색 테두리 + tint 배경 |
| `SDTransactionRow` | `SDTransactionRow(title:, subtitle:, amount:, color:, icon:)` | 좌측 색 원형 아이콘 + 제목/부제 + 우측 금액 |
| `SDEmptyState` | `SDEmptyState(icon:, title:, message:, actionTitle:, action:)` | 원형 tint 아이콘 + Pixel 제목 + 안내 + 선택적 버튼 |
| `SDPageIndicator` | `SDPageIndicator(count: 4, current: $page)` | 현재 페이지는 `primary` 막대(너비 24), 나머지는 `textTertiary` 점(8). 표시 전용(탭 없음 — 점마다 44 영역 불가). VoiceOver는 조절 요소로 이동 |
| `SDProgressRing` | `SDProgressRing(progress: 0.7, color:) { 가운데 내용 }` | 12시 방향부터 시계 방향으로 채움. 트랙은 색의 `SDOpacity.tint`, 선 두께 기본 `SDSpacing.m`, 둥근 끝 |
| `SDCalendar` | `SDCalendar(month:, today:, selection:, amount: { SDCalendar.Amount(text:, accessibilityText:) }, onSelect:)` | 일요일 시작 7열. 오늘은 `primary` 원, 선택일은 `primary` 링, 날짜 아래 `textSecondary` 금액(`compactFormatted` — "1.2만"). 칸 높이 44, 폭은 열 너비 |
| `.sdCard(_:radius:padding:)` | `.sdCard()` / `.sdCard(.floating, radius: SDRadius.l)` | `surface` 배경, 기본 여백 `SDSpacing.l`, 기본 그림자 `.card` |
| `.sdScreen()` | 화면 루트 | `background` 전체 배경 |
| `.sdToast(_:)` | `.sdToast($message)` | 하단 150pt 위 중앙, 검정 85%, `SDRadius.m`, `.sd.callout`, 2.2초 후 자동 닫힘 |
| `.sdSheet(isPresented:)` / `.sdSheetStyle()` | `.sdSheet(isPresented: $on) { … }` · TCA: `.sheet(item: $store.scope(…)) { SheetView(store:).sdSheetStyle() }` | 시스템 sheet + 상단 `SDRadius.sheet` + 드래그 핸들 + 내용 높이 detent |
| `.sdShake(trigger:)` | `.sdShake(trigger: count)` | 좌우 흔들림 0.5s |

- 금액은 반드시 `SDAmountText` 또는 `Int.wonFormatted` / `signedWonFormatted`(Core)로 표시한다
- 키패드, 차트, 영수증 카드는 해당 Feature를 만들 때 DesignSystem에 추가한다. 예산 다이얼은 `SDProgressRing`을 쓴다

## 9. 화면 패턴 (기획서 요약)
- **온보딩**: 첫 실행에만 표시. 4장 가로 스와이프(`TabView` page 스타일) + `SDPageIndicator` + 하단 CTA("다음" → 마지막 장 "이제부터 시작!") + 우상단 `.sdText` "건너뛰기"(마지막 장에서 숨김). 완료·건너뛰기 시 `SettingsClient.completeOnboarding()`. 앱 시작 시 완료 여부를 확인하는 동안은 빈 배경만 보여 홈이 깜빡이지 않게 한다
- **홈**: 월 이동(← 2025년 1월 →) → 선택일 지출 카드("오늘 지출" / "1월 15일 지출" + 이번달 총 지출) → `SDCalendar` → "지출 추가" → 바로가기 카드 3개(0원의 기적·통계·고정 지출) → 인사이트 배너(지난달 대비 지출 증감) → 선택일 거래 + "전체보기". 월 이동은 이번 달까지만 가능하다(이번 달에서는 → 숨김). 월을 옮기면 오늘이 있는 달은 오늘, 아니면 1일을 선택한다. 내비게이션 바는 숨기고, 월 이동은 스크롤 밖에 고정해 카드가 상태 표시줄 영역을 넘지 않게 한다
- **지출 리스트**: 상단 제목 "2025년 1월"(홈에서 보던 달) → 요약 카드(총 지출, 예산 사용률 바 + "예산 X원의 N%", 수입) → 날짜별 그룹(헤더 "2025.01.15 (수)" + 그날 지출) → 하단 고정 "내역 추가". 예산 사용률은 **예산 기간(시작일~만기일) 지출** 기준. 예산이 없으면 "아직 예산을 설정하지 않았어요" + "설정하기". 행을 누르면 수정, 왼쪽으로 밀면 삭제(확인 알림)
- **내비게이션**: 탭바 없음. 홈이 허브이고 모든 하위 화면은 push, 좌상단 뒤로가기로 복귀
- **입력 화면**: `surfaceDark` 헤더(← / 수익·지출 토글 / ✓ 저장) + Pixel 금액 + 카테고리 칩 + 제목·메모 + 고정 지출 체크 + 3×4 키패드. 토글은 포인트 색만 바꾸고 헤더 배경은 그대로
- **저장 흐름**: 저장 → 토스트("지출을 저장했어요") → 0.65초 후 지출 리스트로 이동
- **CTA**: 화면 하단, 좌우 `SDSpacing.page`. 홈 "지출 추가"는 넓은 레드 채우기 대신 `.sdSecondary` + `expense` 색 아이콘
- **바텀시트**: `.sdSheet` — 딤 배경 탭으로 닫기
- **빈 상태**: `SDEmptyState` — 무엇이 없는지 + 다음 행동. 홈("이 날은 기록된 내역이 없어요"), 리스트("아직 거래 내역이 없어요"), 통계("아직 보여드릴 통계가 없어요"), 텅장방지("아직 예산이 없어요")
- **텅장방지 단계**: 안전 < 70% (`primary`) · 경고 70–90% (`warning`) · 위험 ≥ 90% (`danger`). 다이얼·배너·사용률 바 색을 함께 바꾼다
- **예산 사용률 바**: 80% 초과 시 `expense`로 전환 (지출 리스트)

## 10. 접근성
- 아이콘만 있는 버튼에는 `.accessibilityLabel`을 단다 ("뒤로", "저장", "거래 추가")
- 터치 영역 최소 44×44
- 색만으로 의미를 전달하지 않는다 — 금액에는 부호, 상태에는 텍스트
- 가장 작은 글자는 `.sd.caption`(11). Dynamic Type 최대 크기에서 잘리거나 겹치지 않는지 확인한다

## 11. 문구 (UX Writing)
- 모든 문구는 **"~요"체**. 짧고 친근하게, 정보 중심
- 이모지는 **인사이트 문구 끝에 1개만** ("1월에 가장 많이 지출했어요 😞")
- 토스트는 "~했어요"체 ("지출을 저장했어요")
- 금액: `10,000원` (콤마, 단위 붙여쓰기), 부호가 필요하면 `+10,000원` / `-10,000원`
- 퍼센트: `+10%` / `-90%` (부호 포함)
- 날짜: `2025.01.15 (수)`, 기간: `2025.01.01 ~ 2026.01.01` — `Date.FormatStyle` 기반 포맷터로 만든다 (직접 문자열 조합 금지)
- 앱 고유 용어: **텅장방지**, **0원의 기적**, **무소비 데이**, **고정 지출**

## 12. 미해결 과제 (기획서 7장)
| 항목 | 상태 |
|------|------|
| 거래 수정·삭제 UX | **결정** — 행 탭 = 수정, 왼쪽 스와이프 = 삭제(확인 알림) |
| 고정 지출 자동 등록 시점 (자정 / 앱 실행 시) | 미정 |
| 다크모드 토큰 | 미확정 — 확정 전까지 라이트 고정 |
| 예산 알림(로컬 푸시) 발송 조건 | 미정 |
| "0원의 기적" 카드 이름과 연결 화면(텅장방지) | 용어 정리 필요 |
