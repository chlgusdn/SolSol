import Domain
import Foundation
import SQLiteData

struct BudgetDAO: Sendable {
    let database: any DatabaseWriter

    func fetch() async throws -> Budget? {
        try await database.read { db in try Self.fetch(in: db) }
    }

    func save(_ budget: Budget) async throws {
        let record = BudgetMapper.toRecord(budget)
        try await database.write { db in
            try BudgetRecord.upsert { record }.execute(db)
        }
    }

    func clear() async throws {
        try await database.write { db in
            try BudgetRecord.delete().execute(db)
        }
    }

    func observe() -> AsyncThrowingStream<Budget?, any Error> {
        observeDatabase(database) { db in try Self.fetch(in: db) }
    }

    private static func fetch(in db: Database) throws -> Budget? {
        try BudgetRecord
            .where { $0.id.eq(BudgetRecord.singletonID) }
            .fetchOne(db)
            .map(BudgetMapper.toDomain)
    }
}
