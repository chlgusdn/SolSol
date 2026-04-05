<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Tuist

## 목적
Tuist 프로젝트 설정 및 헬퍼 파일들. 모든 외부 SPM 의존성, 모듈 템플릿, 모듈 간 의존성 그래프를 정의합니다. `tuist generate`가 이 파일들을 사용해 `.xcodeproj`와 `.xcworkspace`를 생성합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Package.swift` | 모든 외부 의존성을 나열하는 SPM 패키지 매니페스트 |
| `Package.resolved` | 잠긴 의존성 버전 |
| `Dependencies.swift` | Tuist 의존성 설정 (레거시 또는 보조) |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `ProjectDescriptionHelpers/` | 모든 `Project.swift`에서 공유하는 헬퍼 (`ProjectDescriptionHelpers/AGENTS.md` 참고) |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `Package.swift` 수정 후 `tuist install` → `tuist generate` 순서로 실행
- `Package.resolved`는 커밋해야 함 — 의존성 버전을 잠금
- `ProjectDescriptionHelpers/`의 헬퍼 파일은 `import ProjectDescription`을 통해 모든 `Project.swift`에서 자동으로 사용 가능

<!-- MANUAL: -->
