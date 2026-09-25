import Clients
import ComposableArchitecture
import Domain
import Foundation

/// 텅장방지 — 예산 만기까지 남은 날과 사용률 단계(안전·경고·위험)
@Reducer
public struct BudgetStatusFeature {
    @ObservableState
    public struct State: Equatable {
        public var today: Date
        public var budget: Budget?
        /// 예산 기간(시작일~만기일) 동안의 지출
        public var spent = 0
        public var hasLoaded = false
        public var errorMessage: String?
        @Presents public var alert: AlertState<Action.Alert>?

        public init(today: Date) {
            self.today = Calendar.current.startOfDay(for: today)
        }

        public var status: BudgetStatus? { budget?.status(spent: spent) }
        public var isExpired: Bool { budget?.isExpired(at: today) ?? false }
        public var overAmount: Int { max(0, -remaining) }
        public var usageRatio: Double { budget?.usageRatio(spent: spent) ?? 0 }
        public var remaining: Int { budget?.remaining(spent: spent) ?? 0 }
        public var daysRemaining: Int { budget?.daysRemaining(from: today) ?? 0 }
        public var remainingPeriodRatio: Double { budget?.remainingPeriodRatio(from: today) ?? 0 }
    }

    public enum Action: Equatable {
        case onAppear
        case settingsButtonTapped
        case deleteButtonTapped
        case addExpenseButtonTapped
        case budgetUpdated(Budget?)
        case spentLoaded(Int)
        case loadFailed(String)
        case deleteFinished
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        @CasePathable
        public enum Alert: Equatable, Sendable {
            case confirmDelete
        }

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case openSettings
            case addExpense
        }
    }

    enum CancelID {
        case budget
        case spent
    }

    @Dependency(\.budgetClient) var budgetClient
    @Dependency(\.transactionClient) var transactionClient
    @Dependency(\.date.now) var now
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.today = Calendar.current.startOfDay(for: now)
                return .run { [budgetClient] send in
                    for try await budget in budgetClient.observe() {
                        await send(.budgetUpdated(budget))
                    }
                } catch: { error, send in
                    await send(.loadFailed(error.localizedDescription))
                }
                .cancellable(id: CancelID.budget, cancelInFlight: true)

            case .settingsButtonTapped:
                return .send(.delegate(.openSettings))

            case .deleteButtonTapped:
                let isExpired = state.isExpired
                state.alert = AlertState {
                    TextState("예산을 삭제할까요?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDelete) { TextState("삭제") }
                    ButtonState(role: .cancel) { TextState("취소") }
                } message: {
                    TextState(isExpired ? "끝난 예산의 결과는 기록으로 남아요" : "진행 중인 예산이 사라져요")
                }
                return .none

            case .alert(.presented(.confirmDelete)):
                // 끝난 예산은 결과를 남겨 다음 예산을 정할 때 보여준다.
                // 화면의 spent는 아직 불러오지 못했을 수 있어 DB에서 다시 집계하고, 실패하면 삭제하지 않는다
                let archive = state.isExpired
                    ? state.budget.map { (budget: $0, id: uuid(), closedAt: now) }
                    : nil
                return .run { [budgetClient, transactionClient] send in
                    if let archive {
                        let spent = try await transactionClient.fetchSummary(interval: archive.budget.period()).expense
                        try await budgetClient.close(
                            result: archive.budget.result(spent: spent, id: archive.id),
                            closedAt: archive.closedAt,
                            budget: nil
                        )
                    } else {
                        try await budgetClient.clear()
                    }
                    await send(.deleteFinished)
                } catch: { error, send in
                    await send(.loadFailed(error.localizedDescription))
                }

            case .alert, .deleteFinished:
                return .none

            case .addExpenseButtonTapped:
                return .send(.delegate(.addExpense))

            case let .budgetUpdated(budget):
                state.budget = budget
                guard let budget else {
                    state.spent = 0
                    state.hasLoaded = true
                    return .cancel(id: CancelID.spent)
                }
                // 합계는 DB(SQL)에서 집계한다
                let period = budget.period()
                return .run { [transactionClient] send in
                    await send(.spentLoaded(try await transactionClient.fetchSummary(interval: period).expense))
                } catch: { error, send in
                    await send(.loadFailed(error.localizedDescription))
                }
                .cancellable(id: CancelID.spent, cancelInFlight: true)

            case let .spentLoaded(spent):
                state.spent = spent
                state.hasLoaded = true
                state.errorMessage = nil
                return .none

            case let .loadFailed(message):
                state.hasLoaded = true
                state.errorMessage = message
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
