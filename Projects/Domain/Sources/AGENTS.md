<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Domain/Sources

## 목적
`Domain` 프레임워크의 모든 소스 코드. 순수 Swift — UIKit, GRDB, 영속성 없음. 도메인 모델, 유스케이스 구현, 리포지토리 프로토콜 정의, async/Combine 브릿지 유틸리티를 포함합니다.

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Common/` | 공유 도메인 타입 — `UsecaseError` 열거형 |
| `Entities/` | 순수 Swift 도메인 모델 구조체 |
| `Extensions/` | `Combine+Async.swift` — Combine Publisher와 async/await 간 브릿지 |
| `Repositories/` | 각 도메인 애그리게이트(Budget, Notification, Transaction, User)의 프로토콜 정의 |
| `Usecases/` | 비즈니스 로직 — 각 유스케이스 구조체는 독립적으로 테스트 가능 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 유스케이스 이름: `XxxUsecase`, 매칭되는 `XxxUsecaseProtocol` 포함
- 유스케이스 `execute(...)`는 `async -> Result<T, UsecaseError>` 반환
- 리포지토리 프로토콜 이름: `XxxRepositoryProtocol` (단, `TransactionRepositroyProtocol`에 오타 있음 — 맞춰서 사용)
- 도메인 모델: `XxxModel` — 필요에 따라 `Codable`/`Equatable` 준수
- `HomeChartSummaryResponseModel`은 프레젠테이션 레이어에 반환되는 차트 엔트리 데이터를 그룹화

<!-- MANUAL: -->
