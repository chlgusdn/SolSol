<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DesignSystem

## 목적
재사용 가능한 컴포넌트, 디자인 토큰(색상, 폰트, 이미지), 애니메이션을 제공하는 공유 UI 디자인 시스템. 모든 기능 모듈의 ViewController와 UI 컴포넌트는 이 모듈 위에서 구축됩니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Project.swift` | Tuist 프로젝트 정의 — `hasResources: true`인 `layerProject` |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Sources/` | 디자인 시스템 소스 — 컴포넌트, 파운데이션, 확장 (`Sources/AGENTS.md` 참고) |
| `Resources/Foundation/` | 번들 에셋 — `Localizable.xcstrings`, 커스텀 폰트 (`Moneygraphy-Pixel.ttf`, `Moneygraphy-Rounded.ttf`) |
| `Derived/Sources/` | Tuist 자동 생성 에셋/폰트/번들 접근자 — 직접 수정 금지 |
| `Tests/` | 디자인 시스템 테스트 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `Derived/Sources/`의 생성 타입으로 에셋 접근: `SDColors`, `SDFonts`, `SDImages`
- `BaseViewController`는 여기에 정의됨 — 모든 기능 VC는 이를 상속해야 함
- 문자열 리소스는 `Resources/Foundation/Localizable.xcstrings`에 위치
- 커스텀 폰트는 `Resources/Foundation/`에 추가하고 `Project.swift`에 등록해야 함

### 공통 패턴
- 모든 커스텀 컴포넌트는 `SD` 접두사 사용 (SolSol Design)
- `Layoutable` 프로토콜: `setupViews()`, `setupProperties()`, `setupLayout()` 구현
- `BaseViewController`는 `viewDidLoad()`에서 `setupProperties()`와 `setupViews()`를, `viewDidLayoutSubviews()`에서 `setupLayout()`을 호출

## 의존성

### 내부
- `SolSolCore` — `BaseViewController`에서 로깅

### 외부
- 없음 (UIKit만 사용)

<!-- MANUAL: -->
