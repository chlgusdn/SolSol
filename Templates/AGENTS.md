<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Templates

## 목적
새 모듈 스캐폴딩을 위한 Stencil 코드 생성 템플릿. 프로젝트 컨벤션에 맞는 기능 모듈과 레이어 모듈의 보일러플레이트를 빠르게 생성하는 데 사용합니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `FeatureModule.stencil` | 새 Presentation 기능 모듈 템플릿 |
| `LayerModule.stencil` | 새 Core/Data/Domain 레이어 모듈 템플릿 |
| `ProjectFile.stencil` | `Project.swift` 파일 생성 템플릿 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `.stencil` 파일은 Stencil 템플릿 — Tuist의 템플릿 생성 명령어로 사용
- 새 기능 추가 시 수동으로 파일을 생성하는 것보다 이 템플릿 사용을 권장
- 템플릿은 기존 모듈에서 확립된 패턴을 따라야 함

<!-- MANUAL: -->
