//
//  CategoryModel.swift
//  SolSol
//
//  Created by NUNU:D on 7/2/25.
//

import Foundation

public struct CategoryModel: BaseModel {
    public private(set) var id: Int64
    public var categoryName: String
    public var categoryType: Int

    public init(
        id: Int64,
        categoryName: String,
        categoryType: Int
    ) {
        self.id = id
        self.categoryName = categoryName
        self.categoryType = categoryType
    }
}
