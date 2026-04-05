<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DesignSystem/Sources

## 목적
`DesignSystem` 프레임워크의 모든 소스 코드. 기반 뷰 컨트롤러, 레이아웃 프로토콜, 모든 SD 접두사 UI 컴포넌트, 디자인 토큰 타입, 애니메이션 유틸리티를 포함합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `BaseViewController.swift` | 모든 앱 VC의 기반 클래스 — 배경색 설정, `setupProperties()`, `setupViews()`, `setupLayout()` 호출 |
| `Layoutable.swift` | `setupViews()`, `setupProperties()`, `setupLayout()` 필수 구현 프로토콜 — 모든 VC와 커스텀 뷰에 적용 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Components/` | 재사용 가능한 SD 접두사 UI 컴포넌트 (`Components/AGENTS.md` 참고) |
| `Components/Charts/` | 차트 라이브러리 사용을 위한 차트 데이터 엔트리 타입 |
| `Extensions/` | UIKit 확장 (예: `UIView+Extension.swift`) |
| `Foundation/` | 디자인 토큰 — 색상, 폰트, 이미지, 애니메이션, 번들 접근자 |
| `Foundation/Animations/` | 재사용 가능한 애니메이션 구현 (damping, haptic, wave) |
| `Foundation/Colors/` | `SDColors` 카탈로그 + `UIColor` 확장 |
| `Foundation/Fonts/` | `SDFonts` 카탈로그 |
| `Foundation/Images/` | `SDImages` 카탈로그 + `UIImage` 확장 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 모든 새 VC는 반드시 `BaseViewController`를 상속해야 함
- 모든 새 커스텀 뷰는 `Layoutable`을 구현해야 함
- 색상/폰트/이미지는 `SDColors.xxx`, `SDFonts.xxx`, `SDImages.xxx` 사용 — 하드코딩 절대 금지
- `BaseViewController`에 Combine 구독을 위한 `bindings: Set<AnyCancellable>` 존재

<!-- MANUAL: -->
