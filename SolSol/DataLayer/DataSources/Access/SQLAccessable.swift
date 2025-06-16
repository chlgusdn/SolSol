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
    func save<T: PersistableRecord>(to object: T) async -> Bool
    func saveAll<T: PersistableRecord>(to objects: [T]) async -> Bool
    func fetchOne<T: PersistableRecord & FetchableRecord>(type: T.Type, rawQuery: String) async -> T?
    func fetchAll<T: PersistableRecord & FetchableRecord>(type: T.Type, rawQuery: String) async -> [T]?
    func updateOne<T: PersistableRecord>(to object: T) async -> Bool
    func updateAll<T: PersistableRecord>(type: T.Type, queryRequest: QueryInterfaceRequest<T>) async -> Bool
    func deleteOne<T: PersistableRecord>(to object: T) async -> Bool
    func deleteAll<T: PersistableRecord>(type: T.Type, filter: SQLExpression?) async -> Bool
    func observeAll<T: PersistableRecord & FetchableRecord>(type: T.Type, query: QueryInterfaceRequest<T>?, observeTable: [Table<any PersistableRecord>]?) -> ValueObservation<ValueReducers.Fetch<[T]?>>
    func observeOne<T: PersistableRecord & FetchableRecord>(type: T.Type, query: QueryInterfaceRequest<T>?, observeTable: [Table<any PersistableRecord>]?) -> ValueObservation<ValueReducers.Fetch<T?>>
}
