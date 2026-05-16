//
//  ExpenseChangeRateUsecase.swift
//  SolSol
//
//  Created by NUNU:D on 12/27/25.
//

import Foundation
import SolSolCore

public protocol ExpenseChangeRateUsecaseProtocol {
    func execute(startAt: TimeInterval, endAt: TimeInterval) async -> Result<Decimal, UsecaseError>
}

public final class ExpenseChangeRateUsecase: ExpenseChangeRateUsecaseProtocol {
    private let transactionRepository: TransactionRepositroyProtocol

    public init(transactionRepository: TransactionRepositroyProtocol) {
        self.transactionRepository = transactionRepository
    }

    public func execute(startAt: TimeInterval, endAt: TimeInterval) async -> Result<Decimal, UsecaseError> {

        do {
            let currentDate = Date.ntpNow
            let todayOfStartDay = Calendar.current.startOfDay(for: currentDate).millisecond

            let todayTotalExpense = try await self.transactionRepository.getTotalTransactionAmount(
                for: .expense,
                startAt: todayOfStartDay,
                endAt: currentDate.millisecond
            )

            let targetTotalExpense = try await self.transactionRepository.getTotalTransactionAmount(
                for: .expense,
                startAt: startAt,
                endAt: endAt
            )

            guard let todayTotalExpense = todayTotalExpense, todayTotalExpense.isZero == false else {
                return .failure(.notFound)
            }

            guard let targetTotalExpense = targetTotalExpense, targetTotalExpense.isZero == false else {
                return .failure(.notFound)
            }

            let changeRate = ((todayTotalExpense - targetTotalExpense)/targetTotalExpense) * 100

            return .success(changeRate)

        } catch {
            Log.e(error.localizedDescription)
            return .failure(.unknown(error: error))
        }

    }
}
