import Foundation
import SQLiteData

@Table("budgetResults")
struct BudgetResultRecord: Identifiable, Hashable, Sendable {
    let id: UUID
    var amount: Int
    var startDate: Date
    var dueDate: Date
    var spent: Int
    var closedAt: Date
}
