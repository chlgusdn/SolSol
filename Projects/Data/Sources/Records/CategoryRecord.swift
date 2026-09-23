import Foundation
import SQLiteData

@Table("categoryRecords")
struct CategoryRecord: Identifiable, Hashable, Sendable {
    let id: UUID
    var type: TransactionTypeColumn
    var name: String
    var colorKey: String
    var iconKey: String
    var isDefault: Bool
    var sortOrder: Int
}
