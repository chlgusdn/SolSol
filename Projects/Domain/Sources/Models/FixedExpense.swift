import Foundation

/// 매월 반복되는 고정 지출. `isEnabled`인 항목만 자동 등록 대상이다
public struct FixedExpense: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var amount: Int
    public var isEnabled: Bool
    public var sortOrder: Int

    public init(id: UUID, name: String, amount: Int, isEnabled: Bool = true, sortOrder: Int) {
        self.id = id
        self.name = name
        self.amount = amount
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
    }
}

extension Collection where Element == FixedExpense {
    /// 체크된(자동 등록 대상) 항목의 합계
    public var enabledTotal: Int {
        filter(\.isEnabled).reduce(0) { $0 + $1.amount }
    }

    public var enabledCount: Int {
        filter(\.isEnabled).count
    }
}
