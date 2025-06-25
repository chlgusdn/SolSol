//
//  UserRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation
import Combine

public final class UserRepositoryImpl: UserRepositoryProtocol {
    
    let localDataSource: UserLocalDataSourceRepository
    
    init(localDataSource: UserLocalDataSourceRepository) {
        self.localDataSource = localDataSource
    }
    
    public func getUser() -> AnyPublisher<UserModel, any Error> {
        return Publishers.Async {
            guard let result = await self.localDataSource.getUser() else {
                throw NSError(domain: "", code: -1)
            }
            return UserMapper.toDomain(to: result)
        }
        .eraseToAnyPublisher()
    }
    
    public func getUsers() -> AnyPublisher<[UserModel], any Error> {
        return Publishers.Async {
            let result = await self.localDataSource.getUsers()
            return result.map { UserMapper.toDomain(to: $0) }
        }
        .eraseToAnyPublisher()
    }
    
    public func saveUser(user: UserModel) -> AnyPublisher<Bool, any Error> {
        return Publishers.Async {
            return await self.localDataSource.saveUser(user)
        }
        .eraseToAnyPublisher()
    }
    
    public func saveUsers(users: [UserModel]) -> AnyPublisher<Bool, any Error> {
        return Publishers.Async {
            return await self.localDataSource.saveUsers(users: users)
        }
        .eraseToAnyPublisher()
    }
    
    public func updateUser(user: UserModel) -> AnyPublisher<Bool, any Error> {
        return Publishers.Async {
            return await self.localDataSource.updateUser(user)
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteUser(user: UserModel) -> AnyPublisher<Bool, any Error> {
        return Publishers.Async {
            return await self.localDataSource.deleteUser(user)
        }
        .eraseToAnyPublisher()
    }
}
