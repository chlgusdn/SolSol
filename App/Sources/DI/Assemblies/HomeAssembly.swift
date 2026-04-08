//
//  Container+ViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 12/22/25.
//

import Foundation
import Factory
import HomePresentation

enum HomeAssembly {

    static func register() {
        Container.shared.homeExpenseChartViewModel.register {
            HomeExpenseChartViewModel(
                chartSummaryUsecase: Container.shared.homeExpenseChartUsecase()
            )
        }

        Container.shared.homeExpenseSummaryViewModel.register {
            HomeExpenseSummaryViewModel(
                homeExpenseTotalAmountUsecase: Container.shared.homeExpenseTotalAmountUsecase()
            )
        }

        Container.shared.homeViewModel.register {
            HomeViewModel(
                expenseChangeRateUsecase: Container.shared.expenseChangeRateUsecase()
            )
        }
    }
}

public extension Container {
    var homeExpenseChartViewModel: Factory<HomeExpenseChartViewModel> {
        self {
            fatalError("Home chart view model is not registered")
        }
    }

    var homeExpenseSummaryViewModel: Factory<HomeExpenseSummaryViewModel> {
        self {
            fatalError("Home summary view model is not registered")
        }
    }

    var homeViewModel: Factory<HomeViewModel> {
        self {
            fatalError("Home view model is not registered")
        }
    }
}
