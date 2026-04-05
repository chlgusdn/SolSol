<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Presentation/Transaction (TransactionPresentation)

## 목적
거래 관리 기능 모듈. 현재 스캐폴딩 상태 — `TransactionScenePlaceholder.swift`가 작업 진행 중임을 표시합니다. 수입/지출 거래의 추가 및 수정을 위한 전체 플로우를 포함할 예정입니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Project.swift` | Tuist 프로젝트 정의 |
| `Sources/TransactionScenePlaceholder.swift` | 플레이스홀더 파일 — 기능 구현 대기 중 |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Tests/` | 거래 기능 단위 테스트 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 이 모듈은 스텁 상태 — 코디네이터, 뷰 모델, 뷰를 추가해야 함
- `HomePresentation`과 동일한 패턴으로: `TransactionDependencyProviding`, 코디네이터, VM, VC 생성
- 모듈 이름은 `TransactionPresentation` — `import TransactionPresentation`으로 사용
- `App/Sources/DI/Assemblies/TransactionAssembly.swift`에 등록 (이미 존재)

## 의존성

### 내부
- `SolSolCore` — `Coordinator` 프로토콜
- `DesignSystem` — `BaseViewController`, SD 컴포넌트
- `Domain` — 유스케이스 프로토콜

<!-- MANUAL: -->
