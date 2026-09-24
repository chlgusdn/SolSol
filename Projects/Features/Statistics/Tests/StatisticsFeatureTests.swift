import Clients
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import StatisticsFeature

@MainActor
struct StatisticsFeatureTests {
    private let calendar = Calendar.current
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func day(_ offset: Int) -> Date {
        calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: now)!)
    }

    private var thisMonth: DateInterval { .month(containing: now) }

    @Test func init_defaultsToThisMonthUntilToday_daily() {
        let state = StatisticsFeature.State(today: now)

        #expect(state.period == DateInterval(start: thisMonth.start, end: day(1)))
        #expect(state.tab == .average)
        #expect(state.unit == .day)
    }

    @Test func onAppear_observesPeriodWithDailyBuckets_andStoresSnapshot() async {
        let lunch = Domain.Transaction(id: UUID(0), type: .expense, amount: 12_000, category: .Default.food, title: "점심", date: now)
        let salary = Domain.Transaction(id: UUID(1), type: .income, amount: 3_000_000, category: .Default.income, title: "월급", date: now)
        let initial = StatisticsFeature.State(today: now)
        let intervals = initial.bucketIntervals
        let totals = intervals.map { $0.contains(now) ? TransactionSummary(income: 3_000_000, expense: 12_000) : .zero }
        let snapshot = StatisticsSnapshot(
            bucketTotals: totals,
            categoryTotals: [CategoryTotal(category: .Default.food, amount: 12_000, count: 1)],
            largestIncome: salary,
            largestExpense: lunch,
            transactionCount: 2
        )
        let requested = LockIsolated<[(DateInterval, [DateInterval])]>([])
        let store = TestStore(initialState: initial) {
            StatisticsFeature()
        } withDependencies: {
            $0.statisticsClient.observe = { period, buckets in
                requested.withValue { $0.append((period, buckets)) }
                return AsyncThrowingStream { $0.yield(snapshot); $0.finish() }
            }
        }

        await store.send(.onAppear) { $0.isLoading = true }
        await store.receive(\.snapshotUpdated) {
            $0.isLoading = false
            $0.buckets = StatisticsCalculator.buckets(intervals: intervals, totals: totals)
            $0.categoryTotals = snapshot.categoryTotals
            $0.largestIncome = salary
            $0.largestExpense = lunch
            $0.transactionCount = 2
        }

        #expect(requested.value.map(\.0) == [initial.period])
        #expect(requested.value.map(\.1) == [intervals])
        #expect(intervals.count == calendar.component(.day, from: now))
        #expect(!store.state.isEmpty)
        #expect(store.state.peakExpenseBucket?.start == day(0))
        #expect(store.state.expenseShares.map(\.category) == [.Default.food])
        #expect(store.state.frequentCategory?.count == 1)
    }

    @Test func tabSelected_changesTab() async {
        let store = TestStore(initialState: StatisticsFeature.State(today: now)) { StatisticsFeature() }

        await store.send(.tabSelected(.report)) { $0.tab = .report }
    }

    @Test func periodSelection_replacesPeriod_clearsData_andReobserves() async {
        var state = StatisticsFeature.State(today: now)
        state.transactionCount = 1
        state.categoryTotals = [CategoryTotal(category: .Default.food, amount: 1, count: 1)]
        let requested = LockIsolated<[DateInterval]>([])
        let store = TestStore(initialState: state) {
            StatisticsFeature()
        } withDependencies: {
            $0.statisticsClient.observe = { period, _ in
                requested.withValue { $0.append(period) }
                return .finished()
            }
        }

        await store.send(.periodButtonTapped) {
            $0.periodPicker = PeriodPickerFeature.State(period: $0.period, today: self.now)
        }
        await store.send(\.periodPicker.quickRangeTapped, 7) {
            $0.periodPicker?.start = self.day(-6)
            $0.periodPicker?.end = self.day(0)
            $0.periodPicker?.displayedMonth = .month(containing: self.now)
        }
        await store.send(\.periodPicker.confirmButtonTapped)
        let lastWeek = DateInterval(start: day(-6), end: day(1))
        await store.receive(\.periodPicker.delegate.selected, lastWeek) {
            $0.period = lastWeek
            $0.periodPicker = nil
            $0.categoryTotals = []
            $0.transactionCount = 0
            $0.isLoading = true
        }
        await store.finish()
        #expect(requested.value == [lastWeek])
    }

    @Test func periodPicker_secondTapSetsEnd_swappingWhenEarlier() async {
        let store = TestStore(initialState: PeriodPickerFeature.State(period: DateInterval(start: day(-3), end: day(1)), today: now)) {
            PeriodPickerFeature()
        }

        await store.send(.dayTapped(day(-2))) {
            $0.start = self.day(-2)
            $0.end = nil
        }
        #expect(!store.state.canConfirm)
        await store.send(.dayTapped(day(-10))) {
            $0.start = self.day(-10)
            $0.end = self.day(-2)
        }
        #expect(store.state.period == DateInterval(start: day(-10), end: day(-1)))
    }

    @Test func periodPicker_cannotMovePastCurrentMonth() async {
        let store = TestStore(initialState: PeriodPickerFeature.State(period: StatisticsFeature.State(today: now).period, today: now)) {
            PeriodPickerFeature()
        }

        await store.send(.nextMonthButtonTapped)
        await store.send(.previousMonthButtonTapped) {
            $0.displayedMonth = self.thisMonth.shiftedMonth(by: -1)
        }
        await store.send(.nextMonthButtonTapped) {
            $0.displayedMonth = self.thisMonth
        }
    }

    @Test func observationFailure_setsError() async {
        struct Failure: Error {}
        let store = TestStore(initialState: StatisticsFeature.State(today: now)) {
            StatisticsFeature()
        } withDependencies: {
            $0.statisticsClient.observe = { _, _ in AsyncThrowingStream { $0.finish(throwing: Failure()) } }
        }

        await store.send(.onAppear) { $0.isLoading = true }
        await store.receive(\.loadFailed) {
            $0.isLoading = false
            $0.errorMessage = Failure().localizedDescription
        }
    }
}

