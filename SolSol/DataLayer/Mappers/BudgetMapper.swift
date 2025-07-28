//
//  BudgetMapper.swift
//  SolSol
//
//  Created by NUNU:D on 6/25/25.
//

import Foundation

public struct BudgetMapper: Mappable {
    public typealias DomainType = BudgetModel
    public typealias DataType = BudgetEntity
    
    public static func toDomain(to data: BudgetEntity) -> BudgetModel {
        return BudgetModel(
            id: data.id ?? -1,
            userId: data.userId,
            budgetName: data.budgetName,
            startedAt: Date(timeIntervalSince1970: data.startedAt),
            finishedAt: Date(timeIntervalSince1970: data.finishedAt),
            createdAt: Date(timeIntervalSince1970: data.createdAt),
            updatedAt: Date(timeIntervalSince1970: data.updatedAt),
            initalizeAmount: data.initalizeAmount,
            currentAmount: data.currentAmount
        )
    }
    
    public static func toLocal(to doamin: BudgetModel) -> BudgetEntity {
        return BudgetEntity(
            userId: doamin.userId,
            budgetName: doamin.budgetName,
            startedAt: doamin.startedAt.timeIntervalSince1970,
            finishedAt: doamin.finishedAt.timeIntervalSince1970,
            createdAt: doamin.createdAt.timeIntervalSince1970,
            updatedAt: doamin.updatedAt.timeIntervalSince1970,
            initalizeAmount: doamin.initalizeAmount,
            currentAmount: doamin.currentAmount
        )
    }
}
