import Clients
import Dependencies
import SQLiteData

extension StatisticsClient: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.defaultDatabase) var database
        return .live(database: database)
    }

    static func live(database: any DatabaseWriter) -> Self {
        let dao = StatisticsDAO(database: database)
        return Self(observe: dao.observe)
    }
}
