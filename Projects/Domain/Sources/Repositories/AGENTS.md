<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Domain/Repositories (프로토콜)

## 목적
리포지토리 레이어의 프로토콜 정의. Domain은 필요한 데이터를 정의하고, Data는 그것을 가져오는 방법을 구현합니다. 이 역전(Inversion)이 Domain을 특정 저장 기술로부터 독립적으로 유지합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `TransactionRepositroyProtocol.swift` | `getTransactions(startAt:endAt:)` 및 기타 거래 작업 정의 (오타 "Repositroy" 주의) |
| `BudgetRepositoryProtocol.swift` | 예산 데이터 접근 프로토콜 |
| `NotificationRepositoryProtocol.swift` | 알림 데이터 접근 프로토콜 |
| `UserRepositoryProtocol.swift` | 사용자 데이터 접근 프로토콜 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 프로토콜 이름: `XxxRepositoryProtocol` — `TransactionRepositroyProtocol`의 역사적 오타는 일관성을 위해 유지
- 모든 프로토콜 메서드는 `async` — 이 경계에서 Combine Publisher 없음
- 새 작업 추가 시: 여기 프로토콜에 추가하고 `Data/Sources/Repositories/`에서도 구현

<!-- MANUAL: -->
