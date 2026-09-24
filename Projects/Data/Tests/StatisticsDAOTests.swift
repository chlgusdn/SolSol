import Domain
import Foundation
import SQLiteData
import Testing
@testable import Data

struct StatisticsDAOTests {
    private let calendar = TestCalendar.seoul

    private func date(_ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }

    private func day(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
    }

    private func transaction(
        _ type: TransactionType, _ amount: Int, _ category: TransactionCategory = .Default.food, on date: Date
    ) -> Transaction {
        Transaction(
            id: UUID(), type: type, amount: amount,
            category: type == .income ? .Default.income : category,
            title: "\(amount)", date: date
        )
    }

    @Test func snapshot_aggregatesOnlyWithinPeriod() async throws {
        let database = try TestDatabase.make()
        let transactions = TransactionDAO(database: database)
        let coffee1 = transaction(.expense, 4_500, .Default.cafe, on: date(9, 1))
        let coffee2 = transaction(.expense, 5_000, .Default.cafe, on: date(9, 2, hour: 23))
        let shopping = transaction(.expense, 30_000, .Default.shopping, on: date(9, 2, hour: 9))
        let salary = transaction(.income, 3_000_000, on: date(9, 3))
        let outside = transaction(.expense, 999_999, .Default.shopping, on: date(9, 4))
        for item in [coffee1, coffee2, shopping, salary, outside] {
            try await transactions.save(item)
        }
        let period = DateInterval(start: day(9, 1), end: day(9, 4))
        let buckets = [
            DateInterval(start: day(9, 1), end: day(9, 2)),
            DateInterval(start: day(9, 2), end: day(9, 3)),
            DateInterval(start: day(9, 3), end: day(9, 4))
        ]

        let snapshot = try await database.read { db in try StatisticsDAO.snapshot(period, buckets, in: db) }

        #expect(snapshot.bucketTotals == [
            TransactionSummary(income: 0, expense: 4_500),
            TransactionSummary(income: 0, expense: 35_000),
            TransactionSummary(income: 3_000_000, expense: 0)
        ])
        #expect(snapshot.transactionCount == 4)
        #expect(snapshot.largestExpense == shopping)
        #expect(snapshot.largestIncome == salary)
        let byName = Dictionary(uniqueKeysWithValues: snapshot.categoryTotals.map { ($0.category.name, $0) })
        #expect(byName.count == 2)
        #expect(byName["카페"] == CategoryTotal(category: .Default.cafe, amount: 9_500, count: 2))
        #expect(byName["쇼핑"] == CategoryTotal(category: .Default.shopping, amount: 30_000, count: 1))
    }

    @Test func snapshot_emptyPeriod_isEmpty() async throws {
        let database = try TestDatabase.make()
        let period = DateInterval(start: day(9, 1), end: day(9, 2))

        let snapshot = try await database.read { db in try StatisticsDAO.snapshot(period, [period], in: db) }

        #expect(snapshot == StatisticsSnapshot(bucketTotals: [.zero]))
    }

    @Test func observe_emitsAgainWhenTransactionSaved() async throws {
        let database = try TestDatabase.make()
        let dao = StatisticsDAO(database: database)
        let period = DateInterval(start: day(9, 1), end: day(9, 2))
        let lunch = transaction(.expense, 12_000, on: date(9, 1))

        var iterator = dao.observe(period, [period]).makeAsyncIterator()
        #expect(try await iterator.next()?.transactionCount == 0)

        try await TransactionDAO(database: database).save(lunch)
        let updated = try await iterator.next()
        #expect(updated?.transactionCount == 1)
        #expect(updated?.bucketTotals == [TransactionSummary(expense: 12_000)])
    }
}
