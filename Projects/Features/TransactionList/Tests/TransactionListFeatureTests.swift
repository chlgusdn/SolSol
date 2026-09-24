import Clients
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import TransactionListFeature

@MainActor
struct TransactionListFeatureTests {
    private let calendar = Calendar.current
    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private var month: DateInterval { .month(containing: now) }

    private func transaction(_ id: Int, _ type: TransactionType, _ amount: Int, dayOffset: Int = 0) -> Domain.Transaction {
        Domain.Transaction(
            id: UUID(id), type: type, amount: amount,
            category: type == .income ? .Default.income : .Default.food,
            title: "거래\(id)",
            date: calendar.date(byAdding: .day, value: dayOffset, to: now)!
        )
    }

    private var budget: Budget {
        .suggested(
            amount: 100_000,
            startDate: calendar.date(byAdding: .day, value: -20, to: now)!,
            dueDate: calendar.date(byAdding: .day, value: 10, to: now)!
        )
    }

    @Test func onAppear_loadsTransactions_budget_andSpentWithinBudgetPeriod() async {
        let lunch = transaction(0, .expense, 12_000)
        let month = month
        let budget = budget
        let requested = LockIsolated<[DateInterval]>([])
        let store = TestStore(initialState: TransactionListFeature.State(month: month, today: now)) {
            TransactionListFeature()
        } withDependencies: {
            $0.transactionClient.observeMonth = { _ in AsyncThrowingStream { $0.yield([lunch]); $0.finish() } }
            $0.budgetClient.observe = { AsyncThrowingStream { $0.yield(budget); $0.finish() } }
            $0.transactionClient.fetchSummary = { interval in
                requested.withValue { $0.append(interval) }
                return interval == month
                    ? TransactionSummary(income: 50_000, expense: 12_000)
                    : TransactionSummary(expense: 85_000)
            }
        }
        // 거래·예산 스트림은 동시에 흘러 도착 순서가 정해지지 않으므로 최종 상태만 검증한다
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.onAppear) { $0.isLoading = true }
        await store.finish()
        await store.skipReceivedActions(strict: false)

        #expect(!store.state.isLoading)
        #expect(store.state.transactions == [lunch])
        #expect(store.state.budget == budget)
        #expect(store.state.summary == TransactionSummary(income: 50_000, expense: 12_000))
        #expect(store.state.budgetSpent == 85_000)
        #expect(store.state.budgetUsageRatio == 0.85)
        #expect(requested.value.contains(budget.period()))
    }

    @Test func noBudget_skipsBudgetPeriodQuery() async {
        let store = TestStore(initialState: TransactionListFeature.State(month: month, today: now)) {
            TransactionListFeature()
        } withDependencies: {
            $0.transactionClient.fetchSummary = { _ in TransactionSummary(expense: 3_000) }
        }

        await store.send(.budgetUpdated(nil))
        await store.receive(\.summariesLoaded) {
            $0.summary = TransactionSummary(expense: 3_000)
        }
        #expect(store.state.budgetUsageRatio == nil)
    }

    @Test func dailyGroups_newestFirst_withDayExpenseTotal() {
        var state = TransactionListFeature.State(month: month, today: now)
        state.transactions = [
            transaction(0, .expense, 12_000, dayOffset: -1),
            transaction(1, .income, 3_000_000, dayOffset: -1),
            transaction(2, .expense, 4_500)
        ]

        let groups = state.dailyGroups

        #expect(groups.map(\.day) == [calendar.startOfDay(for: now), calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)])
        #expect(groups.map(\.expense) == [4_500, 12_000])
    }

    @Test func deleteSwiped_asksConfirmation_thenDeletes() async {
        let lunch = transaction(0, .expense, 12_000)
        let deleted = LockIsolated<[Domain.Transaction.ID]>([])
        let store = TestStore(initialState: TransactionListFeature.State(month: month, today: now)) {
            TransactionListFeature()
        } withDependencies: {
            $0.transactionClient.delete = { id in deleted.withValue { $0.append(id) } }
        }

        await store.send(.deleteSwiped(lunch)) { $0.alert = .deleteConfirmation(lunch.id) }
        await store.send(\.alert.confirmDelete, lunch.id) { $0.alert = nil }
        await store.receive(\.deleteFinished)
        #expect(deleted.value == [lunch.id])
    }

    @Test func deleteCancelled_doesNotDelete() async {
        let store = TestStore(initialState: TransactionListFeature.State(month: month, today: now)) {
            TransactionListFeature()
        }

        let lunch = transaction(0, .expense, 12_000)
        await store.send(.deleteSwiped(lunch)) { $0.alert = .deleteConfirmation(lunch.id) }
        await store.send(.alert(.dismiss)) { $0.alert = nil }
    }

    @Test func buttons_sendDelegates() async {
        let lunch = transaction(0, .expense, 12_000)
        let store = TestStore(initialState: TransactionListFeature.State(month: month, today: now)) {
            TransactionListFeature()
        }

        await store.send(.addButtonTapped)
        await store.receive(\.delegate.addTransaction)
        await store.send(.transactionTapped(lunch))
        await store.receive(\.delegate.editTransaction, lunch)
        await store.send(.budgetSetupButtonTapped)
        await store.receive(\.delegate.openBudgetSettings)
    }

    @Test func isCurrentMonth_excludesMonthEnd() {
        let firstDay = calendar.date(from: DateComponents(year: 2027, month: 2, day: 1, hour: 9))!
        let january = DateInterval.month(containing: firstDay).shiftedMonth(by: -1)

        #expect(!TransactionListFeature.State(month: january, today: firstDay).isCurrentMonth)
        #expect(TransactionListFeature.State(month: .month(containing: firstDay), today: firstDay).isCurrentMonth)
    }
}
