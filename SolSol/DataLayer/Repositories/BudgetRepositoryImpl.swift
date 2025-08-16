//
//  BudgetRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 6/25/25.
//

import Foundation

public final class BudgetRepositoryImpl: BudgetRepositoryProtocol {
    
    let localDataSource: BudgetLocalDataSourceRepository
    
    init(localDataSource: BudgetLocalDataSourceRepository) {
        self.localDataSource = localDataSource
    }
    
    public func getCurrentBudget() async throws -> BudgetModel {
        
        guard let result = await self.localDataSource.getCurrentBudget() else {
            throw BudgetError.notFound
        }
        
        return BudgetMapper.toDomain(to: result)
    }
    
    public func getRemainingBudgetExpirationDate() async throws -> TimeInterval {
        guard let result = await self.localDataSource.getRemainingBudgetExpirationDate() else {
            throw BudgetError.notFound
        }
        return result
    }
    
    public func saveBudget(_ budget: BudgetModel) async -> Bool {
        return await self.localDataSource.saveBudget(budget)
    }
    
    public func updateBudget(_ budget: BudgetModel) async -> Bool {
        return await self.localDataSource.updateBudget(budget)
    }
    
    public func deleteBudget(_ budget: BudgetModel) async -> Bool {
        return await self.localDataSource.deleteBudget(budget)
    }
}
