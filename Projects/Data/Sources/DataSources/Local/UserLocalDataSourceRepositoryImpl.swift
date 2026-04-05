//
//  UserLocalDataSourceRepositoryImpl.swift
//  SolSol
//
//  Created by NUNU:D on 6/15/25.
//

import Foundation
import Domain

public final class UserLocalDataSourceRepositoryImpl: UserLocalDataSourceRepository {
    
    let accessor: SQLAccessor
    
    public init(accessor: SQLAccessor) throws {
        self.accessor = accessor
    }
    
    public func getUser() async -> UserEntity? {
        let sql = "SELECT * FROM \(UserEntity.databaseTableName) ORDER BY \(UserEntity.Columns.id) DESC LIMIT 1"
        return await self.accessor.fetchOne(type: UserEntity.self, rawQuery: sql)
    }
    
    public func getUsers() async -> [UserEntity] {
        let sql = "SELECT * FROM \(UserEntity.databaseTableName) ORDER BY \(UserEntity.Columns.id) DESC"
        return await self.accessor.fetchAll(type: UserEntity.self, rawQuery: sql) ?? []
    }
    
    public func saveUser(_ user: UserModel) async -> Bool {
        let entitiy = UserMapper.toLocal(to: user)
        return await self.accessor.save(to: entitiy)
    }
    
    public func saveUsers(users: [UserModel]) async -> Bool {
        let entities = users.map { user in
            return UserMapper.toLocal(to: user)
        }
        return await self.accessor.saveAll(to: entities)
    }
    
    public func updateUser(_ user: UserModel) async -> Bool {
        let entity = UserMapper.toLocal(to: user)
        return await self.accessor.updateOne(to: entity)
    }
    
    public func deleteUser(_ user: UserModel) async -> Bool {
        let entity = UserMapper.toLocal(to: user)
        return await self.accessor.deleteOne(to: entity)
    }
}
