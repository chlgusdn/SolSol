import Clients
import Dependencies
import SQLiteData

extension CategoryClient: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.defaultDatabase) var database
        return .live(database: database)
    }

    static func live(database: any DatabaseWriter) -> Self {
        let dao = CategoryDAO(database: database)
        return Self(
            fetchAll: dao.fetchAll,
            add: dao.add,
            observeAll: dao.observeAll
        )
    }
}
