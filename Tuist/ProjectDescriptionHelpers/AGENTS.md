<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# ProjectDescriptionHelpers

## 목적
`import ProjectDescription`을 통해 워크스페이스의 모든 `Project.swift` 파일에서 자동으로 사용 가능한 공유 Swift 파일들. 모듈 생성 헬퍼, 의존성 열거형, 모든 외부 패키지 참조를 정의합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Module.swift` | 표준화된 Tuist 프로젝트 생성을 위한 `layerProject(...)` 및 `featureProject(...)` 팩토리 함수 |
| `DependencyGraph.swift` | 모든 내부/외부 의존성을 나열하는 `ModuleDependency` 열거형; 모든 SPM URL을 포함하는 `ExternalPackages` 열거형 |
| `Project+Templates.swift` | 추가 프로젝트 설정 템플릿 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 새 내부 모듈 의존성 추가: `DependencyGraph.swift`의 `ModuleDependency`에 케이스 추가
- 새 외부 SPM 패키지 추가: `ExternalPackages.all` 배열과 `ModuleDependency` 케이스 모두에 추가
- `layerProject`는 소스 + 테스트 모듈 생성, 기본적으로 리소스 없음
- `featureProject`는 소스 + 테스트가 있는 프레젠테이션 기능 모듈 생성
- iOS 배포 타깃은 `Module.deploymentTarget`에서 한 번만 설정 — 여기서 변경하면 모든 모듈에 적용

### 공통 패턴
```swift
// 모든 Project.swift에서:
let project = Module.featureProject(
    name: "MyFeature",
    bundleId: "com.solsol.MyFeature",
    dependencies: [.core, .designSystem, .domain]
)
```

<!-- MANUAL: -->
