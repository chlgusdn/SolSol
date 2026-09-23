import SQLiteData

/// v2 — UI/UX 기획서 데이터 모델
/// - 카테고리 테이블 + 기본 카테고리 (id 고정)
/// - 거래: 카테고리 문자열 → categoryID, title / isFixed 추가 (테이블 재생성)
/// - 고정 지출, 예산, 앱 설정 테이블
///
/// 값은 모두 SQL 리터럴로 고정한다. Domain 기본값이 나중에 바뀌어도 이 마이그레이션 결과는 바뀌지 않아야 한다.
func migrateV2(_ db: Database) throws {
    try db.execute(sql: """
        CREATE TABLE "categoryRecords" (
            "id" TEXT PRIMARY KEY NOT NULL,
            "type" TEXT NOT NULL CHECK ("type" IN ('income', 'expense')),
            "name" TEXT NOT NULL CHECK (length("name") BETWEEN 1 AND 8),
            "colorKey" TEXT NOT NULL,
            "iconKey" TEXT NOT NULL,
            "isDefault" INTEGER NOT NULL DEFAULT 0 CHECK ("isDefault" IN (0, 1)),
            "sortOrder" INTEGER NOT NULL DEFAULT 0
        ) STRICT
        """)
    try db.execute(sql: """
        INSERT INTO "categoryRecords" ("id", "type", "name", "colorKey", "iconKey", "isDefault", "sortOrder") VALUES
            ('00000000-0000-0000-0000-000000000100', 'income', '수입', 'brand', 'money', 1, 0),
            ('00000000-0000-0000-0000-000000000201', 'expense', '식비', 'red', 'food', 1, 1),
            ('00000000-0000-0000-0000-000000000202', 'expense', '카페', 'amber', 'cafe', 1, 2),
            ('00000000-0000-0000-0000-000000000203', 'expense', '교통', 'green', 'transport', 1, 3),
            ('00000000-0000-0000-0000-000000000204', 'expense', '쇼핑', 'purple', 'shopping', 1, 4),
            ('00000000-0000-0000-0000-000000000205', 'expense', '레저', 'blue', 'leisure', 1, 5),
            ('00000000-0000-0000-0000-000000000206', 'expense', '구독', 'blue', 'repeat', 1, 6)
        """)

    // v1 카테고리 중 기본 카테고리에 없는 것은, 실제로 쓰인 경우에만 사용자 카테고리로 옮긴다
    try db.execute(sql: """
        INSERT INTO "categoryRecords" ("id", "type", "name", "colorKey", "iconKey", "isDefault", "sortOrder")
        SELECT '00000000-0000-0000-0000-000000000301', 'expense', '생활', 'green', 'tag', 0, 7
        WHERE EXISTS (SELECT 1 FROM "transactionRecords" WHERE "type" = 'expense' AND "category" = 'living')
        """)
    try db.execute(sql: """
        INSERT INTO "categoryRecords" ("id", "type", "name", "colorKey", "iconKey", "isDefault", "sortOrder")
        SELECT '00000000-0000-0000-0000-000000000302', 'expense', '의료/건강', 'purple', 'tag', 0, 8
        WHERE EXISTS (SELECT 1 FROM "transactionRecords" WHERE "type" = 'expense' AND "category" = 'health')
        """)
    try db.execute(sql: """
        INSERT INTO "categoryRecords" ("id", "type", "name", "colorKey", "iconKey", "isDefault", "sortOrder")
        SELECT '00000000-0000-0000-0000-000000000303', 'expense', '기타', 'blue', 'tag', 0, 9
        WHERE EXISTS (
            SELECT 1 FROM "transactionRecords"
            WHERE "type" = 'expense'
              AND "category" NOT IN ('food', 'transport', 'shopping', 'culture', 'living', 'health')
        )
        """)

    try db.execute(sql: """
        CREATE TABLE "transactionRecords_v2" (
            "id" TEXT PRIMARY KEY NOT NULL,
            "type" TEXT NOT NULL CHECK ("type" IN ('income', 'expense')),
            "amount" INTEGER NOT NULL CHECK ("amount" >= 0),
            "categoryID" TEXT NOT NULL REFERENCES "categoryRecords"("id") ON DELETE RESTRICT,
            "title" TEXT NOT NULL DEFAULT '',
            "memo" TEXT NOT NULL DEFAULT '',
            "date" TEXT NOT NULL,
            "isFixed" INTEGER NOT NULL DEFAULT 0 CHECK ("isFixed" IN (0, 1))
        ) STRICT
        """)
    // v1의 memo는 화면에서 제목 역할을 했으므로 title로 옮긴다
    try db.execute(sql: """
        INSERT INTO "transactionRecords_v2" ("id", "type", "amount", "categoryID", "title", "memo", "date", "isFixed")
        SELECT
            "id", "type", "amount",
            CASE
                WHEN "type" = 'income' THEN '00000000-0000-0000-0000-000000000100'
                WHEN "category" = 'food' THEN '00000000-0000-0000-0000-000000000201'
                WHEN "category" = 'transport' THEN '00000000-0000-0000-0000-000000000203'
                WHEN "category" = 'shopping' THEN '00000000-0000-0000-0000-000000000204'
                WHEN "category" = 'culture' THEN '00000000-0000-0000-0000-000000000205'
                WHEN "category" = 'living' THEN '00000000-0000-0000-0000-000000000301'
                WHEN "category" = 'health' THEN '00000000-0000-0000-0000-000000000302'
                ELSE '00000000-0000-0000-0000-000000000303'
            END,
            CASE
                WHEN "memo" <> '' THEN "memo"
                WHEN "type" = 'income' THEN '수익'
                ELSE '지출'
            END,
            '', "date", 0
        FROM "transactionRecords"
        """)
    try db.execute(sql: #"DROP TABLE "transactionRecords""#)
    try db.execute(sql: #"ALTER TABLE "transactionRecords_v2" RENAME TO "transactionRecords""#)
    try db.execute(sql: #"CREATE INDEX "idx_transactionRecords_date" ON "transactionRecords"("date")"#)
    try db.execute(sql: #"CREATE INDEX "idx_transactionRecords_categoryID" ON "transactionRecords"("categoryID")"#)

    try db.execute(sql: """
        CREATE TABLE "fixedExpenseRecords" (
            "id" TEXT PRIMARY KEY NOT NULL,
            "name" TEXT NOT NULL CHECK (length("name") >= 1),
            "amount" INTEGER NOT NULL CHECK ("amount" > 0),
            "isEnabled" INTEGER NOT NULL DEFAULT 1 CHECK ("isEnabled" IN (0, 1)),
            "sortOrder" INTEGER NOT NULL DEFAULT 0
        ) STRICT
        """)
    try db.execute(sql: """
        CREATE TABLE "budgetRecords" (
            "id" INTEGER PRIMARY KEY NOT NULL CHECK ("id" = 1),
            "amount" INTEGER NOT NULL CHECK ("amount" > 0),
            "startDate" TEXT NOT NULL,
            "dueDate" TEXT NOT NULL,
            "warnAmount" INTEGER NOT NULL,
            "dangerAmount" INTEGER NOT NULL,
            CHECK ("warnAmount" > 0 AND "warnAmount" < "dangerAmount" AND "dangerAmount" <= "amount"),
            CHECK ("startDate" <= "dueDate")
        ) STRICT
        """)
    try db.execute(sql: """
        CREATE TABLE "appSettings" (
            "key" TEXT PRIMARY KEY NOT NULL,
            "value" TEXT NOT NULL
        ) STRICT
        """)
}
