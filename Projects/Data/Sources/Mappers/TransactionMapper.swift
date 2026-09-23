import Domain
import Foundation

/// TransactionRecord ⇄ Domain.Transaction 변환
enum TransactionMapper {
    static func toDomain(_ record: TransactionRecord) -> Transaction {
        Transaction(
            id: record.id,
            type: TransactionType(rawValue: record.type.rawValue) ?? .expense,
            amount: record.amount,
            category: TransactionCategory(rawValue: record.category) ?? .etc,
            memo: record.memo,
            date: record.date
        )
    }

    static func toRecord(_ transaction: Transaction) -> TransactionRecord {
        TransactionRecord(
            id: transaction.id,
            type: TransactionRecord.Kind(rawValue: transaction.type.rawValue) ?? .expense,
            amount: transaction.amount,
            category: transaction.category.rawValue,
            memo: transaction.memo,
            date: transaction.date
        )
    }
}
