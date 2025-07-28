//
//  MockSQLAccessor.swift
//  SolSolTests
//
//  Created by NUNU:D on 7/5/25.
//

import Foundation
import GRDB
import Combine
import SolSol
/*
/// 테스트용 MockSQLAccessor - 실제 데이터베이스 없이 메모리에서 동작
public final actor MockSQLAccessor: SQLAccessable {
    
    // MARK: - Private Properties
    private var mockDatabase: [String: [Any]] = [:]
    private var idCounters: [String: Int] = [:]
    private var mockDatabasePool: DatabaseQueue?
    
    // MARK: - Mock Control Properties
    private var shouldFailOnSave = false
    private var shouldFailOnFetch = false
    private var shouldFailOnUpdate = false
    private var shouldFailOnDelete = false
    
    // MARK: - Initialization
    init() async {
        await setupInMemoryDatabase()
    }
    
    // MARK: - Mock Control Methods
    func setShouldFailOnSave(_ shouldFail: Bool) {
        shouldFailOnSave = shouldFail
    }
    
    func setShouldFailOnFetch(_ shouldFail: Bool) {
        shouldFailOnFetch = shouldFail
    }
    
    func setShouldFailOnUpdate(_ shouldFail: Bool) {
        shouldFailOnUpdate = shouldFail
    }
    
    func setShouldFailOnDelete(_ shouldFail: Bool) {
        shouldFailOnDelete = shouldFail
    }
    
    // MARK: - Test Helper Methods
    func clearAllData() {
        mockDatabase.removeAll()
        idCounters.removeAll()
    }
    
    func getDataCount<T>(for type: T.Type) -> Int where T: PersistableRecord {
        let tableName = String(describing: type)
        return mockDatabase[tableName]?.count ?? 0
    }
    
    func getAllData<T>(for type: T.Type) -> [T] where T: PersistableRecord {
        let tableName = String(describing: type)
        return mockDatabase[tableName] as? [T] ?? []
    }
    
    // MARK: - Private Helper Methods
    private func setupInMemoryDatabase() async {
        do {
            // 인메모리 데이터베이스 생성 (실제 테스트에서 스키마가 필요한 경우)
            mockDatabasePool = try DatabaseQueue()
        }
        catch {
            Log.e("Mock Database Setup Failed \(error)")
        }
    }
    
    private func getTableName<T>(for type: T.Type) -> String where T: PersistableRecord {
        return String(describing: type)
    }
    
    private func generateId<T>(for type: T.Type) -> Int where T: PersistableRecord {
        let tableName = getTableName(for: type)
        let currentId = idCounters[tableName] ?? 0
        let newId = currentId + 1
        idCounters[tableName] = newId
        return newId
    }
    
    // MARK: - SQLAccessable Implementation
    public func getDatabase() async -> DatabasePool? {
        return mockDatabasePool
    }
    
    public func save<T>(to object: T) async -> Bool where T: PersistableRecord {
        guard !shouldFailOnSave else { return false }
        
        let tableName = getTableName(for: object)
        
        if mockDatabase[tableName] == nil {
            mockDatabase[tableName] = []
        }
        
        // 새로운 객체 추가
        mockDatabase[tableName]?.append(object)
        
        Log.d("Mock: Saved object to \(tableName)")
        return true
    }
    
    public func saveAll<T>(to objects: [T]) async -> Bool where T: PersistableRecord {
        guard !shouldFailOnSave else { return false }
        guard !objects.isEmpty else { return true }
        
        let tableName = getTableName(for: objects[0])
        
        if mockDatabase[tableName] == nil {
            mockDatabase[tableName] = []
        }
        
        for object in objects {
            mockDatabase[tableName]?.append(object)
        }
        
        Log.d("Mock: Saved \(objects.count) objects to \(tableName)")
        return true
    }
    
    public func fetchOne<T>(type: T.Type, rawQuery: String) async -> T? where T: FetchableRecord, T: PersistableRecord {
        guard !shouldFailOnFetch else { return nil }
        
        let tableName = getTableName(for: type)
        guard let data = mockDatabase[tableName] as? [T] else { return nil }
        
        // 간단한 쿼리 파싱 (실제 프로덕션에서는 더 복잡한 구현 필요)
        Log.d("Mock: Fetching one from \(tableName) with query: \(rawQuery)")
        return data.first
    }
    
    public func fetchOne<T>(type: T.Type, query: QueryInterfaceRequest<T>) async -> T? where T: FetchableRecord, T: PersistableRecord {
        guard !shouldFailOnFetch else { return nil }
        
        let tableName = getTableName(for: type)
        guard let data = mockDatabase[tableName] as? [T] else { return nil }
        
        Log.d("Mock: Fetching one from \(tableName) with QueryInterfaceRequest")
        return data.first
    }
    
    public func fetchAll<T>(type: T.Type, rawQuery: String) async -> [T]? where T: FetchableRecord, T: PersistableRecord {
        guard !shouldFailOnFetch else { return nil }
        
        let tableName = getTableName(for: type)
        guard let data = mockDatabase[tableName] as? [T] else { return [] }
        
        Log.d("Mock: Fetching all from \(tableName) with query: \(rawQuery)")
        return data
    }
    
    public func fetchAll<T>(type: T.Type, query: QueryInterfaceRequest<T>) async -> [T]? where T: FetchableRecord, T: PersistableRecord {
        guard !shouldFailOnFetch else { return nil }
        
        let tableName = getTableName(for: type)
        guard let data = mockDatabase[tableName] as? [T] else { return [] }
        
        Log.d("Mock: Fetching all from \(tableName) with QueryInterfaceRequest")
        return data
    }
    
    public func updateOne<T>(to object: T) async -> Bool where T: PersistableRecord {
        guard !shouldFailOnUpdate else { return false }
        
        let tableName = getTableName(for: object)
        
        // 실제 구현에서는 Primary Key를 이용해 업데이트해야 함
        // 여기서는 간단히 첫 번째 객체를 대체
        if var data = mockDatabase[tableName] as? [T], !data.isEmpty {
            data[0] = object
            mockDatabase[tableName] = data
            Log.d("Mock: Updated object in \(tableName)")
            return true
        }
        
        return false
    }
    
    public func updateAll<T>(type: T.Type, queryRequest: QueryInterfaceRequest<T>) async -> Bool where T: PersistableRecord {
        guard !shouldFailOnUpdate else { return false }
        
        let tableName = getTableName(for: type)
        
        Log.d("Mock: Updated all in \(tableName) with QueryInterfaceRequest")
        return mockDatabase[tableName] != nil
    }
    
    public func deleteOne<T>(to object: T) async -> Bool where T: PersistableRecord {
        guard !shouldFailOnDelete else { return false }
        
        let tableName = getTableName(for: object)
        
        if var data = mockDatabase[tableName] as? [T], !data.isEmpty {
            data.removeFirst()
            mockDatabase[tableName] = data
            Log.d("Mock: Deleted object from \(tableName)")
            return true
        }
        
        return false
    }
    
    public func deleteAll<T>(type: T.Type, filter: SQLExpression?) async -> Bool where T: PersistableRecord {
        guard !shouldFailOnDelete else { return false }
        
        let tableName = getTableName(for: type)
        
        if filter == nil {
            // 모든 데이터 삭제
            mockDatabase[tableName] = []
            Log.d("Mock: Deleted all from \(tableName)")
            return true
        } else {
            // 필터가 있는 경우 (간단한 구현)
            if let data = mockDatabase[tableName], !data.isEmpty {
                mockDatabase[tableName] = []
                Log.d("Mock: Deleted filtered data from \(tableName)")
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Observation Methods (Mock Implementation)
    public nonisolated func observeAll<T>(
        type: T.Type,
        query: QueryInterfaceRequest<T>?,
        observeTable: [Table<any PersistableRecord>]?
    ) -> ValueObservation<ValueReducers.Fetch<[T]?>> where T: FetchableRecord, T: PersistableRecord, T: Sendable {
        
        // Mock 구현: 실제 관찰 대신 빈 결과 반환
        return ValueObservation.tracking { _ in
            return [] as [T]?
        }
    }
    
    public nonisolated func observeOne<T>(
        type: T.Type,
        query: QueryInterfaceRequest<T>?,
        observeTable: [Table<any PersistableRecord>]?
    ) -> ValueObservation<ValueReducers.Fetch<T?>> where T: FetchableRecord, T: PersistableRecord, T: Sendable {
        
        // Mock 구현: 실제 관찰 대신 nil 반환
        return ValueObservation.tracking { _ in
            return nil as T?
        }
    }
}
*/
