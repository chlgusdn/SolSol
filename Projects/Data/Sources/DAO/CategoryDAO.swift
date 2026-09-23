import Domain
import Foundation
import SQLiteData

struct CategoryDAO: Sendable {
    let database: any DatabaseWriter

    func fetchAll() async throws -> [TransactionCategory] {
        try await database.read { db in try Self.fetchAll(in: db) }
    }

    /// 같은 유형의 맨 뒤 정렬 순서로 추가한다
    func add(_ category: TransactionCategory) async throws {
        let base = CategoryMapper.toRecord(category)
        try await database.write { db in
            var record = base
            let last = try CategoryRecord
                .where { $0.type.eq(record.type) }
                .select { $0.sortOrder.max() }
                .fetchOne(db) ?? nil
            record.sortOrder = (last ?? 0) + 1
            try CategoryRecord.insert { record }.execute(db)
        }
    }

    func observeAll() -> AsyncThrowingStream<[TransactionCategory], any Error> {
        observeDatabase(database) { db in try Self.fetchAll(in: db) }
    }

    private static func fetchAll(in db: Database) throws -> [TransactionCategory] {
        try CategoryRecord
            .order { ($0.type, $0.sortOrder) }
            .fetchAll(db)
            .map(CategoryMapper.toDomain)
    }
}
