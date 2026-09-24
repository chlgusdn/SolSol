import Foundation
import Testing
@testable import Domain

struct StatisticsCalculatorTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }()

    private func day(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
    }

    @Test func unit_upTo31Days_isDay_longerIsMonth() {
        #expect(StatisticsCalculator.unit(for: DateInterval(start: day(1, 1), end: day(2, 1)), calendar: calendar) == .day)
        #expect(StatisticsCalculator.unit(for: DateInterval(start: day(9, 1), end: day(9, 8)), calendar: calendar) == .day)
        #expect(StatisticsCalculator.unit(for: DateInterval(start: day(1, 1), end: day(2, 2)), calendar: calendar) == .month)
    }

    @Test func bucketIntervals_daily_coverWholePeriod() {
        let period = DateInterval(start: day(9, 1), end: day(9, 4))

        let intervals = StatisticsCalculator.bucketIntervals(for: period, unit: .day, calendar: calendar)

        #expect(intervals == [
            DateInterval(start: day(9, 1), end: day(9, 2)),
            DateInterval(start: day(9, 2), end: day(9, 3)),
            DateInterval(start: day(9, 3), end: day(9, 4))
        ])
    }

    @Test func bucketIntervals_monthly_clipFirstAndLastToPeriod() {
        let period = DateInterval(start: day(7, 15), end: day(9, 10))

        let intervals = StatisticsCalculator.bucketIntervals(for: period, unit: .month, calendar: calendar)

        #expect(intervals == [
            DateInterval(start: day(7, 15), end: day(8, 1)),
            DateInterval(start: day(8, 1), end: day(9, 1)),
            DateInterval(start: day(9, 1), end: day(9, 10))
        ])
    }

    @Test func buckets_zipIntervalsWithTotals() {
        let intervals = [DateInterval(start: day(9, 1), end: day(9, 2)), DateInterval(start: day(9, 2), end: day(9, 3))]
        let totals = [TransactionSummary(income: 1, expense: 2), TransactionSummary(income: 3, expense: 4)]

        #expect(StatisticsCalculator.buckets(intervals: intervals, totals: totals) == [
            .init(start: day(9, 1), income: 1, expense: 2),
            .init(start: day(9, 2), income: 3, expense: 4)
        ])
    }

    @Test func average_includesEmptyBuckets() {
        let buckets = [
            StatisticsCalculator.Bucket(start: day(9, 1), income: 0, expense: 3_000),
            .init(start: day(9, 2), income: 0, expense: 0),
            .init(start: day(9, 3), income: 1_000, expense: 1_000)
        ]

        #expect(StatisticsCalculator.average(of: buckets) == TransactionSummary(income: 333, expense: 1_333))
        #expect(StatisticsCalculator.average(of: []) == .zero)
    }

    @Test func expenseTrendRate_comparesLaterHalfToEarlierHalf() {
        func buckets(_ expenses: [Int]) -> [StatisticsCalculator.Bucket] {
            expenses.enumerated().map { .init(start: day(9, $0.offset + 1), income: 0, expense: $0.element) }
        }

        #expect(StatisticsCalculator.expenseTrendRate(buckets([1_000, 1_000, 1_500, 1_500])) == 50)
        #expect(StatisticsCalculator.expenseTrendRate(buckets([2_000, 9_999, 1_000])) == -50)
        #expect(StatisticsCalculator.expenseTrendRate(buckets([0, 1_000])) == nil)
        #expect(StatisticsCalculator.expenseTrendRate(buckets([1_000])) == nil)
    }

    @Test func expenseShares_topCategoriesThenOthers() {
        let categories: [TransactionCategory] = [.Default.food, .Default.cafe, .Default.transport, .Default.shopping, .Default.leisure]
        let totals = categories.enumerated().map { CategoryTotal(category: $1, amount: ($0 + 1) * 1_000, count: 1) }

        let shares = StatisticsCalculator.expenseShares(totals, limit: 3)

        #expect(shares.map(\.category) == [.Default.leisure, .Default.shopping, .Default.transport, nil])
        #expect(shares.map(\.amount) == [5_000, 4_000, 3_000, 3_000])
        #expect(abs(shares.reduce(0) { $0 + $1.ratio } - 1) < 0.0001)
        #expect(StatisticsCalculator.expenseShares([]).isEmpty)
    }

    @Test func mostFrequent_prefersCount_thenAmount() {
        let totals = [
            CategoryTotal(category: .Default.cafe, amount: 9_500, count: 2),
            CategoryTotal(category: .Default.shopping, amount: 30_000, count: 1),
            CategoryTotal(category: .Default.food, amount: 20_000, count: 2)
        ]

        #expect(StatisticsCalculator.mostFrequent(totals)?.category == .Default.food)
        #expect(StatisticsCalculator.mostFrequent([]) == nil)
    }
}
