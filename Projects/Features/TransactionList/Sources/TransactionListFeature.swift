import Clients
import ComposableArchitecture
import Domain
import Foundation

/// 지출 리스트 — 월 단위 거래 내역 + 예산 사용률
@Reducer
public struct TransactionListFeature {
    @ObservableState
    public struct State: Equatable {
        public var month: DateInterval
        public var today: Date
        public var transactions: [Transaction] = []
        public var summary: TransactionSummary = .zero
        public var budget: Budget?
        /// 예산 기간(시작일~만기일) 동안의 지출
        public var budgetSpent = 0
        public var isLoading = false
        public var errorMessage: String?
        @Presents public var alert: AlertState<Action.Alert>?

        public init(month: DateInterval, today: Date) {
            self.month = month
            self.today = Calendar.current.startOfDay(for: today)
        }

        public var isCurrentMonth: Bool { month.start <= today && today < month.end }

        public var dailyGroups: [DailyGroup] {
            TransactionCalculator.groupedByDay(transactions).map {
                DailyGroup(
                    day: $0.day,
                    expense: TransactionCalculator.summary(of: $0.transactions).expense,
                    transactions: $0.transactions
                )
            }
        }

        public var budgetUsageRatio: Double? {
            budget?.usageRatio(spent: budgetSpent)
        }
    }

    public struct DailyGroup: Equatable, Identifiable, Sendable {
        public var day: Date
        public var expense: Int
        public var transactions: [Transaction]
        public var id: Date { day }
    }

    public enum Action: Equatable {
        case onAppear
        case addButtonTapped
        case budgetSetupButtonTapped
        case transactionTapped(Transaction)
        case deleteSwiped(Transaction)
        case transactionsUpdated([Transaction])
        case budgetUpdated(Budget?)
        case summariesLoaded(summary: TransactionSummary, budgetSpent: Int)
        case deleteFinished
        case operationFailed(String)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        @CasePathable
        public enum Alert: Equatable, Sendable {
            case confirmDelete(Transaction.ID)
        }

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case addTransaction
            case editTransaction(Transaction)
            case openBudgetSettings
        }
    }

    enum CancelID {
        case transactions
        case budget
        case summaries
    }

    @Dependency(\.transactionClient) var transactionClient
    @Dependency(\.budgetClient) var budgetClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                let month = state.month
                return .merge(
                    .run { [transactionClient] send in
                        for try await transactions in transactionClient.observeMonth(month: month) {
                            await send(.transactionsUpdated(transactions))
                        }
                    } catch: { error, send in
                        await send(.operationFailed(error.localizedDescription))
                    }
                    .cancellable(id: CancelID.transactions, cancelInFlight: true),
                    .run { [budgetClient] send in
                        for try await budget in budgetClient.observe() {
                            await send(.budgetUpdated(budget))
                        }
                    } catch: { error, send in
                        await send(.operationFailed(error.localizedDescription))
                    }
                    .cancellable(id: CancelID.budget, cancelInFlight: true)
                )

            case .addButtonTapped:
                return .send(.delegate(.addTransaction))

            case .budgetSetupButtonTapped:
                return .send(.delegate(.openBudgetSettings))

            case let .transactionTapped(transaction):
                return .send(.delegate(.editTransaction(transaction)))

            case let .deleteSwiped(transaction):
                state.alert = .deleteConfirmation(transaction.id)
                return .none

            case let .alert(.presented(.confirmDelete(id))):
                return .run { [transactionClient] send in
                    try await transactionClient.delete(id: id)
                    await send(.deleteFinished)
                } catch: { error, send in
                    await send(.operationFailed(error.localizedDescription))
                }

            case .alert:
                return .none

            case .deleteFinished:
                // 목록은 관찰 스트림이 갱신한다
                return .none

            case let .transactionsUpdated(transactions):
                state.isLoading = false
                state.errorMessage = nil
                state.transactions = transactions
                return loadSummaries(state)

            case let .budgetUpdated(budget):
                state.budget = budget
                return loadSummaries(state)

            case let .summariesLoaded(summary, budgetSpent):
                state.summary = summary
                state.budgetSpent = budgetSpent
                return .none

            case let .operationFailed(message):
                state.isLoading = false
                state.errorMessage = message
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    /// 합계는 DB(SQL)에서 집계한다. 예산 사용률은 달이 아니라 예산 기간 기준이다
    private func loadSummaries(_ state: State) -> Effect<Action> {
        let month = state.month
        let budgetPeriod = state.budget?.period()
        return .run { [transactionClient] send in
            async let summary = transactionClient.fetchSummary(interval: month)
            var budgetSpent = 0
            if let budgetPeriod {
                budgetSpent = try await transactionClient.fetchSummary(interval: budgetPeriod).expense
            }
            await send(.summariesLoaded(summary: try await summary, budgetSpent: budgetSpent))
        } catch: { error, send in
            await send(.operationFailed(error.localizedDescription))
        }
        .cancellable(id: CancelID.summaries, cancelInFlight: true)
    }
}

extension AlertState where Action == TransactionListFeature.Action.Alert {
    static func deleteConfirmation(_ id: Transaction.ID) -> Self {
        AlertState {
            TextState("이 내역을 삭제할까요?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDelete(id)) {
                TextState("삭제")
            }
            ButtonState(role: .cancel) {
                TextState("취소")
            }
        } message: {
            TextState("삭제한 내역은 되돌릴 수 없어요")
        }
    }
}
