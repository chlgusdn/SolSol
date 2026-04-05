//
//  HomeExpenseChartViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 11/26/25.
//

import Foundation
import SwiftUI
import Domain
import DesignSystem
import SolSolCore

public final class HomeExpenseChartViewModel: ObservableObject {
 
    @Published private(set) var entries: [SDChartDataEntry] = []
    @Published private(set) var maxCount: Int = 1
    
    private let chartSummaryUsecase: HomeExpenseSummaryChartUsecaseProtocol
    
    public init(chartSummaryUsecase: HomeExpenseSummaryChartUsecaseProtocol) {
        self.chartSummaryUsecase = chartSummaryUsecase
        
        Task { @MainActor in
            
            let result = await self.chartSummaryUsecase.execute(
                startAt: Date.now.millisecond,
                endAt: Date.now.addingTimeInterval(60 * 60 * 24 * 14).millisecond
            )
            
            // response 응답 값이 성공일 경우에만 반환 처리
            guard case .success(let response) = result else {
                return
            }
            
            self.entries = response.entries.map { entry in
                let color = UIColor(named: entry.colorName) ?? (SDColors.graph100 ?? .systemRed)
                return SDChartDataEntry(
                    label: entry.label,
                    color: Color(color),
                    x: entry.value,
                    y: 0.0
                )
            }
            self.maxCount = max(response.max, 1)
        }
    }
    
}
