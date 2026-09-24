import Foundation

/// 통계 화면이 DB에서 받는 집계 결과
public struct StatisticsSnapshot: Equatable, Sendable {
    /// 요청한 칸 순서대로의 수입·지출 합계
    public var bucketTotals: [TransactionSummary]
    /// 카테고리별 지출 합계·횟수
    public var categoryTotals: [CategoryTotal]
    public var largestIncome: Transaction?
    public var largestExpense: Transaction?
    /// 기간 안 거래 수 (0이면 빈 상태)
    public var transactionCount: Int

    public init(
        bucketTotals: [TransactionSummary] = [],
        categoryTotals: [CategoryTotal] = [],
        largestIncome: Transaction? = nil,
        largestExpense: Transaction? = nil,
        transactionCount: Int = 0
    ) {
        self.bucketTotals = bucketTotals
        self.categoryTotals = categoryTotals
        self.largestIncome = largestIncome
        self.largestExpense = largestExpense
        self.transactionCount = transactionCount
    }

    public static let empty = StatisticsSnapshot()
}

/// 카테고리 하나의 지출 합계·횟수
public struct CategoryTotal: Equatable, Sendable {
    public var category: TransactionCategory
    public var amount: Int
    public var count: Int

    public init(category: TransactionCategory, amount: Int, count: Int) {
        self.category = category
        self.amount = amount
        self.count = count
    }
}
