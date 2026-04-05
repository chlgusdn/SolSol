//
//  TransactionRepositroyImpl.swift
//  SolSol
//
//  Created by NUNU:D on 8/14/25.
//

import Foundation
import Domain

public final class TransactionRepositroyImpl: TransactionRepositroyProtocol {
    
    let localDataRepository: TransactionLocalDataSourceRepository
    
    public init(localDataSource: TransactionLocalDataSourceRepository) {
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
    
    public func getTransactions(startAt: TimeInterval, endAt: TimeInterval) async -> [TransactionModel] {
        
        let entities = await self.localDataRepository.getTransactions(startAt: startAt, endAt: endAt)
        
        let transactions = entities.map { entity in
            TransactionMapper.toDomain(to: entity.transaction, category: entity.category)
        }
        
        return transactions
    }
    
    public func getTotalTransactionAmount(for type: TransactionModel.TransactionType, startAt: TimeInterval, endAt: TimeInterval) async throws -> Decimal? {
        guard let amount = await self.localDataRepository.getTotalTransactionAmount(for: type, startAt: startAt, endAt: endAt) else {
            throw TransactionError.notFound
        }
        
        return amount
    }
    
    public func saveTransaction(_ transaction: TransactionModel) async -> Bool {
        return await self.localDataRepository.saveTransaction(transaction)
    }    
}
