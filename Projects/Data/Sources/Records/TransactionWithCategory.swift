import SQLiteData

/// 거래 + 카테고리 조인 결과
@Selection
struct TransactionWithCategory: Sendable {
    let transaction: TransactionRecord
    let category: CategoryRecord
}
