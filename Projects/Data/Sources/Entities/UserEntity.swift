//
//  UserEntity.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

public struct UserEntity: BaseEntitiy {
    public var id: Int64?
    public var createdAt: TimeInterval

    public enum Columns: String, ColumnExpression {
        case id
        case createdAt
    }

    public init(
        id: Int64? = nil,
        createdAt: TimeInterval
    ) {
        self.id = id
        self.createdAt = createdAt
    }
}
