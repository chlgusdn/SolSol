<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Presentation

## 목적
모든 기능 프레젠테이션 모듈의 컨테이너. 각 하위 디렉토리는 코디네이터, 뷰 모델, 뷰를 포함하는 독립적인 기능 모듈로 정적 프레임워크로 컴파일됩니다.

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Home/` | 홈/대시보드 기능 — 지출 요약, 차트, 변화율 (`Home/AGENTS.md` 참고) |
| `Transaction/` | 거래 관리 기능 — 수입/지출 추가 및 수정 (`Transaction/AGENTS.md` 참고) |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 각 기능은 완전히 독립적 — 기능 모듈끼리 서로 import 금지
- 기능 간 통신은 코디네이터 위임(부모 코디네이터 패턴)으로만
- 새 기능 추가 시 `Module.featureProject(...)`를 사용해 자체 `Project.swift`가 있는 새 하위 디렉토리 생성
- `Tuist/ProjectDescriptionHelpers/DependencyGraph.swift`와 `Workspace.swift`에 새 모듈 등록

### 공통 패턴
- 각 기능은 App이 Factory로 조립하는 `DependencyProviding` 프로토콜을 노출
- 코디네이터는 초기화자에서 `dependencies: FeatureDependencyProviding`을 받음
- 뷰 모델은 `ObservableObject` + `@Published` 사용, VC에서 Combine으로 바인딩

<!-- MANUAL: -->
