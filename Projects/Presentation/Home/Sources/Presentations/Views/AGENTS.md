<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Home/Views

## 목적
홈 기능을 위한 UIKit 뷰와 뷰 컨트롤러. 모든 VC는 `BaseViewController`를 상속합니다. 커스텀 뷰는 `Layoutable`을 구현하고 코드 기반 레이아웃에 FlexLayout/PinLayout을 사용합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `HomeViewController.swift` | 메인 홈 화면 VC — 요약 및 차트 서브뷰를 호스팅, `HomeViewModel`에 바인딩 |
| `HomeExpenseChartView.swift` | 카테고리별 지출 내역을 표시하는 차트 서브뷰 — `HomeExpenseChartViewModel`에 바인딩 |
| `HomeExpenseSummaryView.swift` | 총 지출 금액을 표시하는 요약 서브뷰 — `HomeExpenseSummaryViewModel`에 바인딩 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 뷰 내부 레이아웃에 `FlexLayout` 사용 (`view.flex.define { ... }`)
- `setupLayout()` / `viewDidLayoutSubviews()`에서 최종 프레임 계산에 `PinLayout` 사용
- Combine 바인딩은 `setupProperties()`에서 `viewModel.$property.sink { ... }.store(in: &bindings)`로 처리
- Auto Layout(`.translatesAutoresizingMaskIntoConstraints`) 절대 사용 금지 — FlexLayout + PinLayout만 사용

<!-- MANUAL: -->
