//
//  NotificationEntity.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

public struct NotificationEntity: BaseEntitiy {
    
    public var id: Int64?
    public var userId: String
    public var budgetId: Int64?
    public var notificationType: Int
    public var settingNotifiactionAmount: Double
    public var isActive: Bool
    public var createdAt: TimeInterval
    public var updatedAt: TimeInterval
    
    public enum Columns: String, ColumnExpression {
        case id
        case userId
        case budgetId
        case notificationType
        case settingNotifiactionAmount
        case isActive
        case createdAt
        case updatedAt
    }
    
    public init(
        id: Int64? = nil,
        userId: String,
        budgetId: Int64? = nil,
        notificationType: Int,
        settingNotifiactionAmount: Double,
        isActive: Bool,
        createdAt: TimeInterval,
        updatedAt: TimeInterval
    ) {
        self.id = id
        self.userId = userId
        self.budgetId = budgetId
        self.notificationType = notificationType
        self.settingNotifiactionAmount = settingNotifiactionAmount
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
