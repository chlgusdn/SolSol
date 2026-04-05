<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Data/Sources

## 목적
`Data` 정적 프레임워크의 모든 소스 코드. SQL 접근, 엔티티 정의, 데이터 소스, 매퍼, 리포지토리 구현을 포함하는 전체 데이터 영속성 스택을 구현합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Errors.swift` | 데이터 레이어 에러 타입 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `DataSources/Access/` | `SQLAccessor` actor + 마이그레이션 인프라 (`DataSources/Access/AGENTS.md` 참고) |
| `DataSources/Local/` | `SQLAccessor`를 감싸는 도메인별 로컬 데이터 소스 |
| `Entities/` | GRDB `Record` 서브클래스 — 데이터베이스 테이블당 하나 |
| `Entities/ValueEntities/` | 조인 쿼리를 위한 복합 엔티티 타입 |
| `Mappers/` | `Mappable` 프로토콜을 통한 엔티티 ↔ 도메인 모델 변환 |
| `Repositories/` | `RepositoryProtocol` 구현체 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 전체 데이터 흐름: `RepositoryImpl` → `LocalDataSource` → `SQLAccessor` → GRDB `DatabasePool`
- 스키마 마이그레이션: `TableVersionMigrator`에 추가, 기존 마이그레이션은 절대 수정 금지
- 엔티티 이름: 테이블 레코드는 `XxxEntity`, 조인 결과 타입은 `XxxWithYyyEntity`
- 매퍼 이름: `XxxMapper`, 정적 메서드 `toDomain()`과 `toEntity()` 포함

<!-- MANUAL: -->
