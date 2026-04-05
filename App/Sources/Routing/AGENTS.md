<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# App/Sources/Routing

## 목적
루트 레벨 네비게이션 코디네이터. `AppCoordinator`는 코디네이터 트리의 최상단으로, 루트 `UINavigationController`를 소유하고 첫 번째 기능 코디네이터(`HomeCoordinator`)를 실행합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `AppCoordinator.swift` | 루트 코디네이터 — `HomeCoordinator`를 생성하고 의존성으로 `AppContainer.shared`를 주입 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `AppCoordinator`는 앱 `UIWindow`를 받아 `SceneDelegate`에서 생성
- 새 루트 플로우(예: 온보딩) 추가 시 Home 실행 전 여기에 추가
- 기능 코디네이터에 `AppContainer.shared`를 (`HomeDependencyProviding` 준수) 전달

<!-- MANUAL: -->
