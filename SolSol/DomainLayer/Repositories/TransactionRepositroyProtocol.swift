//
//  TransactionRepositroyProtocol.swift
//  SolSol
//
//  Created by NUNU:D on 8/14/25.
//

import Foundation

public protocol TransactionRepositroyProtocol {
    func getTransactions() async -> [TransactionModel]
    func getTransactions(contain name: String) async-> [TransactionModel]
    func getTransactions(by category: CategoryModel) async -> [TransactionModel]
    func getTransaction(by id: Int64) async throws -> TransactionModel
    func getTransaction(by memo: String) async throws -> TransactionModel
    func saveTransaction(_ transaction: TransactionModel) async -> Bool
}
