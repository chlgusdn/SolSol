import Domain
import Foundation
import SQLiteData
import Testing
@testable import Data

struct TransactionDAOTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }()

    private func makeDAO() throws -> TransactionDAO {
        let database = try DatabaseQueue()
        try migrate(database)
        return TransactionDAO(database: database)
    }

    private func date(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12))!
    }

    @Test func save_thenFetchMonth_returnsOnlyThatMonth() async throws {
        let dao = try makeDAO()
        let march = DateInterval.month(containing: date(3, 1), calendar: calendar)
        let inMarch = Transaction(id: UUID(), type: .expense, amount: 12_000, category: .food, memo: "점심", date: date(3, 10))
        let inApril = Transaction(id: UUID(), type: .expense, amount: 5_000, category: .etc, date: date(4, 1))

        try await dao.save(inMarch)
        try await dao.save(inApril)

        #expect(try await dao.fetchMonth(march) == [inMarch])
    }

    @Test func save_existingId_updates() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        var transaction = Transaction(id: UUID(), type: .expense, amount: 1_000, category: .food, date: date(3, 2))
        try await dao.save(transaction)

        transaction.amount = 2_000
        try await dao.save(transaction)

        #expect(try await dao.fetchMonth(month) == [transaction])
    }

    @Test func fetchSummary_aggregatesInSQL() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        try await dao.save(Transaction(id: UUID(), type: .income, amount: 3_000_000, category: .salary, date: date(3, 25)))
        try await dao.save(Transaction(id: UUID(), type: .expense, amount: 12_000, category: .food, date: date(3, 3)))
        try await dao.save(Transaction(id: UUID(), type: .expense, amount: 8_000, category: .transport, date: date(3, 4)))
        try await dao.save(Transaction(id: UUID(), type: .expense, amount: 99_999, category: .etc, date: date(4, 1)))

        #expect(try await dao.fetchSummary(month) == TransactionSummary(income: 3_000_000, expense: 20_000))
    }

    @Test func fetchSummary_emptyMonth_isZero() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        #expect(try await dao.fetchSummary(month) == .zero)
    }

    @Test func delete_removesRow() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        let transaction = Transaction(id: UUID(), type: .expense, amount: 1_000, category: .food, date: date(3, 2))
        try await dao.save(transaction)

        try await dao.delete(transaction.id)

        #expect(try await dao.fetchMonth(month).isEmpty)
    }

    @Test func observeMonth_emitsOnChange() async throws {
        let dao = try makeDAO()
        let month = DateInterval.month(containing: date(3, 1), calendar: calendar)
        let transaction = Transaction(id: UUID(), type: .expense, amount: 1_000, category: .food, date: date(3, 2))

        var iterator = dao.observeMonth(month).makeAsyncIterator()
        #expect(try await iterator.next() == [])

        try await dao.save(transaction)
        #expect(try await iterator.next() == [transaction])
    }
}
