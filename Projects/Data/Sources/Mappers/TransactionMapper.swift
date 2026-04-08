//
//  TransactionMapper.swift
//  SolSol
//
//  Created by NUNU:D on 7/5/25.
//

import Foundation
import Domain
import SolSolCore

public struct TransactionMapper: Mappable {
    public typealias DomainType = TransactionModel
    public typealias DataType = TransactionEntity

    public static func toDomain(to data: TransactionEntity, category: CategoryEntitiy) -> TransactionModel {

        return TransactionModel(
            id: data.id ?? -1,
            userId: data.userId,
            category: CategoryModel(
                id: category.id ?? -1,
                categoryName: category.categoryName,
                categoryType: category.categoryType
            ),
            amount: data.amount,
            createdAt: Date(timeIntervalSince1970: data.createdAt),
            memo: data.memo,
            name: data.name,
            type: TransactionModel.TransactionType(rawValue: data.type) ?? .expense
        )
    }

    public static func toLocal(to doamin: TransactionModel) -> TransactionEntity {
        return TransactionEntity(
            userId: doamin.userId,
            categoryId: doamin.category.id,
            amount: doamin.amount,
            createdAt: doamin.createdAt.timeIntervalSince1970,
            memo: doamin.memo,
            name: doamin.name,
            type: doamin.type.rawValue
        )
    }
}
