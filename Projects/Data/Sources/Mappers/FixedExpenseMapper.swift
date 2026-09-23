import Domain

enum FixedExpenseMapper {
    static func toDomain(_ record: FixedExpenseRecord) -> FixedExpense {
        FixedExpense(id: record.id, name: record.name, amount: record.amount, isEnabled: record.isEnabled, sortOrder: record.sortOrder)
    }

    static func toRecord(_ item: FixedExpense) -> FixedExpenseRecord {
        FixedExpenseRecord(id: item.id, name: item.name, amount: item.amount, isEnabled: item.isEnabled, sortOrder: item.sortOrder)
    }
}
