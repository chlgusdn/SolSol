import Clients
import ComposableArchitecture
import Domain
import Foundation

/// 월별 수입/지출 요약과 거래 목록
@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var month: DateInterval
        public var transactions: [Transaction] = []
        public var summary: TransactionSummary = .zero
        public var isLoading = false
        public var errorMessage: String?

        public init(month: DateInterval) {
            self.month = month
        }

        public var dailyGroups: [DailyGroup] {
            TransactionCalculator.groupedByDay(transactions).map { DailyGroup(day: $0.day, transactions: $0.transactions) }
        }
    }

    public struct DailyGroup: Equatable, Identifiable, Sendable {
        public var day: Date
        public var transactions: [Transaction]
        public var id: Date { day }
    }

    public enum Action: Equatable {
        case onAppear
        case previousMonthButtonTapped
        case nextMonthButtonTapped
        case addButtonTapped
        case transactionTapped(Transaction)
        case transactionsUpdated([Transaction])
        case summaryLoaded(TransactionSummary)
        case loadFailed(String)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case addTransaction
            case editTransaction(Transaction)
        }
    }

    enum CancelID { case observation }

    @Dependency(\.transactionClient) var transactionClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return observe(&state)

            case .previousMonthButtonTapped:
                state.month = state.month.shiftedMonth(by: -1)
                return observe(&state)

            case .nextMonthButtonTapped:
                state.month = state.month.shiftedMonth(by: 1)
                return observe(&state)

            case .addButtonTapped:
                return .send(.delegate(.addTransaction))

            case let .transactionTapped(transaction):
                return .send(.delegate(.editTransaction(transaction)))

            case let .transactionsUpdated(transactions):
                state.isLoading = false
                state.errorMessage = nil
                state.transactions = transactions
                let month = state.month
                // 합계는 DB(SQL)에서 집계한다
                return .run { [transactionClient] send in
                    await send(.summaryLoaded(try await transactionClient.fetchSummary(interval: month)))
                } catch: { error, send in
                    await send(.loadFailed(error.localizedDescription))
                }

            case let .summaryLoaded(summary):
                state.summary = summary
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
