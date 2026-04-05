//
//  SQLAccessor.swift
//  SolSol
//
//  Created by NUNU:D on 6/4/25.
//

import Foundation
import GRDB
import SolSolCore

public final actor SQLAccessor: SQLAccessable {
    
    private var databasePool: DatabasePool?
    
    public init() async {
        await openDatabase()
    }
    
    fileprivate func getDBpath() throws -> String {
        return try FileManager.default
            .url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("SSDatabase.sqlite")
            .path
    }
    
    fileprivate func checkMigration() throws -> DatabaseMigrator{
        var migrator = DatabaseMigrator()
        let versionMigrator = TableMigratorV1()
        TableMigrationApplier.applyAll(to: &migrator, from: versionMigrator)
        
        return migrator
    }
    
    fileprivate func openDatabase() async {
        do {
            let dbPath = try getDBpath()
            databasePool = try DatabasePool(path: dbPath)
            
            let migrator = try checkMigration()
            try migrator.migrate(databasePool!)
            Log.d("Database Opened Successfully")
        }
        catch {
            Log.e("Database Open Failed \(error)")
        }
    }
    
    public func getDatabase() async -> GRDB.DatabasePool? {
        return databasePool
    }
    
    public func save<T>(to object: T) async -> Bool where T : BaseEntitiy {
        guard let pool = databasePool else { return false }
        do {
            try await pool.write { database in
                try object.insert(database)
            }
            return true
        }
        catch {
            Log.e("DB Insert Failed \(error)")
            return false
        }
    }
    
    public func saveAll<T>(to objects: [T]) async -> Bool where T : BaseEntitiy {
        guard let pool = databasePool else { return false }
        do {
            try await pool.write { database in
                for object in objects {
                    try object.insert(database)
                }
                
            }
            return true
        }
        catch {
            Log.e("DB Insert Failed \(error)")
            return false
        }
    }
    
    public func fetchOne<T>(type: T.Type, rawQuery: String) async -> T? where T : BaseEntitiy {
        guard let pool = databasePool else { return nil }
        do {
            let result = try await pool.read { database in
                try type.fetchOne(database, sql: rawQuery)
            }
            
            return result
        }
        catch {
            Log.e("DB Select Failed \(error)")
            return nil
        }
    }
    
    public func fetchOne<T>(type: T.Type, query: QueryInterfaceRequest<T>) async -> T? where T : BaseEntitiy {
        guard let pool = databasePool else { return nil }
        
        do {
            let result = try await pool.read { database in
                try type.fetchOne(database, query)
            }
            
            return result
        }
        catch {
            Log.e("DB Select Failed \(error)")
            return nil
        }
    }
    
    public func fetchAll<T>(type: T.Type, rawQuery: String) async -> [T]? where T : BaseEntitiy {
        guard let pool = databasePool else { return nil }
        do {
            let result = try await pool.read { database in
                try type.fetchAll(database, sql: rawQuery)
            }
            
            return result
        }
        catch {
            Log.e("DB Select Failed \(error)")
            return nil
        }
    }
    
    public func fetchAll<T>(type: T.Type, query: QueryInterfaceRequest<T>) async -> [T]? where T : BaseEntitiy {
        guard let pool = databasePool else { return [] }
        
        do {
            let result = try await pool.read { database in
                try type.fetchAll(database, query)
            }
            
            return result
        }
        catch {
            Log.e("DB Select Failed \(error)")
            return nil
        }
    }
    
    public func updateOne<T>(to object: T) async -> Bool where T : BaseEntitiy {
        guard let pool = databasePool else { return false }
        do {
            try await pool.write { database in
                try object.update(database)
            }
            
            return true
        }
        catch {
            Log.e("DB Update Failed \(error)")
            return false
        }
    }
    
    public func updateAll<T>(type: T.Type, queryRequest: QueryInterfaceRequest<T>) async -> Bool where T : BaseEntitiy {
        guard let pool = databasePool else { return false }
        
        do {
            let result = try await pool.write { database in
                try queryRequest.updateAll(database)
            }
            
            return (result != 0)
        }
        catch {
            Log.e("DB Update Failed \(error)")
            return false
        }
    }
    
    public func deleteOne<T>(to object: T) async -> Bool where T : BaseEntitiy {
        guard let pool = databasePool else { return false }
        do {
            let result = try await pool.write { database in
                try object.delete(database)
            }
            
            return result
        }
        catch {
            Log.e("DB delete Failed \(error)")
            return false
        }
    }
    
    public func deleteAll<T>(type: T.Type, filter: SQLExpression?) async -> Bool where T : BaseEntitiy {
        guard let pool = databasePool else { return false }
        do {
            let result = try await pool.write { database in
                if let filter = filter {
                    try type.filter(filter).deleteAll(database)
                }
                else {
                    try type.deleteAll(database)
                }
            }
            
            return (result != 0)
        }
        catch {
            Log.e("DB delete Failed \(error)")
            return false
        }
    }
    
    public nonisolated func observeAll<T>(type: T.Type, query: QueryInterfaceRequest<T>?, observeTable: [Table<any PersistableRecord>]?)-> ValueObservation<ValueReducers.Fetch<[T]?>> where T : BaseEntitiy {
        let queryRequest = query ?? type.all()
        
        guard let observeTable = observeTable else {
            return ValueObservation.tracking { database in
                try queryRequest.fetchAll(database)
            }
        }
        
        return ValueObservation.tracking(regions: observeTable) { database in
            try queryRequest.fetchAll(database)
        }
        
    }
    
    public nonisolated func observeOne<T>(type: T.Type, query: QueryInterfaceRequest<T>?, observeTable: [Table<any PersistableRecord>]?) -> ValueObservation<ValueReducers.Fetch<T?>> where T : BaseEntitiy {
        let queryRequest = query ?? type.all()
        
        guard let observeTable = observeTable else {
            return ValueObservation.tracking { database in
                
                try queryRequest.fetchOne(database)
            }
        }
        
        return ValueObservation.tracking(regions: observeTable) { database in
            try queryRequest.fetchOne(database)
        }
    }
    
}
