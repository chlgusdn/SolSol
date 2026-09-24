import Domain
import Foundation
import SQLiteData

/// 거래 DB 접근 실제 구현
struct TransactionDAO: Sendable {
    let database: any DatabaseWriter

    func fetch(_ interval: DateInterval) async throws -> [Transaction] {
        try await database.read { db in
            try Self.fetch(interval, in: db)
        }
    }

    func fetchSummary(_ interval: DateInterval) async throws -> TransactionSummary {
        try await database.read { db in
            try Self.summary(interval, in: db)
        }
    }

    /// 구간 [start, end)의 수입·지출 합계 (SQL SUM)
    static func summary(_ interval: DateInterval, in db: Database) throws -> TransactionSummary {
        let row = try TransactionRecord
            .where { $0.date >= interval.start && $0.date < interval.end }
            .select {
                (
                    $0.amount.sum(filter: $0.type.eq(TransactionTypeColumn.income)) ?? 0,
                    $0.amount.sum(filter: $0.type.eq(TransactionTypeColumn.expense)) ?? 0
                )
            }
            .fetchOne(db)
        return TransactionSummary(income: row?.0 ?? 0, expense: row?.1 ?? 0)
    }

    func save(_ transaction: Transaction) async throws {
        let record = TransactionMapper.toRecord(transaction)
        try await database.write { db in
            try TransactionRecord.upsert { record }.execute(db)
        }
    }

    func delete(_ id: Transaction.ID) async throws {
        try await database.write { db in
            try TransactionRecord.where { $0.id.eq(id) }.delete().execute(db)
        }
    }

    func observe(_ interval: DateInterval) -> AsyncThrowingStream<[Transaction], any Error> {
        observeDatabase(database) { db in try Self.fetch(interval, in: db) }
    }

    private static func fetch(_ interval: DateInterval, in db: Database) throws -> [Transaction] {
        let rows = try TransactionRecord
            .join(CategoryRecord.all) { $0.categoryID.eq($1.id) }
            .where { transaction, _ in transaction.date >= interval.start && transaction.date < interval.end }
            .order { transaction, _ in transaction.date.desc() }
            .select { TransactionWithCategory.Columns(transaction: $0, category: $1) }
            .fetchAll(db)
        return rows.map { TransactionMapper.toDomain($0.transaction, category: $0.category) }
    }
}
