//
//  HomeExpenseChartViewModel.swift
//  SolSol
//
//  Created by NUNU:D on 11/26/25.
//

import UIKit
import Combine
import Domain
import DesignSystem
import SolSolCore

public final class HomeExpenseChartViewModel: ObservableObject {

    @Published private(set) var entries: [SDChartDataEntry] = []

    private let chartSummaryUsecase: HomeExpenseSummaryChartUsecaseProtocol

    public init(chartSummaryUsecase: HomeExpenseSummaryChartUsecaseProtocol) {
        self.chartSummaryUsecase = chartSummaryUsecase

        Task { @MainActor in

            let result = await self.chartSummaryUsecase.execute(
                startAt: Date.now.millisecond,
                endAt: Date.now.adding(days: 14).millisecond
            )

            guard case .success(let response) = result else {
                return
            }

            self.entries = response.entries.map { entry in
                let color = UIColor(named: entry.colorName) ?? (SDColors.graph100 ?? .systemRed)
                return SDChartDataEntry(
                    label: entry.label,
                    color: color,
                    x: entry.value,
                    y: 0.0
                )
            }
        }
    }

}
