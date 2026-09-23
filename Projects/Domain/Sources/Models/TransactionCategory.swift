import Foundation

/// 거래 카테고리
public enum TransactionCategory: String, CaseIterable, Codable, Hashable, Sendable {
    // 지출
    case food
    case transport
    case shopping
    case living
    case culture
    case health
    // 수입
    case salary
    case allowance
    case bonus
    // 공통
    case etc

    /// 해당 거래 유형에서 선택 가능한 카테고리
    public static func available(for type: TransactionType) -> [TransactionCategory] {
        switch type {
        case .expense: [.food, .transport, .shopping, .living, .culture, .health, .etc]
        case .income: [.salary, .allowance, .bonus, .etc]
        }
    }
}

extension TransactionCategory {
    public var displayName: String {
        switch self {
        case .food: "식비"
        case .transport: "교통"
        case .shopping: "쇼핑"
        case .living: "생활"
        case .culture: "문화"
        case .health: "의료/건강"
        case .salary: "월급"
        case .allowance: "용돈"
        case .bonus: "상여"
        case .etc: "기타"
        }
    }
}
