import Domain
import Foundation
import SQLiteData

struct BudgetDAO: Sendable {
    let database: any DatabaseWriter

    func fetch() async throws -> Budget? {
        try await database.read { db in try Self.fetch(in: db) }
    }

    /// 저장하면 이미 알린 단계도 초기화된다 (금액·기간이 바뀌면 다시 알려야 하므로)
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

    func notifiedStatus() async throws -> BudgetStatus? {
        try await database.read { db in
            try BudgetRecord
                .where { $0.id.eq(BudgetRecord.singletonID) }
                .select(\.notifiedStatus)
                .fetchOne(db)?
                .map(BudgetMapper.toDomain)
        }
    }

    /// 이미 알린 단계보다 심각할 때만 기록하고 true — 읽기·비교·기록을 한 트랜잭션에서 해 동시에 불려도 한 번만 true
    func raiseNotifiedStatus(_ status: BudgetStatus) async throws -> Bool {
        try await database.write { db in
            guard let record = try BudgetRecord.where({ $0.id.eq(BudgetRecord.singletonID) }).fetchOne(db) else {
                return false
            }
            guard status.newAlert(since: record.notifiedStatus.map(BudgetMapper.toDomain)) != nil else { return false }
            let column = BudgetMapper.toColumn(status)
            try BudgetRecord
                .where { $0.id.eq(BudgetRecord.singletonID) }
                .update { $0.notifiedStatus = column }
                .execute(db)
            return true
        }
    }

    /// 끝난 예산의 결과를 기록하고, 새 예산으로 바꾸거나(nil이면) 지운다 — 한 트랜잭션
    func close(_ result: BudgetResult, closedAt: Date, replacingWith budget: Budget?) async throws {
        let resultRecord = BudgetMapper.toRecord(result, closedAt: closedAt)
        let budgetRecord = budget.map(BudgetMapper.toRecord)
        try await database.write { db in
            try BudgetResultRecord.insert { resultRecord }.execute(db)
            if let budgetRecord {
                try BudgetRecord.upsert { budgetRecord }.execute(db)
            } else {
                try BudgetRecord.delete().execute(db)
            }
        }
    }

    func latestResult() async throws -> BudgetResult? {
        try await database.read { db in
            try BudgetResultRecord
                .order { $0.closedAt.desc() }
                .limit(1)
                .fetchOne(db)
                .map(BudgetMapper.toDomain)
        }
    }

    private static func fetch(in db: Database) throws -> Budget? {
        try BudgetRecord
            .where { $0.id.eq(BudgetRecord.singletonID) }
            .fetchOne(db)
            .map(BudgetMapper.toDomain)
    }
}
