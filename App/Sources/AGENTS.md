<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# App/Sources

## 목적
애플리케이션 진입점과 최상위 라우팅을 위한 루트 소스 파일들. `AppDelegate`, `SceneDelegate`, DI 부트스트랩/어셈블리 레이어, 루트 코디네이터를 포함합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `AppDelegate.swift` | UIApplication 델리게이트 — 최소한의 설정, 씬 관리를 씬 델리게이트에 위임 |
| `SceneDelegate.swift` | UIWindowScene 델리게이트 — 윈도우 생성 및 `AppCoordinator` 시작 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `DI/` | 의존성 주입 — 어셈블리, 부트스트래퍼, Factory 컨테이너 확장 (`DI/AGENTS.md` 참고) |
| `Routing/` | 첫 번째 기능 흐름을 실행하는 루트 코디네이터(`AppCoordinator`) (`Routing/AGENTS.md` 참고) |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `SceneDelegate`에서 `AppCoordinator`를 인스턴스화 — `UIWindow`를 전달
- 비즈니스 로직을 여기에 추가하지 말 것 — 진입점 파일은 최소한으로 유지

<!-- MANUAL: -->
