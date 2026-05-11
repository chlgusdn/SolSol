//
//  HomeExpenseSummaryChartUsecase.swift
//  SolSol
//
//  Created by NUNU:D on 11/22/25.
//

import Foundation
import SolSolCore

public protocol HomeExpenseSummaryChartUsecaseProtocol {
    func execute(
        startAt: TimeInterval,
        endAt: TimeInterval
    ) async -> Result<HomeChartSummaryResponseModel, UsecaseError>
}

/// 홈 지출 차트 데이터 엔트리 생성 usecase
public struct HomeExpenseSummaryChartUsecase: HomeExpenseSummaryChartUsecaseProtocol {
    private let transactionRepository: TransactionRepositroyProtocol

    public init(transactionRepository: TransactionRepositroyProtocol) {
        self.transactionRepository = transactionRepository
    }

    public func execute(
        startAt: TimeInterval,
        endAt: TimeInterval
    ) async -> Result<HomeChartSummaryResponseModel, UsecaseError> {

        let transactions: [TransactionModel] = await self.transactionRepository.getTransactions(
            startAt: startAt,
            endAt: endAt
        )

        let grouped: [String: [TransactionModel]] = Dictionary(
            grouping: transactions,
            by: { (tx: TransactionModel) in
                tx.category.categoryName
            }
        )

        let sortedGroups: [[TransactionModel]] = grouped
            .values
            .sorted { (lhs: [TransactionModel], rhs: [TransactionModel]) in
                lhs.count > rhs.count
            }

        let maxCount = sortedGroups
            .max { $0.count < $1.count }?
            .count ?? 10

        var entries: [HomeChartSummaryEntryModel] = []

        for (index, group) in sortedGroups.enumerated() {

            guard let first = group.first else {
                continue
            }

            let label: String = first.category.categoryName
            let count: Int = group.count
            let colorName = "graph\(index)00"
            let entry = HomeChartSummaryEntryModel(
                label: label,
                colorName: colorName,
                value: Double(count)
            )

            entries.append(entry)
        }

        return .success(
            HomeChartSummaryResponseModel(
                max: maxCount,
                entries: entries
            )
        )
    }

}
