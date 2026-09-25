import Foundation

/// 끝난 예산의 결과 — 다음 예산을 정할 때 보여준다
public struct BudgetResult: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var amount: Int
    public var startDate: Date
    public var dueDate: Date
    public var spent: Int

    public init(id: UUID, amount: Int, startDate: Date, dueDate: Date, spent: Int) {
        self.id = id
        self.amount = amount
        self.startDate = startDate
        self.dueDate = dueDate
        self.spent = spent
    }

    public var isExceeded: Bool { spent > amount }
    /// 넘은 금액 (지켰으면 0)
    public var overAmount: Int { max(0, spent - amount) }

    /// 예산 대비 더 쓴(+) / 아낀(-) 비율 %
    public var differencePercent: Int {
        Budget.differencePercent(spent: spent, amount: amount)
    }

    public var usageRatio: Double {
        guard amount > 0 else { return 0 }
        return Double(spent) / Double(amount)
    }
}
