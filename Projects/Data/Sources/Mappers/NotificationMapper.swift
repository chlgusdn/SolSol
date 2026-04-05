//
//  NotificationMapper.swift
//  SolSol
//
//  Created by NUNU:D on 8/13/25.
//

import Foundation
import Domain
import SolSolCore

public struct NotificationMapper: Mappable {
    
    public typealias DomainType = NotificationModel
    public typealias DataType = NotificationEntity
    
    public static func toDomain(to data: NotificationEntity, budget: BudgetEntity) -> NotificationModel {
        return NotificationModel(
            userId: data.userId,
            budget: BudgetMapper.toDomain(to: budget),
            notificationType: NotificationModel.NotificationType(rawValue: data.notificationType) ?? .warnning,
            settingNotifiactionAmount: data.settingNotifiactionAmount,
            isActive: data.isActive,
            createdAt: Date(timeIntervalSince1970: data.createdAt),
            updatedAt: Date(timeIntervalSince1970: data.createdAt)
        )
    }
    
    public static func toLocal(to data: NotificationModel) -> NotificationEntity {
        
        return NotificationEntity(
            userId: data.userId,
            budgetId: data.budget?.id,
            notificationType: data.notificationType.rawValue,
            settingNotifiactionAmount: data.settingNotifiactionAmount,
            isActive: data.isActive,
            createdAt: data.createdAt.millisecond,
            updatedAt: data.updatedAt.millisecond
        )
    }
}
