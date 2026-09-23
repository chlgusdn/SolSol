import Foundation

/// 거래 유형
public enum TransactionType: String, CaseIterable, Codable, Hashable, Sendable {
    case income
    case expense
}

extension TransactionType {
    public var displayName: String {
        switch self {
        case .income: "수입"
        case .expense: "지출"
        }
    }
}
