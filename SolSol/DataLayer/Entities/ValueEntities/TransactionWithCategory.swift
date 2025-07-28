//
//  TransactionWithCategory.swift
//  SolSol
//
//  Created by NUNU:D on 7/29/25.
//

import Foundation
import GRDB

public struct TransactionWithCategory: Decodable, FetchableRecord, PersistableRecord {
    public var transaction: TransactionEntity
    public var category: CategoryEntitiy
}
