//
//  Container+Usecase.swift
//  SolSol
//
//  Created by NUNU:D on 11/26/25.
//

import Foundation
import Factory

public extension Container {
    
    /// 홈 지출 차트 usecase
    var homeExpenseChartUsecase: Factory<HomeExpenseSummaryChartUsecaseProtocol> {
        self {
            return HomeExpenseSummaryChartUsecase()
        }
    }
    
    /// 홈 화면 총 지출 값 usecase
    var homeExpenseTotalAmountUsecase: Factory<HomeExpenseTotalAmountUsecaseProtocol> {
        self {
            return  HomeExpenseTotalAmountUsecase()
        }
    }
}
