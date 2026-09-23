import Domain
import Foundation
import GRDB
import SQLiteData

/// 거래 DB 접근 실제 구현
struct TransactionDAO: Sendable {
    let database: any DatabaseWriter

    func fetchMonth(_ month: DateInterval) async throws -> [Transaction] {
        try await database.read { db in
            try Self.fetch(month, in: db)
        }
    }

    func fetchSummary(_ month: DateInterval) async throws -> TransactionSummary {
        try await database.read { db in
            let row = try TransactionRecord
                .where { $0.date >= month.start && $0.date < month.end }
                .select {
                    (
                        $0.amount.sum(filter: $0.type.eq(TransactionRecord.Kind.income)) ?? 0,
                        $0.amount.sum(filter: $0.type.eq(TransactionRecord.Kind.expense)) ?? 0
                    )
                }
                .fetchOne(db)
            return TransactionSummary(income: row?.0 ?? 0, expense: row?.1 ?? 0)
        }
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

    func observeMonth(_ month: DateInterval) -> AsyncThrowingStream<[Transaction], any Error> {
        let observation = ValueObservation.tracking { db in
            try Self.fetch(month, in: db)
        }
        let database = database
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await transactions in observation.values(in: database) {
                        continuation.yield(transactions)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func fetch(_ month: DateInterval, in db: Database) throws -> [Transaction] {
        try TransactionRecord
            .where { $0.date >= month.start && $0.date < month.end }
            .order { $0.date.desc() }
            .fetchAll(db)
            .map(TransactionMapper.toDomain)
    }
}
