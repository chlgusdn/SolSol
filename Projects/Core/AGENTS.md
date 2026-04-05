<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Core (SolSolCore)

## 목적
다른 모든 모듈이 import하는 기반 모듈. 화면 전환을 위한 `Coordinator` 프로토콜, 타입 확장, `Log` 로깅 유틸리티를 제공합니다. 다른 내부 모듈에 대한 의존성이 없습니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Project.swift` | Tuist 프로젝트 정의 — 내부 의존성 없는 `layerProject` |

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Sources/` | Core 소스 파일 — Coordinator, 확장, Logger (`Sources/AGENTS.md` 참고) |
| `Tests/` | Core 유틸리티 단위 테스트 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 이 모듈은 의존성이 없어야 함 (다른 내부 모듈 import 금지)
- 모듈 이름은 `SolSolCore` (`Core` 아님) — 항상 `import SolSolCore`로 사용
- 여기의 확장은 범용 목적 — 앱 특화 로직 추가 금지

### 테스트 방법
- `CoreTests` 스킴으로 실행

<!-- MANUAL: -->
