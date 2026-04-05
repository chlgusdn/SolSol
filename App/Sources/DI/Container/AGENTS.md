<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DI/Container

## 목적
`AppContainer` — 앱의 중앙 Factory 컨테이너 참조 및 커스텀 컨테이너 설정. 모든 `XxxDependencyProviding` 프로토콜의 구체적 구현체로, 기능 모듈이 의존성을 해결할 수 있도록 합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `AppContainer.swift` | 싱글턴 컨테이너 — `HomeDependencyProviding` 및 다른 기능 의존성 프로토콜을 준수하며, `Container.shared`에서 VM을 해결 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `AppContainer.shared`는 의존성 파라미터로 기능 코디네이터에 전달됨
- 새 기능의 `XxxDependencyProviding` 프로토콜 추가 시 여기서 `AppContainer`를 확장해 준수
- `AppContainer`는 Factory 컨테이너와 코디네이터 DI 패턴을 연결하는 브릿지

<!-- MANUAL: -->
