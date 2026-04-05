<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DI/Assemblies

## 목적
기능/레이어별 어셈블리 파일. 각 파일은 해당 모듈의 팩토리를 Factory `Container`에 등록하고 타입화된 팩토리 프로퍼티로 `Container`를 확장합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `DataAssembly.swift` | Data 레이어 리포지토리(`SQLAccessor`, `RepositoryImpl`들) 등록 |
| `DomainAssembly.swift` | Domain 유스케이스 등록 |
| `HomeAssembly.swift` | 홈 기능 뷰 모델(`HomeViewModel`, `HomeExpenseChartViewModel`, `HomeExpenseSummaryViewModel`) 등록 |
| `TransactionAssembly.swift` | 거래 기능 의존성 등록 (스텁) |
| `UsecaseAssembly.swift` | 기능 간 공유 유스케이스 등록 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 각 어셈블리는 앱 시작 시 `DependencyBootstrapper`가 한 번 호출하는 정적 `register()` 메서드를 가짐
- 등록과 함께 항상 타입화된 `Factory<T>` 프로퍼티로 `Container` 확장을 추가
- 미등록 팩토리는 `fatalError` — `register()` 호출 누락은 런타임 크래시
- 등록 순서가 중요 — Data를 Domain 전에, Domain을 Presentation 전에 등록해야 함

<!-- MANUAL: -->
