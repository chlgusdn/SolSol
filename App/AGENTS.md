<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# App

## 목적
메인 애플리케이션 타깃. `AppDelegate`/`SceneDelegate`를 통해 UIApplication 진입점을 소유하며, 시작 시 모든 DI 어셈블리를 연결하고 루트 `AppCoordinator`를 실행합니다. 다른 모든 모듈을 알고 있는 유일한 모듈입니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Project.swift` | App 타깃의 Tuist 프로젝트 정의 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Sources/` | Swift 소스 파일 — AppDelegate, SceneDelegate, DI, Routing (`Sources/AGENTS.md` 참고) |
| `Resources/` | 앱 리소스 — Info.plist |
| `Derived/Sources/` | Tuist 자동 생성 에셋/번들 접근자 — 직접 수정 금지 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `Project.swift`에서 앱 타깃 정의 — 새 모듈 의존성 추가 시 여기서 업데이트
- Derived 파일은 `tuist generate`로 재생성됨 — 절대 직접 수정 금지
- App 모듈은 다른 모든 모듈을 import하는 유일한 위치

### 테스트 방법
- App 전용 테스트 타깃 없음 — 통합 테스트는 기능 모듈 테스트로 대체

### 공통 패턴
- DI 등록은 `Sources/DI/Assemblies/`에서 — 기능/레이어별 어셈블리 파일 1개씩
- `DependencyBootstrapper.start()`가 시작 시 모든 어셈블리를 등록
- `AppCoordinator`는 단일 루트 코디네이터로, `SceneDelegate`에서 생성

## 의존성

### 내부
- `HomePresentation` — 홈 기능 모듈
- `SolSolCore` — Coordinator 프로토콜, 로깅
- 기타 모든 모듈 (기능 모듈을 통해 전이적으로)

### 외부
- `Factory` — DI 컨테이너

<!-- MANUAL: -->
