//
//  BudgetModel.swift
//  SolSol
//
//  Created by NUNU:D on 6/25/25.
//

import Foundation

public struct BudgetModel: BaseModel {
    public var userId: String
    public var budgetName: String
    public var startedAt: Date
    public var finishedAt: Date
    public var createdAt: Date
    public var updatedAt: Date
    public var initalizeAmount: Double
    public var currentAmount: Double
}
