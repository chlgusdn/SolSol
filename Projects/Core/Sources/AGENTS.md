<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Core/Sources

## 목적
`SolSolCore` 프레임워크의 모든 소스 코드. 화면 전환을 위한 `Coordinator` 프로토콜, 구조화된 로깅 유틸리티, 범용 Swift 타입 확장을 제공합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Coordinator.swift` | `Coordinator` 프로토콜 — `navigationController`, `childCoordinators`, `parentCoordinator`, `start()`, `finish()` |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Extensions/` | 타입 확장 — `Date`, `Decimal`, `Double`, `Int`, `LocalizedStringResource` |
| `Logger/` | `Log` 유틸리티 — 구조화된 콘솔 로깅 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `Coordinator` 프로토콜: `finish()`는 모든 자식 코디네이터를 제거; `childCoordinatorDidFinish(with:)`는 특정 자식을 제거
- `Log`는 정적 메서드 제공(`Log.d`, `Log.e` 등) — 앱 전반에 걸쳐 일관된 로깅을 위해 사용
- 확장은 순수 유틸리티 — 앱 특화 로직 없음

<!-- MANUAL: -->
