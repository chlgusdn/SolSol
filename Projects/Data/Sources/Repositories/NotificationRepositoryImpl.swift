//
//  NotificationRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 8/14/25.
//

import Foundation
import Domain

public class NotificationRepositoryImpl: NotificationRepositoryProtocol {
    
    let localDataSource: NotificationLocalDataSourceRepository
    
    public init(localDataSource: NotificationLocalDataSourceRepository) {
        self.localDataSource = localDataSource
    }
    
    public func getAllNotifications() async -> [NotificationModel] {
        let entities = await self.localDataSource.getAllNotifications()
        let notifications = entities.map { entity in
            NotificationMapper.toDomain(to: entity.notification, budget: entity.budget)
        }
        return notifications
    }
    
    public func saveNotification(_ notification: NotificationModel) async -> Bool {
        return await self.localDataSource.saveNotification(notification)
    }
}
