<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# App/Sources/DI

## 목적
의존성 주입 연결 레이어. 앱 시작 시 모든 유스케이스, 리포지토리, 뷰 모델을 Factory `Container`에 등록합니다. 기능/레이어별 어셈블리 파일과 모두를 호출하는 부트스트래퍼로 구성됩니다.

## 하위 디렉토리

| 디렉토리 | 목적 |
|---------|------|
| `Assemblies/` | 기능/레이어별 등록 파일 — 각자 Factory 팩토리를 등록 |
| `Bootstrap/` | `DependencyBootstrapper` — 시작 시 모든 어셈블리의 `register()` 메서드 호출 |
| `Container/` | `AppContainer` — Factory 컨테이너 커스터마이징 또는 공유 컨테이너 참조 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 새 기능 추가 시 `Assemblies/`에 새 `XxxAssembly.swift` 생성 후 `DependencyBootstrapper`에서 호출
- 어셈블리 파일은 팩토리를 등록하고 동시에 타입화된 `Factory<T>` 프로퍼티로 `Container`를 확장
- 미등록 팩토리는 런타임에 `fatalError` — 사용 전 반드시 등록
- `Container.shared.myFactory()`로 의존성 해결

### 공통 패턴
```swift
// 어셈블리 패턴 (HomeAssembly.swift 참고):
enum MyAssembly {
    static func register() {
        Container.shared.myViewModel.register {
            MyViewModel(usecase: Container.shared.myUsecase())
        }
    }
}
public extension Container {
    var myViewModel: Factory<MyViewModel> {
        self { fatalError("not registered") }
    }
}
```

<!-- MANUAL: -->
