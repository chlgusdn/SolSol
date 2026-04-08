//
//  NotificationModel.swift
//  SolSol
//
//  Created by NUNU:D on 7/2/25.
//

import Foundation

public struct NotificationModel: BaseModel {

    public enum NotificationType: Int {
        case warnning
        case danger
    }

    public var userId: String
    public var budget: BudgetModel?
    public var notificationType: NotificationType
    public var settingNotifiactionAmount: Double
    public var isActive: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        userId: String,
        budget: BudgetModel?,
        notificationType: NotificationType,
        settingNotifiactionAmount: Double,
        isActive: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.userId = userId
        self.budget = budget
        self.notificationType = notificationType
        self.settingNotifiactionAmount = settingNotifiactionAmount
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
