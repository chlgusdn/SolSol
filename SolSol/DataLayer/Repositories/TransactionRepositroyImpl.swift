//
//  TransactionRepositroyImpl.swift
//  SolSol
//
//  Created by NUNU:D on 8/14/25.
//

import Foundation

public final class TransactionRepositroyImpl: TransactionRepositroyProtocol {
    
    let localDataRepository: TransactionLocalDataSourceRepository
    
    init(localDataSource: TransactionLocalDataSourceRepository) {
        self.localDataRepository = localDataSource
    }
    
    public func getTransactions() async -> [TransactionModel] {
        let entities = await self.localDataRepository.getTransactions()
        let transactions = entities.map { entity in
            TransactionMapper.toDomain(to: entity.transaction, category: entity.category)
        }
        return transactions
    }
    
    public func getTransactions(contain name: String) async -> [TransactionModel] {
        let entities = await self.localDataRepository.getTransactions(contain: name)
        let transactions = entities.map { entity in
            TransactionMapper.toDomain(to: entity.transaction, category: entity.category)
        }
        return transactions
    }
    
    public func getTransactions(by category: CategoryModel) async -> [TransactionModel] {
        let entities = await self.localDataRepository.getTransactions(by: category)
        let transactions = entities.map { entity in
            TransactionMapper.toDomain(to: entity.transaction, category: entity.category)
        }
        return transactions
    }
    
    public func getTransaction(by id: Int64) async throws -> TransactionModel {
        
        guard let entity = await self.localDataRepository.getTransaction(by: id) else {
            throw TransactionError.notFound
        }
        
        return TransactionMapper.toDomain(to: entity.transaction, category: entity.category)
        
    }
    
    public func getTransaction(by memo: String) async throws -> TransactionModel {
        
        guard let entity = await self.localDataRepository.getTransaction(by: memo) else {
            throw TransactionError.notFound
        }
        
        return TransactionMapper.toDomain(to: entity.transaction, category: entity.category)
    }
    
    public func saveTransaction(_ transaction: TransactionModel) async -> Bool {
        return await self.localDataRepository.saveTransaction(transaction)
    }    
}
