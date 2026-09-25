import Domain
import Foundation

enum BudgetMapper {
    static func toDomain(_ record: BudgetRecord) -> Budget {
        Budget(
            amount: record.amount,
            startDate: record.startDate,
            dueDate: record.dueDate,
            warnAmount: record.warnAmount,
            dangerAmount: record.dangerAmount
        )
    }

    static func toRecord(_ budget: Budget) -> BudgetRecord {
        BudgetRecord(
            id: BudgetRecord.singletonID,
            amount: budget.amount,
            startDate: budget.startDate,
            dueDate: budget.dueDate,
            warnAmount: budget.warnAmount,
            dangerAmount: budget.dangerAmount,
            notifiedStatus: nil
        )
    }

    static func toDomain(_ column: BudgetStatusColumn) -> BudgetStatus {
        switch column {
        case .warning: .warning
        case .danger: .danger
        case .exceeded: .exceeded
        }
    }

    static func toColumn(_ status: BudgetStatus?) -> BudgetStatusColumn? {
        switch status {
        case .warning: .warning
        case .danger: .danger
        case .exceeded: .exceeded
        case .safe, nil: nil
        }
    }

    static func toDomain(_ record: BudgetResultRecord) -> BudgetResult {
        BudgetResult(
            id: record.id,
            amount: record.amount,
            startDate: record.startDate,
            dueDate: record.dueDate,
            spent: record.spent
        )
    }

    static func toRecord(_ result: BudgetResult, closedAt: Date) -> BudgetResultRecord {
        BudgetResultRecord(
            id: result.id,
            amount: result.amount,
            startDate: result.startDate,
            dueDate: result.dueDate,
            spent: result.spent,
            closedAt: closedAt
        )
    }
}
