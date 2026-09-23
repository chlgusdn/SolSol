import Clients
import Dependencies
import SQLiteData

extension BudgetClient: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.defaultDatabase) var database
        return .live(database: database)
    }

    static func live(database: any DatabaseWriter) -> Self {
        let dao = BudgetDAO(database: database)
        return Self(
            fetch: dao.fetch,
            save: dao.save,
            clear: dao.clear,
            observe: dao.observe
        )
    }
}
