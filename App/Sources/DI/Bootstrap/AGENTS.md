<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# DI/Bootstrap

## 목적
앱 시작 시 모든 DI 어셈블리 등록을 조율하는 단일 진입점.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `DependencyBootstrapper.swift` | 의존성 순서에 맞게 모든 `XxxAssembly.register()` 메서드를 호출 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `AppCoordinator` 생성 전 `SceneDelegate`에서 `DependencyBootstrapper.start()`(또는 동등한 메서드) 호출
- 새 어셈블리 추가 시 올바른 순서(Data → Domain → Presentation)로 여기에 `register()` 호출 추가

<!-- MANUAL: -->
