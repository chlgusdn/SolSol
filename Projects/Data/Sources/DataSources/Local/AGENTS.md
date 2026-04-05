<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DataSources/Local

## 목적
도메인별 로컬 데이터 소스 리포지토리. 각 클래스는 특정 도메인 애그리게이트를 위한 `SQLAccessor` 호출을 감싸고 엔티티 타입을 반환합니다. 도메인 엔티티당 하나의 클래스.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `LocalDataSourceRepository.swift` | 로컬 데이터 소스의 기반 프로토콜/클래스 |
| `TransactionDataSourceRepositoryImpl.swift` | `SQLAccessor`를 통한 거래 CRUD |
| `BudgetDataSourceRepositoryImpl.swift` | `SQLAccessor`를 통한 예산 CRUD |
| `NotificationDataSourceRepositroyImpl.swift` | `SQLAccessor`를 통한 알림 CRUD |
| `UserLocalDataSourceRepositoryImpl.swift` | `SQLAccessor`를 통한 사용자 데이터 CRUD |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 데이터 소스는 엔티티 타입(`XxxEntity`)을 다룸, 도메인 모델 아님 — 매핑은 리포지토리에서 수행
- 이름 규칙: `XxxDataSourceRepositoryImpl` (단, `Notification` 파일에 "Repositroy" 오타 있음 — 참조 시 맞춰서 사용)
- 각 데이터 소스는 생성자 주입을 통해 `SQLAccessor`를 받음

<!-- MANUAL: -->
