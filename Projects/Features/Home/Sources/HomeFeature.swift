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
        public var isCurrentMonth: Bool { month.contains(today) }
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
        case previousMonthButtonTapped
        case nextMonthButtonTapped
        case dayTapped(Date)
        case addButtonTapped
        case shortcutTapped(Shortcut)
        case transactionTapped(Transaction)
        case transactionsUpdated([Transaction])
        case summariesLoaded(current: TransactionSummary, previous: TransactionSummary)
        case loadFailed(String)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case addTransaction
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
                // 자정을 넘겨 돌아와도 오늘 표시가 맞도록 매번 갱신한다
                state.today = Calendar.current.startOfDay(for: now)
                return observe(&state)

            case .previousMonthButtonTapped:
                return moveMonth(&state, by: -1)

            case .nextMonthButtonTapped:
                guard state.canMoveToNextMonth else { return .none }
                return moveMonth(&state, by: 1)

            case let .dayTapped(day):
                state.selectedDay = Calendar.current.startOfDay(for: day)
                return .none

            case .addButtonTapped:
                return .send(.delegate(.addTransaction))

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
                    await send(.summariesLoaded(current: try await current, previous: try await previous))
                } catch: { error, send in
                    await send(.loadFailed(error.localizedDescription))
                }

            case let .summariesLoaded(current, previous):
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

    /// 오늘이 있는 달로 오면 오늘을, 아니면 1일을 선택한다
    private func moveMonth(_ state: inout State, by offset: Int) -> Effect<Action> {
        state.month = state.month.shiftedMonth(by: offset)
        state.selectedDay = state.isCurrentMonth ? state.today : state.month.start
        return observe(&state)
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
