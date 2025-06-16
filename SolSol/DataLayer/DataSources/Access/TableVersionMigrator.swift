//
//  TableVersionMigrator.swift
//  SolSol
//
//  Created by NUNU:D on 6/4/25.
//

import Foundation
import GRDB

public protocol TableVersionMigratoralbe {
    var migraionVersion: String { get }
    
    func createUserTable(in database: Database) throws
    func createBudgetTable(in database: Database) throws
    func createTransactionTable(in database: Database) throws
    func createCategoryTable(in database: Database) throws
    func createNotificationTable(in database: Database) throws
}

public struct TableMigratorV1: TableVersionMigratoralbe {
    
    public var migraionVersion: String {
        return "V1"
    }
    
    public func createUserTable(in database: GRDB.Database) throws {
        try database.create(table: UserEntity.databaseTableName, ifNotExists: true) { table in
            table.autoIncrementedPrimaryKey(UserEntity.Columns.id.rawValue)
            table.column(UserEntity.Columns.createdAt.rawValue, .double).notNull()
        }
    }
    
    public func createBudgetTable(in database: GRDB.Database) throws {
        try database.create(table: BudgetEntity.databaseTableName, ifNotExists: true) { table in
            table.autoIncrementedPrimaryKey(BudgetEntity.Columns.id.rawValue)
            table.column(BudgetEntity.Columns.userId.rawValue, .text).notNull()
            table.column(BudgetEntity.Columns.budgetName.rawValue, .text).notNull()
            table.column(BudgetEntity.Columns.startedAt.rawValue, .double).notNull()
            table.column(BudgetEntity.Columns.finishedAt.rawValue, .double).notNull()
            table.column(BudgetEntity.Columns.createdAt.rawValue, .double).notNull()
            table.column(BudgetEntity.Columns.updatedAt.rawValue, .double).notNull()
            table.column(BudgetEntity.Columns.initalizeAmount.rawValue, .double).notNull()
            table.column(BudgetEntity.Columns.currentAmount.rawValue, .double).notNull()
        }
    }
    
    public func createTransactionTable(in database: GRDB.Database) throws {
        try database.create(table: TransactionEntity.databaseTableName, ifNotExists: true) { table in
            table.autoIncrementedPrimaryKey(TransactionEntity.Columns.id.rawValue)
            table.column(TransactionEntity.Columns.userId.rawValue, .text).notNull()
            table.column(TransactionEntity.Columns.categoryId.rawValue, .integer).notNull()
            table.column(TransactionEntity.Columns.amount.rawValue, .double).notNull()
            table.column(TransactionEntity.Columns.createdAt.rawValue, .double).notNull()
        }
    }
    
    public func createCategoryTable(in database: GRDB.Database) throws {
        try database.create(table: CategoryEntitiy.databaseTableName, ifNotExists: true) { table in
            table.autoIncrementedPrimaryKey(CategoryEntitiy.Columns.id.rawValue)
            table.column(CategoryEntitiy.Columns.categoryName.rawValue, .text).notNull()
            table.column(CategoryEntitiy.Columns.categoryType.rawValue, .integer).notNull()
        }
    }
    
    public func createNotificationTable(in database: GRDB.Database) throws {
        try database.create(table: NotificationEntity.databaseTableName, ifNotExists: true) { table in
            table.autoIncrementedPrimaryKey(NotificationEntity.Columns.id.rawValue)
            table.column(NotificationEntity.Columns.userId.rawValue, .text).notNull()
            table.column(NotificationEntity.Columns.budgetId.rawValue, .integer)
            table.column(NotificationEntity.Columns.notificationType.rawValue, .integer).notNull()
            table.column(NotificationEntity.Columns.settingNotifiactionAmount.rawValue, .double).notNull()
            table.column(NotificationEntity.Columns.isActive.rawValue, .boolean).notNull()
            table.column(NotificationEntity.Columns.updatedAt.rawValue, .double).notNull()
            table.column(NotificationEntity.Columns.createdAt.rawValue, .double).notNull()
        }
    }
}
