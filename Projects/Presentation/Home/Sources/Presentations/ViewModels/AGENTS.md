<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Home/ViewModels

## 목적
홈 기능을 위한 Observable 뷰 모델. 각 ViewModel은 하나 이상의 유스케이스를 소유하고, 해당 뷰에서 사용하는 `@Published` 상태를 노출합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `HomeViewModel.swift` | 홈 화면 구동 — `ExpenseChangeRateUsecase`를 사용해 `ChangeRate` (.increase/.decrease/.none) 계산 |
| `HomeExpenseChartViewModel.swift` | 지출 카테고리 차트 구동 — `HomeExpenseSummaryChartUsecase` 사용 |
| `HomeExpenseSummaryViewModel.swift` | 총 지출 요약 구동 — `HomeExpenseTotalAmountUsecase` 사용 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 모든 VM은 `ObservableObject`, `@Published private(set)` 프로퍼티 사용
- 비동기 작업은 `init`에서 `Task { @MainActor [weak self] in ... }`로 디스패치
- `HomeViewModel.ChangeRate`는 열거형 — 뷰에서 세 가지 케이스 모두 처리
- VM은 `HomeDependencyProviding`에서 `HomeCoordinator`가 생성하고 주입

<!-- MANUAL: -->
