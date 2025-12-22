//
//  HomeExpenseSummaryViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 11/22/25.
//

import Foundation
import Combine
import Factory

final class HomeExpenseSummaryViewModel: ObservableObject {
    
    @Published private(set) var totalExpense: Decimal = 0
    
    @Injected(\.homeExpenseTotalAmountUsecase) var homeExpenseTotalAmountUsecase: HomeExpenseTotalAmountUsecaseProtocol
    
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
    
    init() {
        
        Task { @MainActor [weak self] in
            
            guard let `self` = self else {
                return
            }
            
            let result = await self.homeExpenseTotalAmountUsecase.execute(
                startAt: Date.now.millisecond,
                endAt: Date.now.adding(days: 14).millisecond
            )
            
            // response 응답 값이 성공일 경우에만 반환 처리
            guard case .success(let response) = result else {
                return
            }
            
            self.totalExpense = response
        }
    }
}
