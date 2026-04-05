<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Data/Entities

## 목적
데이터베이스 테이블에 직접 매핑되는 GRDB 레코드 타입. 각 엔티티는 `BaseEntitiy`를 준수합니다(GRDB의 `Record`/`PersistableRecord`/`FetchableRecord` 래핑).

## 주요 파일

| 파일 | 설명 |
|------|------|
| `BaseEntitiy.swift` | 모든 GRDB 엔티티의 기반 클래스/프로토콜 — 테이블 준수 요구사항 정의 |
| `TransactionEntity.swift` | 거래 테이블 매핑 |
| `BudgetEntity.swift` | 예산 테이블 매핑 |
| `CategoryEntitiy.swift` | 카테고리 테이블 매핑 (이름에 "Entitiy" 오타 — 참조 시 맞춰서 사용) |
| `NotificationEntity.swift` | 알림 테이블 매핑 |
| `UserEntity.swift` | 사용자 테이블 매핑 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `ValueEntities/` | 조인 쿼리 결과를 위한 복합 타입 — `TransactionWithCategoryEntitiy`, `NotificationWithBudgetEntitiy` |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 모든 엔티티는 반드시 `BaseEntitiy`를 준수해야 함
- 테이블 이름은 엔티티의 정적 `databaseTableName` 프로퍼티로 정의
- 새 엔티티 추가 시 `DataSources/Access/TableVersionMigrator.swift`에 마이그레이션도 함께 생성
- `ValueEntities/`의 값 엔티티는 읽기 전용 프로젝션 — 쓰기 작업에 사용 금지

<!-- MANUAL: -->
