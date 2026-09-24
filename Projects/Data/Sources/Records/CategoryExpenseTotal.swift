import SQLiteData

/// 카테고리별 지출 집계 결과 (GROUP BY)
@Selection
struct CategoryExpenseTotal: Sendable {
    let category: CategoryRecord
    let amount: Int
    let count: Int
}
