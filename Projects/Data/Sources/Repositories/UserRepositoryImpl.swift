//
//  UserRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation
import Combine
import Domain

public final class UserRepositoryImpl: UserRepositoryProtocol {
    
    let localDataSource: UserLocalDataSourceRepository
    
    public init(localDataSource: UserLocalDataSourceRepository) {
        self.localDataSource = localDataSource
    }

    public func getUser() async throws -> UserModel {
        
        guard let userEntity = await self.localDataSource.getUser() else {
            throw UserError.notFound
        }
        
        return UserMapper.toDomain(to: userEntity)
    }
    
    public func getUsers() async throws -> [UserModel] {
        
        let userEntities = await self.localDataSource.getUsers()
        let users = userEntities.map { entity in
            UserMapper.toDomain(to: entity)
        }
        
        guard users.isEmpty == false else {
            throw UserError.notFound
        }
        
        return users
    }
    
    public func saveUser(user: UserModel) async -> Bool {
        return await self.localDataSource.saveUser(user)
    }
    
    public func saveUsers(users: [UserModel]) async -> Bool {
        return await self.localDataSource.saveUsers(users: users)
    }
    
    public func updateUser(user: UserModel) async -> Bool {
        return await self.localDataSource.updateUser(user)
    }
    
    public func deleteUser(user: UserModel) async -> Bool {
        return await self.localDataSource.deleteUser(user)
    }
}
