import Clients
import Dependencies
import SQLiteData

extension TransactionClient: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.defaultDatabase) var database
        return .live(database: database)
    }

    static func live(database: any DatabaseWriter) -> Self {
        let dao = TransactionDAO(database: database)
        return Self(
            fetchMonth: dao.fetchMonth,
            fetchSummary: dao.fetchSummary,
            save: dao.save,
            delete: dao.delete,
            observeMonth: dao.observeMonth
        )
    }
}
