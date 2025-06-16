//
//  Mappable.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation

public protocol Mappable {
    associatedtype DomainType: BaseModel
    associatedtype DataType: BaseEntitiy
    
    static func toDomain(to data: DataType) -> DomainType
    
    static func toLocal(to doamin: DomainType) -> DataType
    
}
