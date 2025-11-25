//
//  HomeExpenseChartViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 11/26/25.
//

import Foundation
import Factory

final class HomeExpenseChartViewModel: ObservableObject {
 
    @Published private(set) var entries: [SDChartDataEntry] = []
    @Published private(set) var maxCount: Int = 1
    
    @Injected(\.homeExpenseChartUsecase) var chartSummaryUsecase: HomeExpenseSummaryChartUsecaseProtocol
    
    init() {
        
        Task { @MainActor in
            let (maxCount, entries) = await self.chartSummaryUsecase.execute(
                startAt: Date.now.millisecond,
                endAt: Date.now.addingTimeInterval(60 * 60 * 24 * 14).millisecond
            )
            
            self.entries = entries
            self.maxCount = max(maxCount, 1)
        }
    }
    
}
