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
            try! UserLocalDataSourceRepositoryImpl(accessor: Container.shared.sqlAccessor())
        }

        Container.shared.budgetDataSource.register {
            try! BudgetDataSourceRepositoryImpl(accessor: Container.shared.sqlAccessor())
        }

        Container.shared.transactionDataSource.register {
            try! TransactionDataSourceRepositoryImpl(accessor: Container.shared.sqlAccessor())
        }

        Container.shared.notificationDataSource.register {
            try! NotificationDataSourceRepositroyImpl(accessor: Container.shared.sqlAccessor())
        }
    }
}

public extension Container {
    var sqlAccessor: Factory<SQLAccessor> { self { fatalError("SQLAccessor is not initialized") }.singleton }
    var userDataSource: Factory<UserLocalDataSourceRepository> { self { fatalError("User data source is not registered") } }
    var budgetDataSource: Factory<BudgetLocalDataSourceRepository> { self { fatalError("Budget data source is not registered") } }
    var transactionDataSource: Factory<TransactionLocalDataSourceRepository> { self { fatalError("Transaction data source is not registered") } }
    var notificationDataSource: Factory<NotificationLocalDataSourceRepository> { self { fatalError("Notification data source is not registered") } }
}
