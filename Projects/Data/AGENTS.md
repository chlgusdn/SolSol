<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Data

## 목적
Domain에서 정의한 리포지토리 프로토콜을 구현하는 데이터 레이어. GRDB(SQLite)를 통한 모든 로컬 영속성을 처리하며, 스키마 마이그레이션을 포함합니다. 매퍼를 사용해 데이터베이스 엔티티와 도메인 모델 간 변환을 수행합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Project.swift` | Tuist 프로젝트 정의 — Domain, Core, GRDB 의존 |
| `Sources/Errors.swift` | 데이터 레이어 에러 타입 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Sources/DataSources/Access/` | `SQLAccessor` actor — 저수준 GRDB DatabasePool 작업 (`Sources/DataSources/Access/AGENTS.md` 참고) |
| `Sources/DataSources/Local/` | `SQLAccessor`를 감싸는 도메인별 데이터 소스 리포지토리 |
| `Sources/Entities/` | 데이터베이스 테이블에 매핑되는 GRDB 레코드 타입 |
| `Sources/Mappers/` | 엔티티 ↔ 도메인 모델 변환 |
| `Sources/Repositories/` | Domain 유스케이스에 주입되는 `RepositoryProtocol` 구현체 |
| `Tests/` | `MockSQLAccessor`를 사용한 단위 테스트 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- Data 모듈은 Domain 프로토콜을 구현 — Presentation을 절대 import하지 말 것
- `SQLAccessor`는 Swift `actor` — 모든 DB 작업은 async
- 스키마 변경 시 `TableVersionMigrator`에 새 마이그레이션 추가 (버전 관리), 기존 버전은 절대 수정 금지
- 엔티티 타입은 반드시 `BaseEntitiy`를 준수해야 함 (GRDB의 `Record` 래핑)
- 매퍼 패턴: `Mappable` 프로토콜을 통해 `Entity → DomainModel` 변환

### 테스트 방법
- 실제 데이터베이스 I/O를 피하기 위해 `MockSQLAccessor` (`Tests/` 내) 사용
- `DataTests` 스킴으로 실행

### 공통 패턴
```swift
// 리포지토리 구현 패턴:
final class TransactionRepositoryImpl: TransactionRepositoryProtocol {
    private let dataSource: TransactionDataSourceRepositoryImpl
    func getTransactions(...) async -> [TransactionModel] {
        let entities = await dataSource.fetch(...)
        return entities.map(TransactionMapper.toDomain)
    }
}
```

## 의존성

### 내부
- `SolSolCore` — 로깅

### 외부
- `GRDB` — SQLite 데이터베이스 접근

<!-- MANUAL: -->
