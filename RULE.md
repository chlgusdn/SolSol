# RULE.md — 코드 규칙

> Swift 코드를 작성·수정할 때 따르는 규칙입니다. 진입점과 작업 절차는 [`AGENTS.md`](AGENTS.md), 디자인은 [`DESIGN.md`](DESIGN.md)를 보세요.

## 목차
1. [모듈과 의존성](#1-모듈과-의존성)
2. [파일 생성 · 네이밍 · 접근 제어](#2-파일-생성--네이밍--접근-제어)
3. [Domain 규칙](#3-domain-규칙)
4. [Data 규칙 (SQLiteData)](#4-data-규칙-sqlitedata)
5. [Client 규칙](#5-client-규칙)
6. [Reducer 규칙](#6-reducer-규칙)
7. [Store · View 규칙](#7-store--view-규칙)
8. [내비게이션 규칙](#8-내비게이션-규칙)
9. [동시성 · 시간 규칙](#9-동시성--시간-규칙)
10. [테스트 규칙](#10-테스트-규칙)
11. [Tuist · 외부 의존성 규칙](#11-tuist--외부-의존성-규칙)

---

## 1. 모듈과 의존성

```
App          → Features, Data, Clients, Domain, DesignSystem, Core
Features     → Clients, Domain, DesignSystem, Core (+ ComposableArchitecture)
Data         → Clients, Domain, Core (+ SQLiteData, GRDB, Kronos)
Clients      → Domain (+ Dependencies, DependenciesMacros)
DesignSystem → Core
Domain       → Foundation만
```

- **Domain**은 어떤 모듈도, TCA도, SwiftUI도 import하지 않는다
- **Features**는 Data를 import하지 않는다 — DB 접근은 반드시 Client를 통한다
- **Feature 모듈은 기능 단위다** — 한 흐름으로 이어지고 같은 데이터·표시 규칙을 쓰는 화면들(예: 텅장방지 + 예산 설정)은 한 모듈에 둔다. 따로 쓰이는 기능은 모듈을 나눈다
- **Feature 모듈끼리는 서로 import하지 않는다** — 화면 간 이동은 모듈 안이든 밖이든 `AppFeature`가 조립한다
- **DesignSystem**은 TCA와 Domain을 import하지 않는다
- **Kronos**는 Data에서만 import한다
- 모듈 의존성은 `Project.swift`에서 `ModuleDependency` 헬퍼로만 선언한다 (`.domain`, `.feature("Home")`, `.external(.sqliteData)` …)

## 2. 파일 생성 · 네이밍 · 접근 제어

### 파일 위치

| 종류 | 위치 | 이름 |
|------|------|------|
| 도메인 모델 | `Domain/Sources/Models/` | `Xxx.swift` |
| 도메인 계산 | `Domain/Sources/Calculators/` | `XxxCalculator.swift`, `Type+Xxx.swift` |
| Client 인터페이스 | `Clients/Sources/` | `XxxClient.swift` (인터페이스 + `DependencyValues` + `testValue` + `previewValue`) |
| DAO | `Data/Sources/DAO/` | `XxxDAO.swift` |
| live 연결 | `Data/Sources/Live/` | `XxxClient+Live.swift` |
| live 등록 | `Data/Sources/Live/LiveDependencies.swift` | `bootstrapLive(database:)` |
| DB 레코드 | `Data/Sources/Records/` | `XxxRecord.swift` |
| 변환 | `Data/Sources/Mappers/` | `XxxMapper.swift` |
| 마이그레이션 | 등록: `Data/Sources/Database/AppDatabase.swift`, 내용: `Database/MigrationVN.swift` | id는 `MigrationID.vN` (`"vN_설명"`) |
| Feature | `Features/<Name>/Sources/` (화면이 여럿이면 `Sources/<Screen>/`) | `<Screen>Feature.swift`, `<Screen>View.swift` |
| Feature 테스트 | `Features/<Name>/Tests/` | `<Name>FeatureTests.swift` |
| 확장 | 해당 모듈 `Sources/Extensions/` | `Type+기능.swift` (예: `Int+Currency.swift`) |

- 새 모듈·Feature·Client는 **직접 만들지 말고 `tuist scaffold`** 로 생성한다
- 파일 하나에 주요 타입 하나. **View는 하위 View까지 한 파일에 하나** — 화면 전용 하위 View는 그 화면 폴더의 `Components/<ViewName>.swift`에, 같은 모듈의 여러 화면이 함께 쓰는 것은 `Sources/Shared/`에 `internal`로 둔다
- 파일을 추가·삭제하면 `tuist generate`를 다시 실행한다

### 네이밍
- 타입: `UpperCamelCase`. Feature는 `XxxFeature` / `XxxView`, Client는 `XxxClient`, DAO는 `XxxDAO`, 레코드는 `XxxRecord`
- 테이블 이름: 복수형 camelCase (`transactionRecords`)
- Bool: `is`/`has`/`can` 접두사 (`isLoading`, `canSave`)
- 테스트 함수: `대상_조건_기대결과` (`save_existingId_updates`)

### 접근 제어
- 다른 모듈에서 쓰는 것만 `public`. 기본은 `internal`
- Feature의 `State`, `Action`, `init`, `body`, View와 View의 `init`은 `public`
- Data의 Record, DAO, Mapper는 `internal`. 모듈 밖으로 나가는 것은 `appDatabase()`, `bootstrapLive`, `DateGenerator.trusted`뿐
- `Domain.Transaction`은 `SwiftUI.Transaction`과 이름이 겹친다 → 각 Feature 모듈에 `Sources/Domain+Aliases.swift`(`public typealias Transaction = Domain.Transaction`)를 두고, 테스트에서는 `Domain.Transaction`으로 명시한다
- **시스템 타입과 겹치는 이름을 새로 만들지 않는다.** 예: `Category`는 Objective-C 런타임 타입(`OpaquePointer`)과 겹쳐서 `TransactionCategory`로 지었다
- 모듈 이름 `Data`는 `Foundation.Data`와 겹쳐 `Data.xxx`로 한정할 수 없다 → Data 모듈의 전역 함수는 메서드와 이름이 겹치지 않게 짓는다 (예: `observeDatabase`)

## 3. Domain 규칙
- `struct` / `enum`만 사용한다. `class`, 싱글톤, 전역 가변 상태 금지
- 모든 모델은 `Sendable`, `Hashable`(또는 `Equatable`), 필요하면 `Identifiable`
- 금액은 **원 단위 `Int`**, 항상 0 이상. 부호는 `TransactionType`이 결정한다 (`signedAmount`)
- id는 `UUID`. 새 id는 호출 측이 `@Dependency(\.uuid)`로 만든다 (Domain이 직접 `UUID()` 생성 금지)
- 계산 로직은 부작용 없는 순수 함수로 작성한다 (`enum XxxCalculator { static func ... }` 또는 모델 extension)
- `Calendar`, 현재 시각처럼 환경에 따라 달라지는 값은 **인자로 받는다** (`calendar: Calendar = .current`)
- 사용자 표시 이름(`displayName`)은 Domain에 둔다 — Feature끼리 import할 수 없어 공유 위치가 필요하기 때문
- 대량 집계는 Domain이 아니라 DB(SQL)에서 한다 (§4). Domain 계산은 메모리에 이미 있는 목록에만 쓴다

## 4. Data 규칙 (SQLiteData)
- DB 모델은 `@Table("테이블명") struct XxxRecord`로 정의하고, Mapper로 Domain 모델과 변환한다
- Record의 enum 컬럼은 `String` raw value + `QueryBindable` (예: `TransactionTypeColumn`)
- 조인 결과는 튜플이 아니라 `@Selection` 구조체로 받는다 (`.select { TransactionWithCategory.Columns(transaction: $0, category: $1) }`)
- 컬럼 저장 형식: UUID는 **소문자 텍스트**, Date는 `yyyy-MM-dd HH:mm:ss.SSS`(UTC) 텍스트, Bool은 0/1 정수. 마이그레이션 SQL과 테스트 데이터도 이 형식을 따른다
- 하나만 존재하는 데이터(예산)는 `id = 1` CHECK 제약 + `upsert`로 저장한다. 키-값 설정은 `appSettings` 테이블
- 기본 데이터(기본 카테고리 등)는 마이그레이션에서 **SQL 리터럴로 고정 id**를 넣는다. Domain 상수(`TransactionCategory.Default`)와 같은 값을 쓰고, 둘이 같은지 테스트한다
- Record 타입은 Data 밖으로 절대 노출하지 않는다
- 스키마 변경은 `DatabaseMigrator`에 **새 마이그레이션을 추가**한다. 이미 배포된 마이그레이션은 수정 금지
- 테이블은 `STRICT`, 필요한 `CHECK` 제약과 인덱스를 함께 정의한다
- 집계(합계, 기간 비교, 카테고리별 합산)는 SQL로 DB에서 처리한다 (`sum(filter:)`, `group(by:)`)
- 관찰은 공용 헬퍼 `observeDatabase(_:fetch:)`(GRDB `ValueObservation` → `AsyncThrowingStream`)를 쓴다. 스트림이 끝나면 관찰도 취소된다
- Feature에서 `@FetchAll` / `@FetchOne`을 쓰지 않는다 — 읽기·쓰기 모두 Client를 통한다
- DB 연결은 App 진입점에서 `appDatabase()`로 한 번만 연다

```swift
// Data/Sources/Database/AppDatabase.swift
func makeMigrator() -> DatabaseMigrator {
    var migrator = DatabaseMigrator()
    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration(MigrationID.v1) { db in /* CREATE TABLE ... */ }
    migrator.registerMigration(MigrationID.v2, migrate: migrateV2)   // Database/MigrationV2.swift
    // migrator.registerMigration(MigrationID.v3, migrate: migrateV3)  ← 새 변경은 여기 추가
    return migrator
}
```

## 5. Client 규칙
- **protocol이 아닌 struct + 클로저 프로퍼티** + `@DependencyClient` (Point-Free 표준). protocol 기반 DI와 섞지 않는다
- 인터페이스는 Clients, live 구현은 Data에 둔다
- 실제 로직은 **DAO의 일반 메서드**에 작성하고, live는 DAO 메서드를 클로저에 연결만 한다
- Client는 **Domain 모델만** 주고받는다
- 클로저 인자에 레이블을 붙인다 (`_ interval:`) → 호출은 `client.fetch(interval:)`
- throw하지 않는 클로저는 기본값을 지정한다 (매크로 요구사항)
- `testValue = Self()` (매크로가 만든 unimplemented), `previewValue`는 공용 인메모리 저장소 `PreviewStore`(Clients/Sources/Preview)로 구현한다 — 변경 시 관찰 스트림에도 반영된다
- **새 Client는 `bootstrapLive(database:)`에 반드시 등록한다.** Data는 staticFramework라서 App이 직접 참조하지 않는 `XxxClient+Live.swift`는 링커가 제거하고, 그러면 `DependencyKey` 적합성이 사라져 앱에서 `testValue`(unimplemented)가 쓰인다

```swift
// Clients/Sources/TransactionClient.swift
@DependencyClient
public struct TransactionClient: Sendable {
    public var fetch: @Sendable (_ interval: DateInterval) async throws -> [Transaction]
    public var save: @Sendable (_ transaction: Transaction) async throws -> Void
    public var observe: @Sendable (_ interval: DateInterval) -> AsyncThrowingStream<[Transaction], any Error> = { _ in .finished() }
}

extension DependencyValues {
    public var transactionClient: TransactionClient {
        get { self[TransactionClient.self] }
        set { self[TransactionClient.self] = newValue }
    }
}

extension TransactionClient: TestDependencyKey {
    public static let testValue = Self()
    public static var previewValue: Self { /* 인메모리 */ }
}
```

```swift
// Data/Sources/Live/TransactionClient+Live.swift — 연결만
extension TransactionClient: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.defaultDatabase) var database
        return .live(database: database)
    }

    static func live(database: any DatabaseWriter) -> Self {
        let dao = TransactionDAO(database: database)
        return Self(fetch: dao.fetch, save: dao.save, observe: dao.observe)
    }
}

// Data/Sources/Live/LiveDependencies.swift — App 진입점에서 호출
extension DependencyValues {
    public mutating func bootstrapLive(database: any DatabaseWriter) {
        defaultDatabase = database
        date = .trusted
        transactionClient = .live(database: database)
        categoryClient = .live(database: database)
        fixedExpenseClient = .live(database: database)
        budgetClient = .live(database: database)
        settingsClient = .live(database: database)
        timeSyncClient = .liveValue
        // 새 Client를 여기에 추가
    }
}
```

## 6. Reducer 규칙
- 화면 하나 = `@Reducer struct XxxFeature` + `XxxView`
- `State`: `@ObservableState`, `Equatable`. 화면 렌더링에 필요한 값만 둔다. 파생 값은 computed property로 (`canSave`, `dailyGroups`)
- `State`의 `init`에서 `@Dependency`를 읽지 않는다 — 필요한 값(날짜 등)은 부모가 인자로 넘긴다
- `Action`: `Equatable`. 이름은 다음 규칙을 따른다

| 종류 | 형식 | 예 |
|------|------|----|
| 사용자 행동 | `xxxButtonTapped`, `xxxTapped`, `onAppear` | `saveButtonTapped` |
| 비동기 결과 | `xxxLoaded(...)`, `xxxUpdated(...)`, `xxxFinished`, `xxxFailed(String)` | `summaryLoaded` |
| 부모 알림 | `delegate(Delegate)` | `.delegate(.saved)` |
| 바인딩 | `binding(BindingAction<State>)` + `BindingReducer()` | 폼 입력 |

- `Delegate` 같은 중첩 enum에는 **`@CasePathable`** 을 붙인다 (테스트의 `\.delegate.saved` 키패스에 필요)
- 부모는 자식의 `delegate`만 처리하고, 자식 내부 Action에 반응하지 않는다
- 비동기 작업은 `.run`에서 Client를 호출하고 결과를 Action으로 돌려보낸다
- `.run` 클로저에는 **의존성을 명시 캡처**한다: `.run { [transactionClient] send in ... }` (Swift 6에서 `self` 캡처는 Sendable 오류)
- 에러는 `catch:`에서 `xxxFailed(String)` Action으로 바꾼다. Reducer에서 에러를 삼키지 않는다
- 장기 구독(관찰)은 `enum CancelID`와 `.cancellable(id:cancelInFlight: true)`로 취소 가능하게 한다
- 사용자 확인·오류 표시는 `@Presents var alert: AlertState<Action.Alert>?`로 한다
- 중복 실행 방지(예: `isSaving`) 같은 가드는 Reducer에서 처리한다

```swift
case .saveButtonTapped:
    guard let amount = state.amount, !state.isSaving else { return .none }
    state.isSaving = true
    return .run { [transactionClient] send in
        try await transactionClient.save(transaction: transaction)
        await send(.saveFinished)
    } catch: { error, send in
        await send(.operationFailed(error.localizedDescription))
    }
```

## 7. Store · View 규칙
- View는 `store`의 상태를 읽고 `store.send(_:)`만 호출한다 — View에 비즈니스 로직, 포맷 외 계산, Client 호출 금지
- 바인딩이 필요한 View는 `@Bindable var store`, 아니면 `let store`
- 자식 Store는 `store.scope(state:action:)`로 만든다. View에서 새 `Store`를 만들지 않는다 (`#Preview` 제외)
- `Store`는 App 진입점(`SolSolApp.store`)에서 한 번만 만든다
- `onAppear` 같은 생명주기는 Action으로 보낸다 (`.onAppear { store.send(.onAppear) }`)
- 모든 공개 View에 `#Preview`를 둔다. 프리뷰 Store는 Client의 `previewValue`를 쓴다

## 8. 내비게이션 규칙
- push: 부모의 `StackState<Path.State>` + `@Reducer enum Path`
- 모달(sheet, fullScreenCover, alert, confirmationDialog): `@Presents var destination` + `@Reducer enum Destination`
- 자식은 직접 이동하지 않고 `.delegate(...)`를 보낸다 → 부모가 `path.append` / `destination` 설정·해제
- `NavigationLink(destination:)` 금지 — `NavigationStack(path: $store.scope(state: \.path, action: \.path))` 사용
- `Path.State`, `Destination.State`에 `Equatable`을 extension으로 선언한다
- 딥링크는 `AppFeature`에서 `path`를 조립해 처리한다

## 9. 동시성 · 시간 규칙
- Swift 6 language mode, Strict Concurrency `complete`. 경고를 남기지 않는다
- 레이어 경계를 넘는 모든 모델과 Client는 `Sendable`
- Combine 금지 — `async/await`, `AsyncStream`, `AsyncThrowingStream`
- 인메모리 공유 상태는 `actor` 또는 `LockIsolated`
- **현재 시각은 `@Dependency(\.date)`로만 얻는다** — `Date()`, `Date.now` 금지 (프리뷰 샘플 데이터 제외)
- 새 id는 `@Dependency(\.uuid)`, 대기·타이머는 `@Dependency(\.continuousClock)`
- `\.date`의 live 값은 `bootstrapLive`에서 `DateGenerator.trusted`(Kronos, 미동기화 시 기기 시각)로 설정된다
- NTP 동기화는 `TimeSyncClient.sync()` — `AppFeature`의 `onAppear`와 `scenePhase == .active` 복귀 시 호출
- Kronos의 `Clock`은 Swift `Clock`과 겹치므로 항상 `Kronos.Clock`으로 쓴다
- Kronos continuation은 실패해도 호출되는 `completion:`에서 재개한다 (`first:`는 오프라인 시 호출되지 않아 무한 대기)

## 10. 테스트 규칙
- 모든 모듈에 `Tests/` 타깃이 있다. 프레임워크는 **Swift Testing** (`@Test`, `#expect`). XCTest 신규 작성 금지
- Reducer 테스트 구조체는 `@MainActor`
- **Features**: `TestStore`로 Action → State 변화, 받은 Action, delegate를 **빠짐없이** 검증한다 (exhaustive). `exhaustivity = .off`는 에러 경로처럼 부분 검증이 필요한 경우에만
- 의존성은 `withDependencies`로 **필요한 Client 메서드만** 교체한다. 나머지는 unimplemented로 남겨 의도치 않은 호출을 잡는다
- 고정 값 주입: `$0.date = .constant(...)`, `$0.uuid = .incrementing`
- 호출 인자 확인은 `LockIsolated`에 기록 후 `#expect`
- **Data**: `TestDatabase.make()`(인메모리 `DatabaseQueue` + 전체 마이그레이션)로 DAO를 검증한다. 실제 파일 DB 금지
- **마이그레이션**: 새 마이그레이션마다 이전 버전 데이터가 옮겨지는지 테스트한다 — `makeMigrator().migrate(db, upTo: MigrationID.vN)`으로 이전 버전까지 적용 → 이전 스키마로 데이터 삽입 → `migrate(_:)` → 결과 검증
- DB 제약(CHECK, 외래 키)이 잘못된 값을 거부하는지도 테스트한다
- **Domain**: 순수 함수 단위 테스트. `Calendar`/`TimeZone`을 고정한다 (`Asia/Seoul`)
- **DesignSystem**: 에셋(색상·폰트) 등록 여부를 테스트한다
- **App**: `AppFeature`의 내비게이션 조립(push/pop, sheet 표시/해제)을 테스트한다
- `.skip`, 비어 있는 테스트, 주석 처리된 검증을 남기지 않는다

```swift
@Test func onAppear_observesTransactionsAndLoadsSummary() async {
    let store = TestStore(initialState: HomeFeature.State(month: month)) {
        HomeFeature()
    } withDependencies: {
        $0.transactionClient.observe = { _ in AsyncThrowingStream { $0.yield([sample]); $0.finish() } }
        $0.transactionClient.fetchSummary = { _ in TransactionSummary(income: 0, expense: 12_000) }
    }
    await store.send(.onAppear) { $0.isLoading = true }
    await store.receive(\.transactionsUpdated) { $0.isLoading = false; $0.transactions = [sample] }
    await store.receive(\.summaryLoaded) { $0.summary = TransactionSummary(income: 0, expense: 12_000) }
}
```

## 11. Tuist · 외부 의존성 규칙
- 모든 내부 모듈은 `staticFramework`. 리소스가 있으면 `hasResources: true`
- Swift 설정(`SWIFT_VERSION 6.0`, `SWIFT_STRICT_CONCURRENCY complete`)은 `Module.baseSettings`에서만 바꾼다
- 외부 패키지는 `Tuist/Package.swift`에 추가하고 `ModuleDependency.External`에 case를 추가한다
- 전이 의존성의 모듈을 직접 import하면 명시적으로 의존성을 선언한다 (예: `ValueObservation` → `.external(.grdb)`)
- 버전은 `Package.resolved`로 고정하고 의도적으로만 올린다. Point-Free 라이브러리는 릴리스 노트를 확인한다
- 외부 의존성: `swift-composable-architecture`, `swift-dependencies`, `sqlite-data`(GRDB 포함), `Kronos`
