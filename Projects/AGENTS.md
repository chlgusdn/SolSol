<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Projects

## 목적
모든 모듈형 정적 프레임워크 타깃의 컨테이너. Clean Architecture 레이어별로 구성되어 있습니다. 각 하위 디렉토리는 `staticFramework`로 컴파일되는 독립적인 Tuist 프로젝트입니다.

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Core/` | 공유 유틸리티 — Coordinator 프로토콜, 확장, 로깅 (`Core/AGENTS.md` 참고) |
| `Data/` | 데이터 레이어 — SQLite 접근, 리포지토리, 엔티티, 매퍼 (`Data/AGENTS.md` 참고) |
| `DesignSystem/` | UI 디자인 시스템 — 컴포넌트, 색상, 폰트, 애니메이션 (`DesignSystem/AGENTS.md` 참고) |
| `Domain/` | 비즈니스 로직 — 유스케이스, 도메인 모델, 리포지토리 프로토콜 (`Domain/AGENTS.md` 참고) |
| `Presentation/` | 기능 UI 모듈 — Home, Transaction (`Presentation/AGENTS.md` 참고) |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 각 하위 디렉토리는 자체 `Project.swift`를 가진 완전히 독립적인 모듈
- 새 레이어 모듈 추가: `Tuist/ProjectDescriptionHelpers/`의 `Module.layerProject(...)` 헬퍼 사용
- 새 기능 모듈 추가: `Module.featureProject(...)` 헬퍼 사용
- 모든 모듈은 iOS 18.0+ 타깃

### 의존성 방향
```
Presentation → Domain, Core, DesignSystem
Data → Core
Domain → Core
DesignSystem → (없음)
Core → (없음)
```

<!-- MANUAL: -->
