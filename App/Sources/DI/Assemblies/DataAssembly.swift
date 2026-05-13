//
//  DataSourceDIContainers.swift
//  SolSol
//
//  Created by NUNU:D on 8/16/25.
//

import Foundation
import Factory
import Data

enum DataAssembly {
    static func initializeSQLAccess() async {

        let sqlAccessor = await SQLAccessor()

        Container.shared.sqlAccessor.register {
            return sqlAccessor
        }
        .scope(.singleton)
    }

    static func register() {

        Container.shared.userDataSource.register {
            do {
                return try UserLocalDataSourceRepositoryImpl(accessor: Container.shared.sqlAccessor())
            } catch {
                fatalError("UserLocalDataSourceRepositoryImpl 초기화 실패: \(error)")
            }
        }

        Container.shared.budgetDataSource.register {
            do {
                return try BudgetDataSourceRepositoryImpl(accessor: Container.shared.sqlAccessor())
            } catch {
                fatalError("BudgetDataSourceRepositoryImpl 초기화 실패: \(error)")
            }
        }

        Container.shared.transactionDataSource.register {
            do {
                return try TransactionDataSourceRepositoryImpl(accessor: Container.shared.sqlAccessor())
            } catch {
                fatalError("TransactionDataSourceRepositoryImpl 초기화 실패: \(error)")
            }
        }

        Container.shared.notificationDataSource.register {
            do {
                return try NotificationDataSourceRepositroyImpl(accessor: Container.shared.sqlAccessor())
            } catch {
                fatalError("NotificationDataSourceRepositroyImpl 초기화 실패: \(error)")
            }
        }
    }
}

public extension Container {
    var sqlAccessor: Factory<SQLAccessor> {
        self { fatalError("SQLAccessor is not initialized") }.singleton
    }

    var userDataSource: Factory<UserLocalDataSourceRepository> {
        self { fatalError("User data source is not registered") }
    }

    var budgetDataSource: Factory<BudgetLocalDataSourceRepository> {
        self { fatalError("Budget data source is not registered") }
    }

    var transactionDataSource: Factory<TransactionLocalDataSourceRepository> {
        self { fatalError("Transaction data source is not registered") }
    }

    var notificationDataSource: Factory<NotificationLocalDataSourceRepository> {
        self { fatalError("Notification data source is not registered") }
    }
}
