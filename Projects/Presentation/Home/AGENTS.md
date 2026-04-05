<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Presentation/Home (HomePresentation)

## 목적
홈/대시보드 기능 모듈. 지출 요약, 카테고리 차트, 일일 지출 변화율을 표시합니다. 코디네이터, 뷰 모델, 뷰를 포함하는 전체 기능 스택을 포함합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Project.swift` | Tuist 프로젝트 정의 — Core, DesignSystem, Domain 의존 |
| `Sources/HomeDependencyProviding.swift` | App이 이 기능에 제공해야 하는 모든 팩토리를 나열하는 프로토콜 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Sources/Coordinators/` | `HomeCoordinator` (홈 플로우 루트)와 `ExpenseCoordinator` (지출 추가/수정 서브 플로우) |
| `Sources/Presentations/ViewModels/` | `HomeViewModel`, `HomeExpenseChartViewModel`, `HomeExpenseSummaryViewModel` |
| `Sources/Presentations/Views/` | `HomeViewController`, `HomeExpenseChartView`, `HomeExpenseSummaryView` |
| `Tests/` | 홈 기능 단위 테스트 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 모듈 이름은 `HomePresentation` — 항상 `import HomePresentation`으로 사용
- `HomeDependencyProviding`은 App과 이 기능 간의 경계 계약 — 새 VM 팩토리 필요 시 여기에 추가
- VC에서 `viewModel.$property.sink { ... }.store(in: &bindings)`로 ViewModel 바인딩
- `HomeViewModel.ChangeRate` 열거형이 지출 변화율 표시기의 UI 상태를 결정

### 테스트 방법
- `HomePresentationTests` 스킴으로 실행

### 공통 패턴
- `HomeCoordinator`는 `dependencies: HomeDependencyProviding`을 받아 VM을 해결
- `ExpenseCoordinator`는 지출 입력 플로우를 위해 `HomeCoordinator`에서 push

## 의존성

### 내부
- `SolSolCore` — `Coordinator` 프로토콜
- `DesignSystem` — `BaseViewController`, SD 컴포넌트
- `Domain` — 유스케이스 프로토콜 및 도메인 모델

<!-- MANUAL: -->
