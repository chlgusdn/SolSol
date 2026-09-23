import Core
import Dependencies
import Foundation
import OSLog
import SQLiteData

/// 앱 DB 생성 + 마이그레이션. App 진입점에서 한 번만 호출한다.
public func appDatabase() throws -> any DatabaseWriter {
    let database = try defaultDatabase()
    Logger.database.info("Database opened")
    try migrate(database)
    return database
}

/// 스키마 마이그레이션. 스키마 변경은 새 마이그레이션을 추가한다 (기존 마이그레이션 수정 금지).
func migrate(_ database: any DatabaseWriter) throws {
    var migrator = DatabaseMigrator()
    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("v1_create_tables") { db in
        try db.execute(sql: """
            CREATE TABLE "transactionRecords" (
                "id" TEXT PRIMARY KEY NOT NULL,
                "type" TEXT NOT NULL CHECK ("type" IN ('income', 'expense')),
                "amount" INTEGER NOT NULL CHECK ("amount" >= 0),
                "category" TEXT NOT NULL,
                "memo" TEXT NOT NULL DEFAULT '',
                "date" TEXT NOT NULL
            ) STRICT
            """)
        try db.execute(sql: """
            CREATE INDEX "idx_transactionRecords_date" ON "transactionRecords"("date")
            """)
    }
    try migrator.migrate(database)
}
