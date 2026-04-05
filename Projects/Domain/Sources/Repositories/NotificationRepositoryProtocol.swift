//
//  NotificationRepositoryProtocol.swift
//  SolSol
//
//  Created by NUNU:D on 8/14/25.
//

import Foundation

public protocol NotificationRepositoryProtocol {
    func getAllNotifications() async -> [NotificationModel]
    func saveNotification(_ notification: NotificationModel) async -> Bool
}
