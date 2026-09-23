import Domain

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
            dangerAmount: budget.dangerAmount
        )
    }
}
