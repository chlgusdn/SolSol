//
//  HomeExpenseChartViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 11/26/25.
//

import Foundation
import Factory

public final class HomeExpenseChartViewModel: ObservableObject {
 
    @Published private(set) var entries: [SDChartDataEntry] = []
    @Published private(set) var maxCount: Int = 1
    
    @Injected(\.homeExpenseChartUsecase) var chartSummaryUsecase: HomeExpenseSummaryChartUsecaseProtocol
    
    init() {
        
        Task { @MainActor in
            
            let result = await self.chartSummaryUsecase.execute(
                startAt: Date.now.millisecond,
                endAt: Date.now.addingTimeInterval(60 * 60 * 24 * 14).millisecond
            )
            
            // response 응답 값이 성공일 경우에만 반환 처리
            guard case .success(let response) = result else {
                return
            }
            
            self.entries = response.entries
            self.maxCount = max(response.max, 1)
        }
    }
    
}
