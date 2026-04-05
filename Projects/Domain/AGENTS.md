<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Domain

## 목적
비즈니스 로직 레이어 — 앱의 순수한 핵심. 유스케이스, 도메인 모델 타입, 리포지토리 프로토콜, Combine/async 유틸리티를 포함합니다. UIKit, Data 구현 세부사항, Swift 표준 라이브러리와 Combine 이외의 특정 프레임워크에 대한 지식이 없습니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Project.swift` | Tuist 프로젝트 정의 — Core에만 의존 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Sources/Common/` | 공유 도메인 타입 — `UsecaseError` |
| `Sources/Entities/` | 도메인 모델 타입 (순수 Swift 구조체) |
| `Sources/Extensions/` | Combine/async 브릿지 유틸리티 |
| `Sources/Repositories/` | 리포지토리 프로토콜 정의 (Data 레이어에서 구현) |
| `Sources/Usecases/` | 유스케이스 구현 — 비즈니스 규칙 |
| `Tests/` | 도메인 로직 단위 테스트 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- Domain은 Data, Presentation, UIKit, GRDB를 절대 import하면 안 됨
- 모든 리포지토리 상호작용은 `Sources/Repositories/`에 정의된 프로토콜을 통해
- 유스케이스는 async 함수로 `Result<T, UsecaseError>` 반환
- 도메인 모델은 순수 Swift 구조체 — GRDB/영속성 어노테이션 없음

### 테스트 방법
- 유스케이스는 모의 리포지토리 구현으로 단위 테스트하기 쉬움
- `DomainTests` 스킴으로 실행

### 공통 패턴
```swift
// 유스케이스 패턴:
public struct MyUsecase: MyUsecaseProtocol {
    private let repository: MyRepositoryProtocol
    public func execute(...) async -> Result<Model, UsecaseError> { ... }
}
```

## 의존성

### 내부
- `SolSolCore` — 로깅, 공유 유틸리티

<!-- MANUAL: -->
