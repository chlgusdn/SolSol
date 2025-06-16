//
//  CategoryEntitiy.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

public struct CategoryEntitiy: BaseEntitiy {
    
    public var id: Int64?
    public var categoryName: String
    public var categoryType: Int
    
    public enum Columns: String, ColumnExpression {
        case id
        case categoryName
        case categoryType
    }
    
    public init(
        id: Int64? = nil,
        categoryName: String,
        categoryType: Int
    ) {
        self.id = id
        self.categoryName = categoryName
        self.categoryType = categoryType
    }
}
