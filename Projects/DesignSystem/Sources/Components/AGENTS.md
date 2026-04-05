<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DesignSystem/Components

## 목적
모든 기능 모듈에서 사용되는 재사용 가능한 SD 접두사 UIKit 컴포넌트. 각 컴포넌트는 디자인 시스템 스타일이 적용된 표준 UIKit 컨트롤을 감쌉니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `SDButton.swift` | 디자인 시스템 버튼 |
| `SDLabel.swift` | 타이포그래피 토큰이 적용된 디자인 시스템 레이블 |
| `SDTextField.swift` | 디자인 시스템 텍스트 필드 |
| `SDImageView.swift` | 디자인 시스템 이미지 뷰 |
| `SDImageButton.swift` | 이미지가 있는 버튼 |
| `SDStackView.swift` | 디자인 시스템 스택 뷰 |
| `SDView.swift` | 기반 디자인 시스템 뷰 |
| `SDTouchableView.swift` | 터치 가능한 컨테이너 뷰 |
| `SDUnderLineView.swift` | 밑줄 스타일 뷰 |
| `SDCountingLabel.swift` | 애니메이션 카운팅/증가 레이블 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Charts/` | `SDChartDataEntry` — 차트 컴포넌트를 위한 데이터 엔트리 타입 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 모든 컴포넌트는 `SD` 접두사 사용 — 기능 모듈에 일반 UIKit 서브클래스 추가 금지
- 컴포넌트는 Foundation의 `SDColors`, `SDFonts`, `SDImages` 사용 — 하드코딩 절대 금지
- 새 컴포넌트는 `Layoutable`을 구현하고 기능 모듈이 아닌 여기에 추가

<!-- MANUAL: -->
