//
//  BudgetModel.swift
//  SolSol
//
//  Created by NUNU:D on 6/25/25.
//

import Foundation

public struct BudgetModel: BaseModel {
    private(set)var id: Int64
    public var userId: String
    public var budgetName: String
    public var startedAt: Date
    public var finishedAt: Date
    public var createdAt: Date
    public var updatedAt: Date
    public var initalizeAmount: Double
    public var currentAmount: Double
    
    public init(
        id: Int64,
        userId: String,
        budgetName: String,
        startedAt: Date,
        finishedAt: Date,
        createdAt: Date,
        updatedAt: Date,
        initalizeAmount: Double,
        currentAmount: Double
    ) {
        self.id = id
        self.userId = userId
        self.budgetName = budgetName
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.initalizeAmount = initalizeAmount
        self.currentAmount = currentAmount
    }
}
