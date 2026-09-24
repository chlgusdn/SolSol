import Domain
import Foundation
import SQLiteData

/// 통계 집계 — 합계·그룹화·최댓값을 SQL로 계산해 거래 목록을 메모리로 옮기지 않는다
struct StatisticsDAO: Sendable {
    let database: any DatabaseWriter

    func observe(_ period: DateInterval, _ buckets: [DateInterval]) -> AsyncThrowingStream<StatisticsSnapshot, any Error> {
        observeDatabase(database) { db in try Self.snapshot(period, buckets, in: db) }
    }

    static func snapshot(_ period: DateInterval, _ buckets: [DateInterval], in db: Database) throws -> StatisticsSnapshot {
        StatisticsSnapshot(
            bucketTotals: try buckets.map { try TransactionDAO.summary($0, in: db) },
            categoryTotals: try categoryTotals(period, in: db),
            largestIncome: try largest(.income, period, in: db),
            largestExpense: try largest(.expense, period, in: db),
            transactionCount: try TransactionRecord
                .where { $0.date >= period.start && $0.date < period.end }
                .count()
                .fetchOne(db) ?? 0
        )
    }

    private static func categoryTotals(_ period: DateInterval, in db: Database) throws -> [CategoryTotal] {
        try TransactionRecord
            .join(CategoryRecord.all) { $0.categoryID.eq($1.id) }
            .where { transaction, _ in
                transaction.type.eq(TransactionTypeColumn.expense)
                    && transaction.date >= period.start && transaction.date < period.end
            }
            .group { _, category in category.id }
            .select { transaction, category in
                CategoryExpenseTotal.Columns(
                    category: category,
                    amount: transaction.amount.sum() ?? 0,
                    count: transaction.id.count()
                )
            }
            .fetchAll(db)
            .map { CategoryTotal(category: CategoryMapper.toDomain($0.category), amount: $0.amount, count: $0.count) }
    }

    private static func largest(_ type: TransactionType, _ period: DateInterval, in db: Database) throws -> Transaction? {
        let column = TransactionTypeMapper.toRecord(type)
        return try TransactionRecord
            .join(CategoryRecord.all) { $0.categoryID.eq($1.id) }
            .where { transaction, _ in
                transaction.type.eq(column) && transaction.date >= period.start && transaction.date < period.end
            }
            .order { transaction, _ in (transaction.amount.desc(), transaction.date.desc()) }
            .limit(1)
            .select { TransactionWithCategory.Columns(transaction: $0, category: $1) }
            .fetchOne(db)
            .map { TransactionMapper.toDomain($0.transaction, category: $0.category) }
    }
}
