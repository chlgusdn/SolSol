//
//  BudgetDataSourceRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 6/25/25.
//

import Foundation

public final class BudgetDataSourceRepositoryImpl: BudgetLocalDataSourceRepository {
    
    let accessor: SQLAccessor
    
    init(accessor: SQLAccessor) throws {
        self.accessor = accessor
    }
    
    public func getCurrentBudget() async -> BudgetEntity? {
        let sql = """
        SELECT *
        FROM \(BudgetEntity.databaseTableName)
        WHERE \(BudgetEntity.Columns.finishedAt) < \(Date().second)
        ORDER BY \(BudgetEntity.Columns.id)
        DESC LIMIT 1
        """
        return await accessor.fetchOne(type: BudgetEntity.self, rawQuery: sql)
    }
    
    public func getRemainingBudgetExpirationDate() async -> TimeInterval? {
        let sql = """
        SELECT *
        FROM \(BudgetEntity.databaseTableName)
        WHERE \(BudgetEntity.Columns.finishedAt) < \(Date().second)
        ORDER BY \(BudgetEntity.Columns.id)
        DESC LIMIT 1
        """
        return await accessor.fetchOne(type: BudgetEntity.self, rawQuery: sql)?.finishedAt
    }
    
    public func saveBudget(_ budget: BudgetModel) async -> Bool {
        let entity = BudgetMapper.toLocal(to: budget)
        return await accessor.save(to: entity)
    }
    
    public func updateBudget(_ budget: BudgetModel) async -> Bool {
        let entity = BudgetMapper.toLocal(to: budget)
        return await accessor.updateOne(to: entity)
    }
    
    public func deleteBudget(_ budget: BudgetModel) async -> Bool {
        let entity = BudgetMapper.toLocal(to: budget)
        return await accessor.deleteOne(to: entity)
    }
}
