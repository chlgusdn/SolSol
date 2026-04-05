<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Data/Repositories

## 목적
Domain에서 정의한 리포지토리 프로토콜의 구체적 구현체. 각 구현체는 로컬 데이터 소스와 매퍼를 조합하여 프로토콜 계약을 이행합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `TransactionRepositroyImpl.swift` | `TransactionRepositroyProtocol` 구현 (오타 "Repositroy" — 맞춰서 사용) |
| `BudgetRepositoryImpl.swift` | `BudgetRepositoryProtocol` 구현 |
| `NotificationRepositoryImpl.swift` | `NotificationRepositoryProtocol` 구현 |
| `UserRepositoryImpl.swift` | `UserRepositoryProtocol` 구현 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 각 `RepositoryImpl`은 init 주입을 통해 데이터 소스와 매퍼를 받음
- `App/Sources/DI/Assemblies/DataAssembly.swift`에 등록
- 리포지토리는 도메인 모델 수준 작업과 엔티티 수준 데이터 소스 호출 사이를 변환

<!-- MANUAL: -->
