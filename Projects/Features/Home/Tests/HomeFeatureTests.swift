import Clients
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import HomeFeature

@MainActor
struct HomeFeatureTests {
    private let calendar = Calendar.current
    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private var today: Date { calendar.startOfDay(for: now) }
    private var month: DateInterval { .month(containing: now) }

    private func transaction(_ id: Int, _ type: TransactionType, _ amount: Int, dayOffset: Int = 0) -> Domain.Transaction {
        Domain.Transaction(
            id: UUID(id), type: type, amount: amount,
            category: type == .income ? .Default.income : .Default.food,
            title: "거래\(id)",
            date: calendar.date(byAdding: .day, value: dayOffset, to: now)!
        )
    }

    @Test func init_selectsTodayInCurrentMonth() {
        let state = HomeFeature.State(today: now)

        #expect(state.today == today)
        #expect(state.selectedDay == today)
        #expect(state.month == month)
        #expect(state.isTodaySelected)
    }

    @Test func isCurrentMonth_onFirstDay_excludesPreviousMonth() {
        let firstDay = calendar.date(from: DateComponents(year: 2027, month: 2, day: 1, hour: 9))!
        var state = HomeFeature.State(today: firstDay)
        #expect(state.isCurrentMonth)

        state.month = state.month.shiftedMonth(by: -1)
        #expect(!state.isCurrentMonth)
        #expect(state.canMoveToNextMonth)
    }

    @Test func previousMonth_onFirstDay_selectsFirstOfPreviousMonth() async {
        let firstDay = calendar.date(from: DateComponents(year: 2027, month: 2, day: 1, hour: 9))!
        let store = TestStore(initialState: HomeFeature.State(today: firstDay)) {
            HomeFeature()
        } withDependencies: {
            $0.transactionClient.observe = { _ in .finished() }
        }

        let january = DateInterval.month(containing: firstDay).shiftedMonth(by: -1)
        await store.send(.previousMonthButtonTapped) {
            $0.month = january
            $0.selectedDay = january.start
            $0.isLoading = true
        }
    }

    @Test func monthChange_clearsPreviousMonthData() async {
        var state = HomeFeature.State(today: now)
        state.transactions = [transaction(0, .expense, 12_000)]
        state.summary = TransactionSummary(expense: 12_000)
        state.previousSummary = TransactionSummary(expense: 10_000)
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.transactionClient.observe = { _ in .finished() }
        }

        let previous = month.shiftedMonth(by: -1)
        await store.send(.previousMonthButtonTapped) {
            $0.month = previous
            $0.selectedDay = previous.start
            $0.transactions = []
            $0.summary = .zero
            $0.previousSummary = .zero
            $0.isLoading = true
        }
    }

    @Test func sceneBecameActive_sameDay_doesNothing() async {
        let store = TestStore(initialState: HomeFeature.State(today: now)) {
            HomeFeature()
        } withDependencies: {
            $0.date = .constant(now)
        }

        await store.send(.sceneBecameActive)
    }

    @Test func sceneBecameActive_afterMonthEnds_followsToNewMonth() async {
        let lastDay = calendar.date(from: DateComponents(year: 2027, month: 1, day: 31, hour: 23))!
        let nextMorning = calendar.date(byAdding: .hour, value: 8, to: lastDay)!
        let requested = LockIsolated<[DateInterval]>([])
        let store = TestStore(initialState: HomeFeature.State(today: lastDay)) {
            HomeFeature()
        } withDependencies: {
            $0.date = .constant(nextMorning)
            $0.transactionClient.observe = { month in
                requested.withValue { $0.append(month) }
                return .finished()
            }
        }

        let february = DateInterval.month(containing: nextMorning)
        await store.send(.sceneBecameActive) {
            $0.today = self.calendar.startOfDay(for: nextMorning)
            $0.month = february
            $0.selectedDay = self.calendar.startOfDay(for: nextMorning)
            $0.isLoading = true
        }
        await store.finish()
        #expect(requested.value == [february])
    }

    @Test func sceneBecameActive_whileViewingPastMonth_keepsMonthAndSelection() async {
        var state = HomeFeature.State(today: now)
        state.month = month.shiftedMonth(by: -1)
        state.selectedDay = state.month.start
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.date = .constant(tomorrow)
        }

        await store.send(.sceneBecameActive) {
            $0.today = self.calendar.startOfDay(for: tomorrow)
        }
    }

    @Test func summariesLoaded_forAnotherMonth_isIgnored() async {
        let store = TestStore(initialState: HomeFeature.State(today: now)) { HomeFeature() }

        await store.send(.summariesLoaded(
            month: month.shiftedMonth(by: -1),
            current: TransactionSummary(expense: 1),
            previous: TransactionSummary(expense: 2)
        ))
    }

    @Test func onAppear_refreshesToday_observesMonth_andLoadsBothSummaries() async {
        let lunch = transaction(0, .expense, 12_000)
        let month = month
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let store = TestStore(initialState: HomeFeature.State(today: now)) {
            HomeFeature()
        } withDependencies: {
            $0.date = .constant(tomorrow)
            $0.transactionClient.observe = { _ in
                AsyncThrowingStream { $0.yield([lunch]); $0.finish() }
            }
            $0.transactionClient.fetchSummary = { interval in
                interval == month
                    ? TransactionSummary(expense: 12_000)
                    : TransactionSummary(expense: 10_000)
            }
        }

        await store.send(.onAppear) {
            $0.today = self.calendar.startOfDay(for: tomorrow)
            $0.selectedDay = self.calendar.startOfDay(for: tomorrow)
            $0.isLoading = true
        }
        await store.receive(\.transactionsUpdated) {
            $0.isLoading = false
            $0.transactions = [lunch]
        }
        await store.receive(\.summariesLoaded) {
            $0.summary = TransactionSummary(expense: 12_000)
            $0.previousSummary = TransactionSummary(expense: 10_000)
        }
        #expect(store.state.expenseChangeRate == 20)
    }

    @Test func monthNavigation_selectsFirstDayElsewhere_andTodayInCurrentMonth() async {
        let requested = LockIsolated<[DateInterval]>([])
        let store = TestStore(initialState: HomeFeature.State(today: now)) {
            HomeFeature()
        } withDependencies: {
            $0.transactionClient.observe = { month in
                requested.withValue { $0.append(month) }
                return .finished()
            }
        }

        let previous = month.shiftedMonth(by: -1)
        await store.send(.previousMonthButtonTapped) {
            $0.month = previous
            $0.selectedDay = previous.start
            $0.isLoading = true
        }
        #expect(store.state.canMoveToNextMonth)
        await store.send(.nextMonthButtonTapped) {
            $0.month = self.month
            $0.selectedDay = self.today
        }
        await store.finish()
        #expect(requested.value == [previous, month])
    }

    @Test func nextMonth_inCurrentMonth_doesNothing() async {
        let store = TestStore(initialState: HomeFeature.State(today: now)) { HomeFeature() }

        #expect(!store.state.canMoveToNextMonth)
        await store.send(.nextMonthButtonTapped)
    }

    @Test func dayTapped_filtersTransactionsAndExpenseForThatDay() async {
        let todayLunch = transaction(0, .expense, 12_000)
        let yesterdayCoffee = transaction(1, .expense, 4_500, dayOffset: -1)
        let yesterdaySalary = transaction(2, .income, 3_000_000, dayOffset: -1)
        var state = HomeFeature.State(today: now)
        state.transactions = [todayLunch, yesterdayCoffee, yesterdaySalary]
        let store = TestStore(initialState: state) { HomeFeature() }

        #expect(store.state.selectedTransactions == [todayLunch])
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        await store.send(.dayTapped(yesterday)) {
            $0.selectedDay = self.calendar.startOfDay(for: yesterday)
        }
        #expect(!store.state.isTodaySelected)
        #expect(Set(store.state.selectedTransactions) == [yesterdayCoffee, yesterdaySalary])
        #expect(store.state.selectedDayExpense == 4_500)
        #expect(store.state.dailyAmounts[self.calendar.startOfDay(for: yesterday)] == .expense(4_500))
    }

    @Test func observationFailure_setsError() async {
        struct Failure: Error {}
        let store = TestStore(initialState: HomeFeature.State(today: now)) {
            HomeFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.transactionClient.observe = { _ in AsyncThrowingStream { $0.finish(throwing: Failure()) } }
        }

        await store.send(.onAppear) { $0.isLoading = true }
        await store.receive(\.loadFailed) {
            $0.isLoading = false
            $0.errorMessage = Failure().localizedDescription
        }
    }

    @Test func buttons_sendDelegates() async {
        let lunch = transaction(0, .expense, 12_000)
        let store = TestStore(initialState: HomeFeature.State(today: now)) { HomeFeature() }

        await store.send(.addButtonTapped)
        await store.receive(\.delegate.addTransaction)
        await store.send(.transactionTapped(lunch))
        await store.receive(\.delegate.editTransaction, lunch)
        for shortcut in HomeFeature.Shortcut.allCases {
            await store.send(.shortcutTapped(shortcut))
            await store.receive(\.delegate.open, shortcut)
        }
    }
}
