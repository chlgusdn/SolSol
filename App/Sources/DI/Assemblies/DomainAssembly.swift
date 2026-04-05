//
//  Container+DomainLayer.swift
//  SolSol
//
//  Created by NUNU:D on 8/16/25.
//

import Foundation
import Factory
import Data
import Domain

enum DomainAssembly {
    static func register() {
        Container.shared.userRepository.register {
            UserRepositoryImpl(localDataSource: Container.shared.userDataSource())
        }

        Container.shared.budgetRepository.register {
            BudgetRepositoryImpl(localDataSource: Container.shared.budgetDataSource())
        }

        Container.shared.transactionRepository.register {
            TransactionRepositroyImpl(localDataSource: Container.shared.transactionDataSource())
        }

        Container.shared.notificationRepository.register {
            NotificationRepositoryImpl(localDataSource: Container.shared.notificationDataSource())
        }
    }
}

public extension Container {
    var userRepository: Factory<UserRepositoryProtocol> { self { fatalError("User repository is not registered") } }
    var budgetRepository: Factory<BudgetRepositoryProtocol> { self { fatalError("Budget repository is not registered") } }
    var transactionRepository: Factory<TransactionRepositroyProtocol> { self { fatalError("Transaction repository is not registered") } }
    var notificationRepository: Factory<NotificationRepositoryProtocol> { self { fatalError("Notification repository is not registered") } }
}
