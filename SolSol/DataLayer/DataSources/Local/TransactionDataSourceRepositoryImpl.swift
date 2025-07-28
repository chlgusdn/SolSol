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
    
    public func getTransactions() async -> [TransactionModel] {
        let query = TransactionEntity
               .including(required: TransactionEntity.category)
               .order(TransactionEntity.Columns.createdAt.desc)
               .asRequest(of: TransactionWithCategory.self)
        
        let transactions = await self.accessor.fetchAll(type: TransactionWithCategory.self, query: query) ?? []
        
        let domains = transactions.map { TransactionMapper.toDomain(to: $0.transaction, category: $0.category) }
        
        return domains
    }
    
    public func getTransactions(contain name: String) async -> [TransactionModel] {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.name.like("%\(name)%"))
            .order(TransactionEntity.Columns.createdAt.desc)
            .asRequest(of: TransactionWithCategory.self)
        
        guard let entities = await self.accessor.fetchAll(type: TransactionWithCategory.self, query: query) else { return [] }
        
        let domains = entities.map { TransactionMapper.toDomain(to: $0.transaction, category: $0.category) }
        
        return domains
    }
    
    public func getTransactions(by category: CategoryModel) async -> [TransactionModel] {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.categoryId == category.id)
            .order(TransactionEntity.Columns.createdAt.desc)
            .asRequest(of: TransactionWithCategory.self)
        
        let transactions = await self.accessor.fetchAll(type: TransactionWithCategory.self, query: query) ?? []
        let domains = transactions.map { TransactionMapper.toDomain(to: $0.transaction, category: $0.category) }
        
        return domains
    }

    public func getTransaction(by id: Int64) async -> TransactionModel? {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.id == id)
            .asRequest(of: TransactionWithCategory.self)
        
        guard let entity = await self.accessor.fetchOne(type: TransactionWithCategory.self, query: query) else { return nil }
        
        return TransactionMapper.toDomain(to: entity.transaction, category: entity.category)
    }
    
    public func getTransaction(by memo: String) async -> TransactionModel? {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.memo == memo)
            .asRequest(of: TransactionWithCategory.self)
        
        guard let entity = await self.accessor.fetchOne(type: TransactionWithCategory.self, query: query) else { return nil }
        
        return TransactionMapper.toDomain(to: entity.transaction, category: entity.category)
    }
    
    public func saveTransaction(_ transaction: TransactionModel) async -> Bool {
        let entity = TransactionMapper.toLocal(to: transaction)
        return await self.accessor.save(to: entity)
    }
    
    
}
