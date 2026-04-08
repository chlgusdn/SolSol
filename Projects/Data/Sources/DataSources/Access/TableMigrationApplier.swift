//
//  TableMigrationApplier.swift
//  SolSol
//
//  Created by NUNU:D on 6/4/25.
//

import Foundation
import GRDB

public struct TableMigrationApplier {

    public enum Step: String, CaseIterable {
        case createUser
        case createBudget
        case createTransaction
        case createCategory
        case createNotification

        func apply(to database: Database, migrator: TableVersionMigratoralbe) throws {
            switch self {
            case .createUser:               return try migrator.createUserTable(in: database)
            case .createBudget:             return try migrator.createBudgetTable(in: database)
            case .createTransaction:        return try migrator.createTransactionTable(in: database)
            case .createCategory:           return try migrator.createCategoryTable(in: database)
            case .createNotification:       return try migrator.createNotificationTable(in: database)
            }
        }
    }

    static func applyAll(to migrator: inout DatabaseMigrator, from tableMigrationVersion: TableVersionMigratoralbe) {
        migrator.registerMigration(tableMigrationVersion.migraionVersion) { database in

            for step in Step.allCases {
                try step.apply(to: database, migrator: tableMigrationVersion)
            }

        }

    }

}
