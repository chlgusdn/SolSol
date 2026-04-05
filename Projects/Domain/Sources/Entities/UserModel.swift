//
//  UserModel.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation

public struct UserModel: BaseModel {
    public var createdAt: Date
    
    public init(createdAt: Date) {
        self.createdAt = createdAt
    }
}
