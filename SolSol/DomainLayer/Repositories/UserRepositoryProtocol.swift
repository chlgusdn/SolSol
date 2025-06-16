//
//  UserRepositoryProtocol.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation
import Combine

public protocol UserRepositoryProtocol {
    func getUser() -> AnyPublisher<UserModel, Error>
    func getUsers() -> AnyPublisher<[UserModel], Error>
    func saveUser(user: UserModel) -> AnyPublisher<Bool, Error>
    func saveUsers(users: [UserModel]) -> AnyPublisher<Bool, Error>
    func updateUser(user: UserModel) -> AnyPublisher<Bool, Error>
    func deleteUser(user: UserModel) -> AnyPublisher<Bool, Error>
}
