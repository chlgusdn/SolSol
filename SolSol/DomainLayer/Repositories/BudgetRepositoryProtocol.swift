//
//  BudgetRepositoryProtocol.swift
//  SolSol
//
//  Created by NUNU:D on 6/25/25.
//

import Foundation

public protocol BudgetRepositoryProtocol {
    func getCurrentBudget() async throws -> BudgetModel
    func getRemainingBudgetExpirationDate() async throws -> TimeInterval
    func saveBudget(_ budget: BudgetModel) async -> Bool
    func updateBudget(_ budget: BudgetModel) async -> Bool
    func deleteBudget(_ budget: BudgetModel) async -> Bool
}
