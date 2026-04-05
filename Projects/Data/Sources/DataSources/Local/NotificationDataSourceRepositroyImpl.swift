//
//  NotificationDataSourceRepositroyImpl.swift
//  SolSol
//
//  Created by NUNU:D on 8/13/25.
//

import Foundation
import GRDB
import Domain

public final class NotificationDataSourceRepositroyImpl: NotificationLocalDataSourceRepository {
    
    let accessor: SQLAccessor
    
    public init(accessor: SQLAccessor) throws {
        self.accessor = accessor
    }
    
    public func getAllNotifications() async -> [NotificationWithBudgetEntitiy] {
        
        let query = NotificationEntity
            .including(required: NotificationEntity.budget)
            .order(NotificationEntity.Columns.createdAt.desc)
            .asRequest(of: NotificationWithBudgetEntitiy.self)
        
        return await self.accessor.fetchAll(type: NotificationWithBudgetEntitiy.self, query: query) ?? []
    }
    
    public func saveNotification(_ notification: NotificationModel) async -> Bool {
        let entity = NotificationMapper.toLocal(to: notification)
        return await self.accessor.save(to: entity)
    }
}
