//
//  TransactionWithCategoryEntitiy.swift
//  SolSol
//
//  Created by NUNU:D on 7/29/25.
//

import Foundation
import GRDB

public struct TransactionWithCategoryEntitiy: Codable, PersistableRecord, FetchableRecord {
    public var transaction: TransactionEntity
    public var category: CategoryEntitiy
}
