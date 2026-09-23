import Domain
import Foundation
import SQLiteData
import Testing
@testable import Data

struct TransactionDAOTests {
    private let calendar = TestCalendar.seoul

    private func makeDAO() throws -> TransactionDAO {
        TransactionDAO(database: try TestDatabase.make())
    }

    private func date(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12))!
    }

    private func expense(_ amount: Int, _ category: TransactionCategory = .Default.food, on date: Date) -> Transaction {
        Transaction(id: UUID(), type: .expense, amount: amount, category: category, title: "지출", date: date)
    }

    @Test func save_thenFetchMonth_returnsOnlyThatMonthWithCategory() async throws {
        let dao = try makeDAO()
        let march = DateInterval.month(containing: date(3, 1), calendar: calendar)
        let inMarch = Transaction(
            id: UUID(), type: .expense, amount: 4_500, category: .Default.cafe,
            title: "아메리카노", memo: "회사 앞", date: date(3, 10), isFixed: true
        )
        try await dao.save(inMarch)
        try await dao.save(expense(5_000, on: date(4, 1)))

        #expect(try await dao.fetchMonth(march) == [inMarch])
    }

    @Test func save_existingId_updates() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        var transaction = expense(1_000, on: date(3, 2))
        try await dao.save(transaction)

        transaction.amount = 2_000
        transaction.category = .Default.transport
        try await dao.save(transaction)

        #expect(try await dao.fetchMonth(month) == [transaction])
    }

    @Test func save_unknownCategory_failsForeignKey() async throws {
        let dao = try makeDAO()
        let unknown = TransactionCategory(id: UUID(), type: .expense, name: "없음", colorKey: "red", sortOrder: 99)
        await #expect(throws: (any Error).self) {
            try await dao.save(expense(1_000, unknown, on: date(3, 2)))
        }
    }

    @Test func fetchSummary_aggregatesInSQL() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        try await dao.save(Transaction(id: UUID(), type: .income, amount: 3_000_000, category: .Default.income, title: "월급", date: date(3, 25)))
        try await dao.save(expense(12_000, on: date(3, 3)))
        try await dao.save(expense(8_000, .Default.transport, on: date(3, 4)))
        try await dao.save(expense(99_999, on: date(4, 1)))

        #expect(try await dao.fetchSummary(month) == TransactionSummary(income: 3_000_000, expense: 20_000))
    }

    @Test func fetchSummary_emptyMonth_isZero() async throws {
        let dao = try makeDAO()
        #expect(try await dao.fetchSummary(DateInterval.month(containing: date(3, 1), calendar: calendar)) == .zero)
    }

    @Test func delete_removesRow() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        let transaction = expense(1_000, on: date(3, 2))
        try await dao.save(transaction)

        try await dao.delete(transaction.id)

        #expect(try await dao.fetchMonth(month).isEmpty)
    }

    @Test func observeMonth_emitsOnChange() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        let transaction = expense(1_000, on: date(3, 2))

        var iterator = dao.observeMonth(month).makeAsyncIterator()
        #expect(try await iterator.next() == [])

        try await dao.save(transaction)
        #expect(try await iterator.next() == [transaction])
    }
}
