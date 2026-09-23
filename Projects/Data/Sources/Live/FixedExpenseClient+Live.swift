import Clients
import Dependencies
import SQLiteData

extension FixedExpenseClient: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.defaultDatabase) var database
        return .live(database: database)
    }

    static func live(database: any DatabaseWriter) -> Self {
        let dao = FixedExpenseDAO(database: database)
        return Self(
            fetchAll: dao.fetchAll,
            save: dao.save,
            setEnabled: dao.setEnabled,
            delete: dao.delete,
            observeAll: dao.observeAll
        )
    }
}
