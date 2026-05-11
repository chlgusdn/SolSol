//
//  LocalDataSourceRepository.swift
//  SolSol
//
//  Created by NUNU:D on 6/15/25.
//

import Foundation
import Domain

public protocol LocalDataSourceRepository {}

// MARK: - User
public protocol UserLocalDataSourceRepository: LocalDataSourceRepository {
    func getUser() async -> UserEntity?
    func getUsers() async -> [UserEntity]
    func saveUser(_ user: UserModel) async -> Bool
    func saveUsers(users: [UserModel]) async -> Bool
    func updateUser(_ user: UserModel)async -> Bool
    func deleteUser(_ user: UserModel) async -> Bool
}

// MARK: - Budget
public protocol BudgetLocalDataSourceRepository: LocalDataSourceRepository {
    func getCurrentBudget() async -> BudgetEntity?
    func getRemainingBudgetExpirationDate() async -> TimeInterval?
    func saveBudget(_ budget: BudgetModel) async -> Bool
    func updateBudget(_ budget: BudgetModel) async -> Bool
    func deleteBudget(_ budget: BudgetModel) async -> Bool
}

// MARK: - Notification
public protocol NotificationLocalDataSourceRepository: LocalDataSourceRepository {
    func getAllNotifications() async -> [NotificationWithBudgetEntitiy]
    func saveNotification(_ notification: NotificationModel) async -> Bool
}

// MARK: - Transaction
public protocol TransactionLocalDataSourceRepository: LocalDataSourceRepository {
    func getTransactions() async -> [TransactionWithCategoryEntitiy]
    func getTransactions(contain name: String) async -> [TransactionWithCategoryEntitiy]
    func getTransactions(by category: CategoryModel) async -> [TransactionWithCategoryEntitiy]
    func getTransaction(by id: Int64) async -> TransactionWithCategoryEntitiy?
    func getTransaction(by memo: String) async -> TransactionWithCategoryEntitiy?
    func getTransactions(startAt: TimeInterval, endAt: TimeInterval) async -> [TransactionWithCategoryEntitiy]
    func getTotalTransactionAmount(
        for type: TransactionModel.TransactionType,
        startAt: TimeInterval,
        endAt: TimeInterval
    ) async -> Decimal?
    func saveTransaction(_ transaction: TransactionModel) async -> Bool
}
