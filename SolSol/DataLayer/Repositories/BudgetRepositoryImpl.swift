//
//  BudgetRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 6/25/25.
//

import Foundation
import Combine

public final class BudgetRepositoryImpl: BudgetRepositoryProtocol {
    
    let localDataSource: BudgetLocalDataSourceRepository
    
    init(localDataSource: BudgetLocalDataSourceRepository) {
        self.localDataSource = localDataSource
    }
    
    public func getCurrentBudget() -> AnyPublisher<BudgetModel, any Error> {
        return Publishers.Async {
            
            guard let result = await self.localDataSource.getCurrentBudget() else {
                throw NSError(domain: "", code: -1)
            }
            
            return BudgetMapper.toDomain(to: result)
        }
        .eraseToAnyPublisher()
    }
    
    public func getRemainingBudgetExpirationDate() -> AnyPublisher<TimeInterval, any Error> {
        return Publishers.Async {
            let result = await self.localDataSource.getRemainingBudgetExpirationDate()
            return result
        }
        .eraseToAnyPublisher()
    }
    
    public func saveBudget(_ budget: BudgetModel) -> AnyPublisher<Bool, any Error> {
        return Publishers.Async {
            return await self.localDataSource.saveBudget(budget)
        }
        .eraseToAnyPublisher()
    }
    
    public func updateBudget(_ budget: BudgetModel) -> AnyPublisher<Bool, any Error> {
        return Publishers.Async {
            return await self.localDataSource.updateBudget(budget)
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteBudget(_ budget: BudgetModel) -> AnyPublisher<Bool, any Error> {
        return Publishers.Async {
            return await self.localDataSource.deleteBudget(budget)
        }
        .eraseToAnyPublisher()
    }
    
}
