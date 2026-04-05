<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DesignSystem/Foundation

## 목적
디자인 토큰 및 기반 유틸리티. 앱 전체에서 사용되는 모든 시각적 상수(색상, 폰트, 이미지)와 애니메이션 프리미티브의 단일 진실 공급원(Single Source of Truth)을 제공합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `DesignSystemBundle.swift` | DesignSystem 리소스 번들 접근자 — 프레임워크 번들에서 폰트와 에셋을 로드하는 데 사용 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Animations/` | 애니메이션 구현 — `DampingAnimation`, `HapticFeedbackAnimation`, `WaveAnimation` |
| `Colors/` | `SDColors` 카탈로그 + `UIColor+DesignSystem` 확장 |
| `Fonts/` | `SDFonts` 카탈로그 — Moneygraphy-Pixel, Moneygraphy-Rounded |
| `Images/` | `SDImages` 카탈로그 + `UIImage+DesignSystem` 확장 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `SDColors`, `SDFonts`, `SDImages`는 색상/폰트/이미지 상수를 정의하는 유일한 위치
- 커스텀 폰트(`Moneygraphy-Pixel`, `Moneygraphy-Rounded`)는 `Resources/Foundation/`에 있으며 `SDFonts`로 접근
- 디자인 시스템 컴포넌트용 지역화 문자열은 `Resources/Foundation/Localizable.xcstrings`에 위치

<!-- MANUAL: -->
