import Foundation

/// 수입/지출 거래 한 건
public struct Transaction: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var type: TransactionType
    /// 금액 (원 단위, 항상 0 이상. 부호는 `type`이 결정)
    public var amount: Int
    public var category: TransactionCategory
    public var title: String
    public var memo: String
    public var date: Date
    /// 고정 지출로 등록된 거래
    public var isFixed: Bool

    public init(
        id: UUID,
        type: TransactionType,
        amount: Int,
        category: TransactionCategory,
        title: String,
        memo: String = "",
        date: Date,
        isFixed: Bool = false
    ) {
        self.id = id
        self.type = type
        self.amount = amount
        self.category = category
        self.title = title
        self.memo = memo
        self.date = date
        self.isFixed = isFixed
    }

    /// 입력 가능한 최대 금액
    public static let maxAmount = 1_000_000_000
    /// 메모 최대 글자 수
    public static let memoLimit = 200

    /// 제목을 비워 두면 쓰는 기본 제목
    public static func defaultTitle(for type: TransactionType) -> String {
        switch type {
        case .income: "수익"
        case .expense: "지출"
        }
    }

    /// 수입은 +, 지출은 - 부호를 가진 금액
    public var signedAmount: Int {
        switch type {
        case .income: amount
        case .expense: -amount
        }
    }
}
