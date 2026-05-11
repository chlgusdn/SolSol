//
//  TransactionDataSourceRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 7/5/25.
//

import Foundation
import GRDB
import Domain

public struct TransactionDataSourceRepositoryImpl: TransactionLocalDataSourceRepository {

    let accessor: SQLAccessor

    public init(accessor: SQLAccessor) throws {
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

    public func getTransactions(startAt: TimeInterval, endAt: TimeInterval) async -> [TransactionWithCategoryEntitiy] {
        let query = TransactionEntity
            .including(required: TransactionEntity.category)
            .filter(TransactionEntity.Columns.createdAt >= startAt)
            .filter(TransactionEntity.Columns.createdAt <= endAt)
            .order(TransactionEntity.Columns.createdAt.desc)
            .asRequest(of: TransactionWithCategoryEntitiy.self)

        return await self.accessor.fetchAll(type: TransactionWithCategoryEntitiy.self, query: query) ?? []
    }

    public func getTotalTransactionAmount(for type: TransactionModel.TransactionType, startAt: TimeInterval, endAt: TimeInterval) async -> Decimal? {
        let query = TransactionEntity
            .filter(TransactionEntity.Columns.type == type.rawValue)
            .filter(TransactionEntity.Columns.createdAt >= startAt)
            .filter(TransactionEntity.Columns.createdAt <= endAt)
            .order(TransactionEntity.Columns.createdAt.desc)

        return await self.accessor.fetchAll(type: TransactionEntity.self, query: query)?
            .compactMap { $0.amount }
            .map { $0.decimalValue }
            .reduce(0) { $0 + $1 }
    }

    public func saveTransaction(_ transaction: TransactionModel) async -> Bool {
        let entity = TransactionMapper.toLocal(to: transaction)
        return await self.accessor.save(to: entity)
    }

}
