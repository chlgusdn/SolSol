import Domain
import Foundation
import SQLiteData

struct FixedExpenseDAO: Sendable {
    let database: any DatabaseWriter

    func fetchAll() async throws -> [FixedExpense] {
        try await database.read { db in try Self.fetchAll(in: db) }
    }

    /// 같은 id가 있으면 수정, 없으면 맨 뒤 정렬 순서로 추가한다
    func save(_ item: FixedExpense) async throws {
        let base = FixedExpenseMapper.toRecord(item)
        try await database.write { db in
            var record = base
            let exists = try FixedExpenseRecord.where { $0.id.eq(record.id) }.fetchCount(db) > 0
            if exists {
                try FixedExpenseRecord.upsert { record }.execute(db)
            } else {
                let last = try FixedExpenseRecord.select { $0.sortOrder.max() }.fetchOne(db) ?? nil
                record.sortOrder = (last ?? -1) + 1
                try FixedExpenseRecord.insert { record }.execute(db)
            }
        }
    }

    func setEnabled(_ id: FixedExpense.ID, _ isEnabled: Bool) async throws {
        try await database.write { db in
            try FixedExpenseRecord
                .where { $0.id.eq(id) }
                .update { $0.isEnabled = isEnabled }
                .execute(db)
        }
    }

    func delete(_ id: FixedExpense.ID) async throws {
        try await database.write { db in
            try FixedExpenseRecord.where { $0.id.eq(id) }.delete().execute(db)
        }
    }

    func observeAll() -> AsyncThrowingStream<[FixedExpense], any Error> {
        observeDatabase(database) { db in try Self.fetchAll(in: db) }
    }

    private static func fetchAll(in db: Database) throws -> [FixedExpense] {
        try FixedExpenseRecord
            .order(by: \.sortOrder)
            .fetchAll(db)
            .map(FixedExpenseMapper.toDomain)
    }
}
