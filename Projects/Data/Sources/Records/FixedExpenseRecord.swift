import Foundation
import SQLiteData

@Table("fixedExpenseRecords")
struct FixedExpenseRecord: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var amount: Int
    var isEnabled: Bool
    var sortOrder: Int
}
