import Foundation

/// 수입/지출 거래 한 건
public struct Transaction: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var type: TransactionType
    /// 금액 (원 단위, 항상 0 이상)
    public var amount: Int
    public var category: TransactionCategory
    public var memo: String
    public var date: Date

    public init(
        id: UUID,
        type: TransactionType,
        amount: Int,
        category: TransactionCategory,
        memo: String = "",
        date: Date
    ) {
        self.id = id
        self.type = type
        self.amount = amount
        self.category = category
        self.memo = memo
        self.date = date
    }

    /// 수입은 +, 지출은 - 부호를 가진 금액
    public var signedAmount: Int {
        switch type {
        case .income: amount
        case .expense: -amount
        }
    }
}
