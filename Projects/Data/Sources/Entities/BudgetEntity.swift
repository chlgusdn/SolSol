//
//  BudgetEntity.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

/// 예산 엔티티
public struct BudgetEntity: BaseEntitiy {
    public var id: Int64?
    public var userId: String
    public var budgetName: String
    public var startedAt: TimeInterval
    public var finishedAt: TimeInterval
    public var createdAt: TimeInterval
    public var updatedAt: TimeInterval
    public var initalizeAmount: Double
    public var currentAmount: Double

    public enum Columns: String, ColumnExpression {
        case id
        case userId
        case budgetName
        case startedAt
        case finishedAt
        case createdAt
        case updatedAt
        case initalizeAmount
        case currentAmount
    }

    public init(
        id: Int64? = nil,
        userId: String,
        budgetName: String,
        startedAt: TimeInterval,
        finishedAt: TimeInterval,
        createdAt: TimeInterval,
        updatedAt: TimeInterval,
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

public extension BudgetEntity {
    /// N: 1 관계
    static let notifications = hasMany(NotificationEntity.self, key: NotificationEntity.Columns.budgetId.rawValue)
}
