//
//  TransactionEntity.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

/// 거래내역
public struct TransactionEntity: BaseEntitiy {

    public var id: Int64?
    public var userId: String
    public var categoryId: Int64
    public var amount: Double
    public var createdAt: TimeInterval
    public var memo: String?
    public var name: String
    public var type: Int

    public enum Columns: String, ColumnExpression {
        case id
        case userId
        case categoryId
        case amount
        case createdAt
        case memo
        case name
        case type
    }

    public init(
        id: Int64? = nil,
        userId: String,
        categoryId: Int64,
        amount: Double,
        createdAt: TimeInterval,
        memo: String?,
        name: String,
        type: Int
    ) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.amount = amount
        self.createdAt = createdAt
        self.memo = memo
        self.name = name
        self.type = type
    }
}

public extension TransactionEntity {
    /// N: 1 관계
    static let category = belongsTo(CategoryEntitiy.self, key: TransactionEntity.Columns.categoryId.rawValue)
}
