//
//  SQLAccessable.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import Foundation
import GRDB

public protocol SQLAccessAdapterable {}

public protocol SQLAccessable: SQLAccessAdapterable {
    func getDatabase() async -> DatabasePool?
    func save<T: BaseEntitiy>(to object: T) async -> Bool
    func saveAll<T: BaseEntitiy>(to objects: [T]) async -> Bool
    func fetchOne<T: BaseEntitiy>(type: T.Type, rawQuery: String) async -> T?
    func fetchOne<T: BaseEntitiy>(type: T.Type, query: QueryInterfaceRequest<T>) async -> T?
    func fetchAll<T: BaseEntitiy>(type: T.Type, rawQuery: String) async -> [T]?
    func fetchAll<T: BaseEntitiy>(type: T.Type, query: QueryInterfaceRequest<T>) async -> [T]?
    func updateOne<T: BaseEntitiy>(to object: T) async -> Bool
    func updateAll<T: BaseEntitiy>(type: T.Type, queryRequest: QueryInterfaceRequest<T>) async -> Bool
    func deleteOne<T: BaseEntitiy>(to object: T) async -> Bool
    func deleteAll<T: BaseEntitiy>(type: T.Type, filter: SQLExpression?) async -> Bool
    nonisolated func observeAll<T: BaseEntitiy>(type: T.Type, query: QueryInterfaceRequest<T>?, observeTable: [Table<any PersistableRecord>]?) -> ValueObservation<ValueReducers.Fetch<[T]?>>
    nonisolated func observeOne<T: BaseEntitiy>(type: T.Type, query: QueryInterfaceRequest<T>?, observeTable: [Table<any PersistableRecord>]?) -> ValueObservation<ValueReducers.Fetch<T?>>
}
