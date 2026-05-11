//
//  HomeExpenseTotalAmountUsecase.swift
//  SolSol
//
//  Created by NUNU:D on 12/22/25.
//

import Foundation

public protocol HomeExpenseTotalAmountUsecaseProtocol {

    func execute(startAt: TimeInterval, endAt: TimeInterval) async -> Result<Decimal, UsecaseError>
}

public final class HomeExpenseTotalAmountUsecase: HomeExpenseTotalAmountUsecaseProtocol {
    private let transactionRepository: TransactionRepositroyProtocol

    public init(transactionRepository: TransactionRepositroyProtocol) {
        self.transactionRepository = transactionRepository
    }

    public func execute(startAt: TimeInterval, endAt: TimeInterval) async -> Result<Decimal, UsecaseError> {

        do {

            // DB에서 계산한 값을 가져옴
            guard let totalAmount = try await self.transactionRepository.getTotalTransactionAmount(
                for: .expense,
                startAt: startAt,
                endAt: endAt
            ) else {
                return .failure(.notFound)
            }

            // 값이 0이 아닌지 체크
            guard totalAmount > 0 else {
                return .failure(.message(message: "값이 0입니다"))
            }

            return .success(totalAmount)
        } catch {
            return .failure(.unknown(error: error))
        }
    }
}
