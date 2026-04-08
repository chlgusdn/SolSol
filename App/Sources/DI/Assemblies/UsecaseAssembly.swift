//
//  Container+Usecase.swift
//  SolSol
//
//  Created by NUNU:D on 11/26/25.
//

import Foundation
import Factory
import Domain

enum UsecaseAssembly {
    static func register() {
        Container.shared.homeExpenseChartUsecase.register {
            HomeExpenseSummaryChartUsecase(
                transactionRepository: Container.shared.transactionRepository()
            )
        }

        Container.shared.homeExpenseTotalAmountUsecase.register {
            HomeExpenseTotalAmountUsecase(
                transactionRepository: Container.shared.transactionRepository()
            )
        }

        Container.shared.expenseChangeRateUsecase.register {
            ExpenseChangeRateUsecase(
                transactionRepository: Container.shared.transactionRepository()
            )
        }
    }
}

public extension Container {
    var homeExpenseChartUsecase: Factory<HomeExpenseSummaryChartUsecaseProtocol> {
        self {
            fatalError("Home chart usecase is not registered")
        }
    }

    var homeExpenseTotalAmountUsecase: Factory<HomeExpenseTotalAmountUsecaseProtocol> {
        self {
            fatalError("Home total amount usecase is not registered")
        }
    }

    var expenseChangeRateUsecase: Factory<ExpenseChangeRateUsecaseProtocol> {
        self {
            fatalError("Expense change rate usecase is not registered")
        }
    }
}
