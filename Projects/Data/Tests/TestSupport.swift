import Foundation
import SQLiteData
@testable import Data

enum TestDatabase {
    /// 전체 마이그레이션이 적용된 인메모리 DB
    static func make() throws -> DatabaseQueue {
        let database = try DatabaseQueue()
        try migrate(database)
        return database
    }
}

enum TestCalendar {
    static let seoul: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }()
}
