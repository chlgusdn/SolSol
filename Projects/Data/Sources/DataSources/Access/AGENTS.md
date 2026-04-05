<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DataSources/Access

## 목적
저수준 데이터베이스 접근 레이어. `SQLAccessor`는 타입화된 async CRUD와 `ValueObservation` 메서드를 가진 GRDB `DatabasePool`을 감싸는 Swift `actor`입니다. 마이그레이션 인프라는 init 시 실행됩니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `SQLAccessable.swift` | 모든 데이터베이스 작업을 정의하는 프로토콜 (`save`, `fetchOne`, `fetchAll`, `updateOne`, `updateAll`, `deleteOne`, `deleteAll`, `observeAll`, `observeOne`) |
| `SQLAccessor.swift` | `SQLAccessable`을 구현하는 actor — `DatabasePool` 소유, Documents의 `SSDatabase.sqlite`에 DB 개방 |
| `TableMigrationApplier.swift` | `TableVersionMigrator`의 모든 마이그레이션을 `DatabaseMigrator`에 적용 |
| `TableVersionMigrator.swift` | 버전 관리 마이그레이션 정의 — `TableMigratorV1` 및 향후 버전 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `SQLAccessor`는 `actor` — 모든 메서드는 `async`, 별도 잠금 불필요
- DB 파일 경로: `Documents/SSDatabase.sqlite`
- 새 테이블 추가 시: `Entities/`에 엔티티 생성, `TableVersionMigrator`에 마이그레이션 추가 (새 버전), 기존 버전 수정 금지
- `observeAll`/`observeOne`은 `ValueObservation` 반환 — 반응형 업데이트를 위해 데이터 소스에서 구독
- `Tests/`의 `MockSQLAccessor`는 단위 테스트에서 `SQLAccessable`을 구현

<!-- MANUAL: -->
