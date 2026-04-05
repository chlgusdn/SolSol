<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Home/Coordinators

## 목적
홈 기능 플로우를 위한 네비게이션 코디네이터. `HomeCoordinator`가 진입점이며, `ExpenseCoordinator`는 지출 추가/수정 서브 플로우를 처리합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `HomeCoordinator.swift` | 루트 홈 코디네이터 — `HomeViewController` 생성 및 push, `dependencies`에서 VM 해결 |
| `ExpenseCoordinator.swift` | 지출 입력 플로우를 위한 서브 코디네이터 — `HomeCoordinator`에서 push |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `HomeCoordinator`는 `dependencies: HomeDependencyProviding`을 받음 — `Container.shared`에서 직접 해결하지 않고 이것에서 VM 해결
- 자식 코디네이터는 `childCoordinators`에 추가하고 완료 시 반드시 `finish()` 호출
- `ExpenseCoordinator`는 `HomeCoordinator`의 자식 — 부모가 `childCoordinatorDidFinish`를 통해 정리

<!-- MANUAL: -->
