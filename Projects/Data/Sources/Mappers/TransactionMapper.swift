import Domain
import Foundation

/// TransactionRecord ⇄ Domain.Transaction 변환
enum TransactionMapper {
    static func toDomain(_ record: TransactionRecord, category: CategoryRecord) -> Transaction {
        Transaction(
            id: record.id,
            type: TransactionTypeMapper.toDomain(record.type),
            amount: record.amount,
            category: CategoryMapper.toDomain(category),
            title: record.title,
            memo: record.memo,
            date: record.date,
            isFixed: record.isFixed
        )
    }

    static func toRecord(_ transaction: Transaction) -> TransactionRecord {
        TransactionRecord(
            id: transaction.id,
            type: TransactionTypeMapper.toRecord(transaction.type),
            amount: transaction.amount,
            categoryID: transaction.category.id,
            title: transaction.title,
            memo: transaction.memo,
            date: transaction.date,
            isFixed: transaction.isFixed
        )
    }
}

enum TransactionTypeMapper {
    static func toDomain(_ column: TransactionTypeColumn) -> TransactionType {
        switch column {
        case .income: .income
        case .expense: .expense
        }
    }

    static func toRecord(_ type: TransactionType) -> TransactionTypeColumn {
        switch type {
        case .income: .income
        case .expense: .expense
        }
    }
}
