//
//  TransactionDataSourceRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 7/5/25.
//

import Foundation
import GRDB

public struct TransactionDataSourceRepositoryImpl: TransactionLocalDataSourceRepository {
    
    let accessor: SQLAccessor
    
    init(accessor: SQLAccessor) throws {
        self.accessor = accessor
    }
    
    public func getTransactions() async -> [TransactionWithCategoryEntitiy] {
        let query = TransactionEntity
               .including(required: TransactionEntity.category)
               .order(TransactionEntity.Columns.createdAt.desc)
               .asRequest(of: TransactionWithCategoryEntitiy.self)
        
        return await self.accessor.fetchAll(type: TransactionWithCategoryEntitiy.self, query: query) ?? []
    }
    
    public func getTransactions(contain name: String) async -> [TransactionWithCategoryEntitiy] {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.name.like("%\(name)%"))
            .order(TransactionEntity.Columns.createdAt.desc)
            .asRequest(of: TransactionWithCategoryEntitiy.self)
        
        return await self.accessor.fetchAll(type: TransactionWithCategoryEntitiy.self, query: query) ?? []
    }
    
    public func getTransactions(by category: CategoryModel) async -> [TransactionWithCategoryEntitiy] {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.categoryId == category.id)
            .order(TransactionEntity.Columns.createdAt.desc)
            .asRequest(of: TransactionWithCategoryEntitiy.self)
        
        return await self.accessor.fetchAll(type: TransactionWithCategoryEntitiy.self, query: query) ?? []
    }

    public func getTransaction(by id: Int64) async -> TransactionWithCategoryEntitiy? {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.id == id)
            .asRequest(of: TransactionWithCategoryEntitiy.self)
        
        return await self.accessor.fetchOne(type: TransactionWithCategoryEntitiy.self, query: query)
    }
    
    public func getTransaction(by memo: String) async -> TransactionWithCategoryEntitiy? {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.memo == memo)
            .asRequest(of: TransactionWithCategoryEntitiy.self)
        
        return await self.accessor.fetchOne(type: TransactionWithCategoryEntitiy.self, query: query)
    }
    
    public func saveTransaction(_ transaction: TransactionModel) async -> Bool {
        let entity = TransactionMapper.toLocal(to: transaction)
        return await self.accessor.save(to: entity)
    }
    
    
}
