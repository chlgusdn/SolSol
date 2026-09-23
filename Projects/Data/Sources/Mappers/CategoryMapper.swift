import Domain

enum CategoryMapper {
    static func toDomain(_ record: CategoryRecord) -> TransactionCategory {
        TransactionCategory(
            id: record.id,
            type: TransactionTypeMapper.toDomain(record.type),
            name: record.name,
            colorKey: record.colorKey,
            iconKey: record.iconKey,
            isDefault: record.isDefault,
            sortOrder: record.sortOrder
        )
    }

    static func toRecord(_ category: TransactionCategory) -> CategoryRecord {
        CategoryRecord(
            id: category.id,
            type: TransactionTypeMapper.toRecord(category.type),
            name: category.name,
            colorKey: category.colorKey,
            iconKey: category.iconKey,
            isDefault: category.isDefault,
            sortOrder: category.sortOrder
        )
    }
}
