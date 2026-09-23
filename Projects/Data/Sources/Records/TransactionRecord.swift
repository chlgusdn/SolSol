import Foundation
import SQLiteData

/// `transactionRecords` 테이블 레코드. Data 모듈 밖으로 노출하지 않는다.
@Table("transactionRecords")
struct TransactionRecord: Identifiable, Hashable, Sendable {
    let id: UUID
    var type: Kind
    var amount: Int
    var category: String
    var memo: String
    var date: Date

    enum Kind: String, QueryBindable, Sendable {
        case income
        case expense
    }
}
