//
//  TransactionModel.swift
//  SolSol
//
//  Created by NUNU:D on 7/2/25.
//

import Foundation

public struct TransactionModel: BaseModel {
    private(set)var id: Int64
    public var userId: String
    public var category: CategoryModel
    public var amount: Double
    public var createdAt: Date
    public var memo: String?
    public var name: String
    
    init(
        id: Int64,
        userId: String,
        category: CategoryModel,
        amount: Double,
        createdAt: Date,
        memo: String? = nil,
        name: String
    ) {
        self.id = id
        self.userId = userId
        self.category = category
        self.amount = amount
        self.createdAt = createdAt
        self.memo = memo
        self.name = name
    }
}
