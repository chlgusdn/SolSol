//
//  UserMapper.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation

public struct UserMapper: Mappable {
    public typealias DomainType = UserModel
    public typealias DataType = UserEntity
    
    public static func toLocal(to doamin: UserModel) -> UserEntity {
        return UserEntity(createdAt: doamin.createdAt.millisecond)
    }
    
    public static func toDomain(to data: UserEntity) -> UserModel {
        return UserModel(createdAt: Date(timeIntervalSince1970: data.createdAt))
    }
}
