//
//  HomeExpenseSummaryViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 11/22/25.
//

import Foundation
import Combine

final class HomeExpenseSummaryViewModel: ObservableObject {
    
    @Published private(set) var totalExpense: Double = 0.0
    
    private var isSummaryExpenseShowed: Bool = false {
        willSet {
            if newValue == true  {
                self.summaryExpenseDays = 14
            }
            else {
                self.summaryExpenseDays = 0
            }
        }
    }
    
    private(set) var summaryExpenseDays: Int = 0
    
}
