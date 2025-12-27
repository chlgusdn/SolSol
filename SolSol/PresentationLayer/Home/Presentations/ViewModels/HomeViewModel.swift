//
//  HomeViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 12/27/25.
//

import Foundation
import Factory


public final class HomeViewModel: ObservableObject {
    
    @Injected(\.expenseChangeRateUsecase) var expenseChangeRateUsecase: ExpenseChangeRateUsecase
    
    @Published private(set) var changeRate: ChangeRate = .none
    
    init() {
        Task { @MainActor [weak self] in
            
            guard let self = self else {
                return
            }
            
            self.changeRate = await self.calculateChangeRate()
        }
    }
    
    private func calculateChangeRate() async -> ChangeRate {
        let currentDate = Date.now
        let startOfDay = Calendar.current.startOfDay(for: currentDate)
        let startedAt = startOfDay.daysAgo(1).millisecond
        let endAt = currentDate.subtracting(milliseconds: 1).millisecond
        
        let changeRate = await self.expenseChangeRateUsecase.execute(
            startAt: startedAt,
            endAt: endAt
        )
        
        
        switch changeRate {
        case .success(let success):
            
            if success > 0 {
                return .increase(rate: success.doubleValue)
            } else if success == 0 {
                return .none
            } else {
                return .decrease(rate: success.doubleValue)
            }
            
        case .failure(let failure):
            return .none
        }
        
    }
}

extension HomeViewModel {
    
    enum ChangeRate {
        case increase(rate: Double)
        case decrease(rate: Double)
        case none
    }
}
