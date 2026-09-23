import Domain
import Foundation
import SQLiteData
import Testing
@testable import Data

struct CategoryDAOTests {
    @Test func add_appendsAtEndOfSameType() async throws {
        let dao = CategoryDAO(database: try TestDatabase.make())
        let delivery = TransactionCategory(id: UUID(), type: .expense, name: "배달", colorKey: "purple", sortOrder: 0)

        try await dao.add(delivery)

        let expenses = try await dao.fetchAll().filter { $0.type == .expense }
        #expect(expenses.last?.id == delivery.id)
        #expect(expenses.last?.sortOrder == TransactionCategory.Default.expenses.count + 1)
        #expect(expenses.last?.isDefault == false)
    }

    @Test func add_nameAcceptedByDomainValidation_isAcceptedByDatabase() async throws {
        let dao = CategoryDAO(database: try TestDatabase.make())
        for raw in ["🇰🇷🇰🇷🇰🇷🇰🇷", "12345678", "배달".decomposedStringWithCanonicalMapping] {
            let name = try #require(TransactionCategory.validatedName(raw))
            try await dao.add(TransactionCategory(id: UUID(), type: .expense, name: name, colorKey: "red", sortOrder: 0))
        }
    }

    @Test func add_nameLongerThanLimit_isRejectedByDatabase() async throws {
        let dao = CategoryDAO(database: try TestDatabase.make())
        let tooLong = TransactionCategory(id: UUID(), type: .expense, name: "123456789", colorKey: "red", sortOrder: 0)
        await #expect(throws: (any Error).self) { try await dao.add(tooLong) }
    }
}

struct FixedExpenseDAOTests {
    @Test func save_appendsThenUpdatesInPlace() async throws {
        let dao = FixedExpenseDAO(database: try TestDatabase.make())
        var netflix = FixedExpense(id: UUID(), name: "넷플릭스", amount: 13_500, sortOrder: 0)
        let rent = FixedExpense(id: UUID(), name: "월세", amount: 500_000, sortOrder: 0)
        try await dao.save(netflix)
        try await dao.save(rent)

        netflix.amount = 17_000
        try await dao.save(netflix)

        let items = try await dao.fetchAll()
        #expect(items.map(\.name) == ["넷플릭스", "월세"])
        #expect(items.map(\.sortOrder) == [0, 1])
        #expect(items.first?.amount == 17_000)
    }

    @Test func setEnabled_andDelete() async throws {
        let dao = FixedExpenseDAO(database: try TestDatabase.make())
        let item = FixedExpense(id: UUID(), name: "통신요금", amount: 55_000, sortOrder: 0)
        try await dao.save(item)

        try await dao.setEnabled(item.id, false)
        #expect(try await dao.fetchAll().first?.isEnabled == false)

        try await dao.delete(item.id)
        #expect(try await dao.fetchAll().isEmpty)
    }
}
