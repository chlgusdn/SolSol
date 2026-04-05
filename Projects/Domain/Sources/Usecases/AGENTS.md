<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Domain/Usecases

## 목적
비즈니스 로직 구현체. 각 유스케이스는 단일 비즈니스 작업을 캡슐화하고, 리포지토리 프로토콜을 의존성으로 받으며, 타입화된 `Result`를 반환합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `ExpenseChangeRateUsecase.swift` | 두 기간 간의 지출 변화율 계산 (`HomeViewModel`의 일일 변화 표시기에 사용) |
| `HomeExpenseSummaryChartUsecase.swift` | 거래를 카테고리별로 그룹화하고 홈 차트 데이터 엔트리 생성 |
| `HomeExpenseTotalAmountUsecase.swift` | 주어진 시간 범위의 총 지출 금액 계산 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 각 유스케이스는 테스트에서 모킹하기 쉽도록 매칭되는 프로토콜(`XxxUsecaseProtocol`) 포함
- 유스케이스는 구조체 — 변경 가능한 상태 없음, 주입된 의존성만 존재
- 시간 범위는 `TimeInterval` (밀리초)로 전달 — Core의 `Date.millisecond` 확장 사용
- `HomeExpenseSummaryChartUsecase`는 `category.categoryName`으로 그룹화하고 `graph{n}00` 색상 이름 할당

<!-- MANUAL: -->
