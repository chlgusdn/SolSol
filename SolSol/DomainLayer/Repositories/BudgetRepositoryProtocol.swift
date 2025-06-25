//
//  BudgetRepositoryProtocol.swift
//  SolSol
//
//  Created by NUNU:D on 6/25/25.
//

import Foundation
import Combine

public protocol BudgetRepositoryProtocol {
    func getCurrentBudget() -> AnyPublisher<BudgetModel, Error>
    func getRemainingBudgetExpirationDate() -> AnyPublisher<TimeInterval, Error>
    func saveBudget(_ budget: BudgetModel) -> AnyPublisher<Bool, Error>
    func updateBudget(_ budget: BudgetModel) -> AnyPublisher<Bool, Error>
    func deleteBudget(_ budget: BudgetModel) -> AnyPublisher<Bool, Error>
}
