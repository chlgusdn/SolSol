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
public protocol BudgetLocalDataSourceRepository: LocalDataSourceRepository {}

