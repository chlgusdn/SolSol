//
//  TransactionRepositroyProtocol.swift
//  SolSol
//
//  Created by NUNU:D on 8/14/25.
//

import Foundation

public protocol TransactionRepositroyProtocol {
    func getTransactions() async -> [TransactionModel]
    func getTransactions(contain name: String) async -> [TransactionModel]
    func getTransactions(by category: CategoryModel) async -> [TransactionModel]
    func getTransaction(by id: Int64) async throws -> TransactionModel
    func getTransaction(by memo: String) async throws -> TransactionModel
    func getTransactions(startAt: TimeInterval, endAt: TimeInterval) async -> [TransactionModel]
    func getTotalTransactionAmount(
        for type: TransactionModel.TransactionType,
        startAt: TimeInterval,
        endAt: TimeInterval
    ) async throws -> Decimal?
    func saveTransaction(_ transaction: TransactionModel) async -> Bool
}
