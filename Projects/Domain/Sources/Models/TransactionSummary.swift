import Foundation

/// 기간별 수입/지출 합계
public struct TransactionSummary: Hashable, Sendable {
    public var income: Int
    public var expense: Int

    public init(income: Int = 0, expense: Int = 0) {
        self.income = income
        self.expense = expense
    }

    public var balance: Int { income - expense }

    public static let zero = TransactionSummary()
}
