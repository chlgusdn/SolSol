//
//  LocalDataSourceRepository.swift
//  SolSol
//
//  Created by NUNU:D on 6/15/25.
//

import Foundation

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
    func getRemainingBudgetExpirationDate() async -> TimeInterval
    func saveBudget(_ budget: BudgetModel) async -> Bool
    func updateBudget(_ budget: BudgetModel) async -> Bool
    func deleteBudget(_ budget: BudgetModel) async -> Bool
}

//MARK: - Category
public protocol CategoryLocalDataSourceRepository: LocalDataSourceRepository {}

//MARK: - Notification
public protocol NotificationLocalDataSourceRepository: LocalDataSourceRepository {}

//MARK: - Transaction
public protocol TransactionLocalDataSourceRepository: LocalDataSourceRepository {}
