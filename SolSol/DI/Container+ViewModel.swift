//
//  Container+ViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 12/22/25.
//

import Foundation
import Factory

public extension Container {
    
    var homeExpenseChartViewModel: Factory<HomeExpenseChartViewModel> {
        self {
            return HomeExpenseChartViewModel()
        }
    }
    
    var homeExpenseSummaryViewModel: Factory<HomeExpenseSummaryViewModel> {
        self {
            return HomeExpenseSummaryViewModel()
        }
    }
    
    var homeViewModel: Factory<HomeViewModel> {
        self {
            return HomeViewModel()
        }
    }
}
