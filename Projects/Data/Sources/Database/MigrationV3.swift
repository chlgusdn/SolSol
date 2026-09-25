import SQLiteData

/// v3 — 텅장방지 알림·결과 기록
/// - 예산에 이미 알린 단계(`notifiedStatus`)를 둔다. 선을 넘을 때 단계마다 한 번만 알리기 위해서
/// - 끝난 예산의 결과를 `budgetResults`에 쌓는다. 다음 예산을 정할 때 직전 결과를 보여준다
func migrateV3(_ db: Database) throws {
    try db.execute(sql: """
        ALTER TABLE "budgetRecords" ADD COLUMN "notifiedStatus" TEXT
            CHECK ("notifiedStatus" IN ('warning', 'danger', 'exceeded'))
        """)
    try db.execute(sql: """
        CREATE TABLE "budgetResults" (
            "id" TEXT PRIMARY KEY NOT NULL,
            "amount" INTEGER NOT NULL CHECK ("amount" > 0),
            "startDate" TEXT NOT NULL,
            "dueDate" TEXT NOT NULL,
            "spent" INTEGER NOT NULL CHECK ("spent" >= 0),
            "closedAt" TEXT NOT NULL,
            CHECK ("startDate" <= "dueDate")
        ) STRICT
        """)
    try db.execute(sql: """
        CREATE INDEX "idx_budgetResults_closedAt" ON "budgetResults"("closedAt")
        """)
}
