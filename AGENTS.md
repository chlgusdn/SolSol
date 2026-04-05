<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# SolSol

## 목적
SolSol은 수입과 지출을 추적하는 모듈형 iOS 개인 가계부 앱입니다. Clean Architecture와 Tuist를 사용해 모듈형 프로젝트를 구성하며, iOS 18.0+를 타깃으로 합니다. UIKit과 Coordinator 패턴으로 화면 전환을 처리하고, Combine으로 반응형 프로그래밍을 구현하며, GRDB로 SQLite 로컬 저장소를 관리하고, FlexLayout/PinLayout으로 코드 기반 UI를 작성합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Workspace.swift` | Tuist 워크스페이스 정의 — App과 Projects/** 모듈을 포함 |
| `Tuist.swift` | Tuist 설정 파일 |
| `.package.resolved` | Swift Package Manager 의존성 잠금 파일 |
| `.gitignore` | Git 무시 규칙 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `App/` | 앱 메인 타깃 — 진입점, DI 연결, AppCoordinator (`App/AGENTS.md` 참고) |
| `Projects/` | 정적 프레임워크로 구성된 기능/레이어 모듈들 (`Projects/AGENTS.md` 참고) |
| `Tuist/` | Tuist 헬퍼 — 의존성 그래프, 모듈 템플릿, SPM 패키지 (`Tuist/AGENTS.md` 참고) |
| `Templates/` | 새 모듈 생성을 위한 Stencil 코드 템플릿 (`Templates/AGENTS.md` 참고) |

## AI 에이전트 가이드

### 아키텍처 개요
```
App (UIApplication 진입점)
 └── AppCoordinator
      └── HomeCoordinator → HomeViewController
           └── ExpenseCoordinator → Transaction 화면

DI: Factory (hmlongco/Factory) — App/Sources/DI/Assemblies/ 에서 등록
데이터 흐름: ViewModel → Usecase → Repository (protocol) ← RepositoryImpl → SQLAccessor (GRDB)
```

### 이 디렉토리에서 작업할 때
- `Derived/Sources/` 내의 생성 파일은 절대 직접 수정하지 말 것 — Tuist가 자동 생성
- `Project.swift` 또는 Tuist 헬퍼 파일 수정 후에는 반드시 `tuist generate` 실행
- 새 모듈 추가 시 `Workspace.swift`를 업데이트하고 `Tuist/ProjectDescriptionHelpers/`의 헬퍼로 `Project.swift` 생성
- 모든 모듈은 `staticFramework` 프로덕트 타입

### 의존성 방향 (엄격 준수)
```
App → Presentation → Domain ← Data
App → Core, DesignSystem
Presentation → Core, DesignSystem
Data → Core
```
Domain은 Data, Presentation, App을 절대 import하면 안 됨.

### 테스트 방법
- 각 모듈에 `Tests/` 타깃 존재 — `tuist test`로 실행
- Data 레이어 테스트는 실제 DB를 피하기 위해 `MockSQLAccessor` 사용

### 공통 패턴
- 모든 화면 전환에 Coordinator 패턴 사용 (`Core`의 `Coordinator` 프로토콜)
- `ObservableObject` + `@Published` ViewModel을 ViewController에서 Combine으로 바인딩
- Factory DI 컨테이너 — `App/Sources/DI/Assemblies/`에서 등록, `Container.shared`로 사용
- 모든 ViewController는 DesignSystem의 `BaseViewController` 상속

## 의존성

### 외부 (SPM)
- `Factory 2.5.3+` — 의존성 주입 컨테이너
- `GRDB 7.6.1+` — SQLite ORM / 반응형 데이터베이스
- `FlexLayout 2.1.0+` — Flexbox 기반 코드 레이아웃
- `PinLayout 1.10.5+` — 앵커 기반 코드 레이아웃
- `FSCalendar 2.8.4+` — 캘린더 UI 컴포넌트
- `yoga 3.2.1+` — Flexbox 레이아웃 엔진 (FlexLayout 의존성)

<!-- MANUAL: -->
