import Clients
import Dependencies
import SQLiteData

extension DependencyValues {
    /// App 진입점에서 한 번 호출해 모든 live 의존성을 연결한다.
    ///
    /// Data는 staticFramework라서 App이 직접 참조하지 않는 `XxxClient+Live.swift` 오브젝트는
    /// 링커가 제거하고, 그러면 `DependencyKey` 적합성도 사라져 `testValue`(unimplemented)가 쓰인다.
    /// 여기서 live 구현을 명시적으로 참조해 링크를 보장한다. 새 Client를 추가하면 여기에도 추가한다.
    public mutating func bootstrapLive(database: any DatabaseWriter) {
        defaultDatabase = database
        date = .trusted  // Kronos 기반 신뢰 시간
        transactionClient = .live(database: database)
        timeSyncClient = .liveValue
    }
}
