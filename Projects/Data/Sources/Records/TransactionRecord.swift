import Foundation
import SQLiteData

/// `transactionRecords` 테이블 레코드. Data 모듈 밖으로 노출하지 않는다.
@Table("transactionRecords")
struct TransactionRecord: Identifiable, Hashable, Sendable {
    let id: UUID
    var type: TransactionTypeColumn
    var amount: Int
    var categoryID: UUID
    var title: String
    var memo: String
    var date: Date
    var isFixed: Bool
}

/// 거래 유형 컬럼 값
enum TransactionTypeColumn: String, QueryBindable, Sendable {
    case income
    case expense
}
