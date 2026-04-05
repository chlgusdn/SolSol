//
//  UserRepositoryProtocol.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation
import Combine

public protocol UserRepositoryProtocol {
    func getUser() async throws -> UserModel
    func getUsers() async throws -> [UserModel]
    func saveUser(user: UserModel) async -> Bool
    func saveUsers(users: [UserModel]) async -> Bool
    func updateUser(user: UserModel) async -> Bool
    func deleteUser(user: UserModel) async -> Bool
}
