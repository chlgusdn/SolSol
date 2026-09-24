import Clients
import ComposableArchitecture
import Domain
import Foundation

/// 홈 — 선택 날짜의 지출 요약 + 월 캘린더 + 전 기능 허브
@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var month: DateInterval
        public var today: Date
        public var selectedDay: Date
        public var transactions: [Transaction] = []
        public var summary: TransactionSummary = .zero
        public var previousSummary: TransactionSummary = .zero
        public var isLoading = false
        public var errorMessage: String?

        public init(today: Date) {
            let day = Calendar.current.startOfDay(for: today)
            self.today = day
            self.selectedDay = day
            self.month = .month(containing: day)
        }

        public var isTodaySelected: Bool { selectedDay == today }
        /// `DateInterval.contains`는 끝(다음 달 1일)을 포함해 1일에 지난달도 참이 되므로 반열린 구간으로 비교한다
        public var isCurrentMonth: Bool { month.start <= today && today < month.end }
        /// 미래 달로는 넘어가지 않는다
        public var canMoveToNextMonth: Bool { month.end <= DateInterval.month(containing: today).start }

        public var dailyAmounts: [Date: DailyAmount] {
            TransactionCalculator.dailyAmounts(transactions)
        }

        public var selectedTransactions: [Transaction] {
            transactions
                .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDay) }
                .sorted { $0.date > $1.date }
        }

        public var selectedDayExpense: Int {
            TransactionCalculator.summary(of: selectedTransactions).expense
        }

        public var expenseChangeRate: Int? {
            TransactionCalculator.expenseChangeRate(current: summary, previous: previousSummary)
        }
    }

    /// 홈에서 바로 가는 화면
    public enum Shortcut: Equatable, Sendable, CaseIterable {
        case budget
        case statistics
        case fixedExpense
        case transactionList
    }

    public enum Action: Equatable {
        case onAppear
        case sceneBecameActive
        case previousMonthButtonTapped
        case nextMonthButtonTapped
        case dayTapped(Date)
        case addButtonTapped
        case shortcutTapped(Shortcut)
        case transactionTapped(Transaction)
        case transactionsUpdated([Transaction])
        case summariesLoaded(month: DateInterval, current: TransactionSummary, previous: TransactionSummary)
        case loadFailed(String)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case addTransaction(on: Date)
            case editTransaction(Transaction)
            case open(Shortcut)
        }
    }

    enum CancelID { case observation }

    @Dependency(\.transactionClient) var transactionClient
    @Dependency(\.date.now) var now

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                refreshToday(&state)
                return observe(&state)

            case .sceneBecameActive:
                // 보존된 화면에는 onAppear가 다시 오지 않아 자정을 넘긴 뒤 복귀하면 여기서 오늘을 갱신한다
                return refreshToday(&state) ? observe(&state) : .none

            case .previousMonthButtonTapped:
                return moveMonth(&state, by: -1)

            case .nextMonthButtonTapped:
                guard state.canMoveToNextMonth else { return .none }
                return moveMonth(&state, by: 1)

            case let .dayTapped(day):
                state.selectedDay = Calendar.current.startOfDay(for: day)
                return .none

            case .addButtonTapped:
                return .send(.delegate(.addTransaction(on: state.selectedDay)))

            case let .shortcutTapped(shortcut):
                return .send(.delegate(.open(shortcut)))

            case let .transactionTapped(transaction):
                return .send(.delegate(.editTransaction(transaction)))

            case let .transactionsUpdated(transactions):
                state.isLoading = false
                state.errorMessage = nil
                state.transactions = transactions
                let month = state.month
                // 합계는 DB(SQL)에서 집계한다
                return .run { [transactionClient] send in
                    async let current = transactionClient.fetchSummary(interval: month)
                    async let previous = transactionClient.fetchSummary(interval: month.shiftedMonth(by: -1))
                    await send(.summariesLoaded(month: month, current: try await current, previous: try await previous))
                } catch: { error, send in
                    await send(.loadFailed(error.localizedDescription))
                }

            case let .summariesLoaded(month, current, previous):
                // 월을 옮긴 뒤 늦게 도착한 이전 달 합계는 버린다
                guard month == state.month else { return .none }
                state.summary = current
                state.previousSummary = previous
                return .none

            case let .loadFailed(message):
                state.isLoading = false
                state.errorMessage = message
                return .none

            case .delegate:
                return .none
            }
        }
    }

    /// 오늘이 바뀌면 이번 달을 보던 경우에만 새 달로 따라간다. 달이 바뀌었으면 true
    @discardableResult
    private func refreshToday(_ state: inout State) -> Bool {
        let today = Calendar.current.startOfDay(for: now)
        guard today != state.today else { return false }
        let wasCurrentMonth = state.isCurrentMonth
        let wasTodaySelected = state.isTodaySelected
        state.today = today
        guard wasCurrentMonth, !state.isCurrentMonth else {
            if wasTodaySelected, state.isCurrentMonth { state.selectedDay = today }
            return false
        }
        show(.month(containing: today), selecting: today, in: &state)
        return true
    }

    /// 오늘이 있는 달로 오면 오늘을, 아니면 1일을 선택한다
    private func moveMonth(_ state: inout State, by offset: Int) -> Effect<Action> {
        let month = state.month.shiftedMonth(by: offset)
        let hasToday = month.start <= state.today && state.today < month.end
        show(month, selecting: hasToday ? state.today : month.start, in: &state)
        return observe(&state)
    }

    /// 새 달의 관찰 결과가 오기 전까지 이전 달 거래·합계가 남아 보이지 않게 비운다
    private func show(_ month: DateInterval, selecting day: Date, in state: inout State) {
        state.month = month
        state.selectedDay = day
        state.transactions = []
        state.summary = .zero
        state.previousSummary = .zero
    }

    private func observe(_ state: inout State) -> Effect<Action> {
        state.isLoading = true
        let month = state.month
        return .run { [transactionClient] send in
            for try await transactions in transactionClient.observeMonth(month: month) {
                await send(.transactionsUpdated(transactions))
            }
        } catch: { error, send in
            await send(.loadFailed(error.localizedDescription))
        }
        .cancellable(id: CancelID.observation, cancelInFlight: true)
    }
}
