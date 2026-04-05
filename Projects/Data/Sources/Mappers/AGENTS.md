<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Data/Mappers

## 목적
데이터베이스 엔티티와 도메인 모델 간의 양방향 변환. Data와 Domain 레이어의 결합도를 낮게 유지합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Mappable.swift` | `toDomain()` 및/또는 `toEntity()` 매핑 인터페이스를 정의하는 프로토콜 |
| `TransactionMapper.swift` | `TransactionEntity` ↔ `TransactionModel` |
| `BudgetMapper.swift` | `BudgetEntity` ↔ `BudgetModel` |
| `NotificationMapper.swift` | `NotificationEntity` ↔ `NotificationModel` |
| `UserMapper.swift` | `UserEntity` ↔ `UserModel` |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 매퍼는 상태 없음 — 정적 메서드가 있는 열거형으로 구현하거나 `Mappable` 준수
- `toDomain()`: 엔티티 → 도메인 모델 변환 (DB에서 읽을 때 사용)
- `toEntity()`: 도메인 모델 → 엔티티 변환 (DB에 쓸 때 사용)

<!-- MANUAL: -->
