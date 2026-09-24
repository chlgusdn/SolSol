import Domain
import Foundation
import SQLiteData
import Testing
@testable import Data

struct MigrationTests {
    @Test func v2_seedsDefaultCategoriesMatchingDomain() async throws {
        let dao = CategoryDAO(database: try TestDatabase.make())
        #expect(try await dao.fetchAll().sorted { $0.id.uuidString < $1.id.uuidString }
            == TransactionCategory.Default.all.sorted { $0.id.uuidString < $1.id.uuidString })
    }

    @Test func v1ToV2_movesTransactionsToCategoriesAndTitles() async throws {
        let database = try DatabaseQueue()
        try makeMigrator().migrate(database, upTo: MigrationID.v1)
        try await database.write { db in
            try db.execute(sql: """
                INSERT INTO "transactionRecords" ("id", "type", "amount", "category", "memo", "date") VALUES
                    ('00000000-0000-0000-0000-00000000000a', 'expense', 12000, 'food', '점심', '2026-03-02 03:00:00.000'),
                    ('00000000-0000-0000-0000-00000000000b', 'expense', 3000, 'living', '', '2026-03-03 03:00:00.000'),
                    ('00000000-0000-0000-0000-00000000000c', 'expense', 1000, 'etc', '', '2026-03-04 03:00:00.000'),
                    ('00000000-0000-0000-0000-00000000000d', 'income', 3000000, 'salary', '월급', '2026-03-05 03:00:00.000')
                """)
        }

        try migrate(database)

        let month = DateInterval(start: .distantPast, end: .distantFuture)
        let transactions = try await TransactionDAO(database: database).fetch(month)
        let byID = Dictionary(uniqueKeysWithValues: transactions.map { ($0.id.uuidString.lowercased().suffix(1), $0) })

        #expect(transactions.count == 4)
        #expect(byID["a"]?.category == .Default.food)
        #expect(byID["a"]?.title == "점심")
        #expect(byID["a"]?.memo == "")
        #expect(byID["b"]?.category.name == "생활")
        #expect(byID["b"]?.title == "지출")
        #expect(byID["c"]?.category.name == "기타")
        #expect(byID["d"]?.category == .Default.income)
        #expect(byID["d"]?.title == "월급")
        #expect(transactions.allSatisfy { !$0.isFixed })

        // 쓰이지 않은 v1 카테고리(health)는 만들지 않는다
        let categories = try await CategoryDAO(database: database).fetchAll()
        #expect(!categories.contains { $0.name == "의료/건강" })
    }
}
