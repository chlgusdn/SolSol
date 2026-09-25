import Foundation
import SQLiteData

/// 예산은 하나만 존재한다 (`id` = 1)
@Table("budgetRecords")
struct BudgetRecord: Identifiable, Hashable, Sendable {
    static let singletonID = 1

    let id: Int
    var amount: Int
    var startDate: Date
    var dueDate: Date
    var warnAmount: Int
    var dangerAmount: Int
    /// 이미 알린 단계. 예산을 저장하면 nil로 돌아간다
    var notifiedStatus: BudgetStatusColumn?
}

enum BudgetStatusColumn: String, QueryBindable, Sendable {
    case warning
    case danger
    case exceeded
}
