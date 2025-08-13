//
//  NotificationWithBudgetEntitiy.swift
//  SolSol
//
//  Created by NUNU:D on 8/13/25.
//

import Foundation
import GRDB

public struct NotificationWithBudgetEntitiy: Codable, PersistableRecord, FetchableRecord {
    public var notification: NotificationEntity
    public var budget: BudgetEntity
}
