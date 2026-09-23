import Foundation
import Testing
@testable import Domain

struct TransactionCalculatorTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }()

    @Test func summary_sumsIncomeAndExpenseSeparately() {
        let date = Date(timeIntervalSince1970: 0)
        let transactions = [
            Transaction(id: UUID(0), type: .income, amount: 3_000_000, category: .salary, date: date),
            Transaction(id: UUID(1), type: .expense, amount: 12_000, category: .food, date: date),
            Transaction(id: UUID(2), type: .expense, amount: 8_000, category: .transport, date: date)
        ]

        let summary = TransactionCalculator.summary(of: transactions)

        #expect(summary == TransactionSummary(income: 3_000_000, expense: 20_000))
        #expect(summary.balance == 2_980_000)
    }

    @Test func signedAmount_isNegativeForExpense() {
        let expense = Transaction(id: UUID(0), type: .expense, amount: 500, category: .etc, date: .distantPast)
        #expect(expense.signedAmount == -500)
    }

    @Test func monthInterval_coversWholeMonth() {
        let date = calendar.date(from: DateComponents(year: 2026, month: 2, day: 14, hour: 13))!
        let month = DateInterval.month(containing: date, calendar: calendar)

        #expect(month.start == calendar.date(from: DateComponents(year: 2026, month: 2, day: 1)))
        #expect(month.end == calendar.date(from: DateComponents(year: 2026, month: 3, day: 1)))
        #expect(month.shiftedMonth(by: -1, calendar: calendar).start
            == calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
    }

    @Test func groupedByDay_sortsNewestFirst() {
        let day1 = calendar.date(from: DateComponents(year: 2026, month: 2, day: 1, hour: 9))!
        let day2 = calendar.date(from: DateComponents(year: 2026, month: 2, day: 2, hour: 9))!
        let transactions = [
            Transaction(id: UUID(0), type: .expense, amount: 1, category: .etc, date: day1),
            Transaction(id: UUID(1), type: .expense, amount: 2, category: .etc, date: day2)
        ]

        let groups = TransactionCalculator.groupedByDay(transactions, calendar: calendar)

        #expect(groups.map(\.day) == [calendar.startOfDay(for: day2), calendar.startOfDay(for: day1)])
    }
}

private extension UUID {
    init(_ value: UInt8) {
        self.init(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, value))
    }
}
