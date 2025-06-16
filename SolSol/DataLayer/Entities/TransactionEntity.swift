//
//  TransactionEntity.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

public struct TransactionEntity: BaseEntitiy {
    
    public var id: Int64?
    public var userId: String
    public var categoryId: Int64
    public var amount: Double
    public var createdAt: TimeInterval
    
    public enum Columns: String, ColumnExpression {
        case id
        case userId
        case categoryId
        case amount
        case createdAt
    }
    
    public init(
        id: Int64? = nil,
        userId: String,
        categoryId: Int64,
        amount: Double,
        createdAt: TimeInterval
    ) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.amount = amount
        self.createdAt = createdAt
    }
}
