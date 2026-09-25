import Clients
import ComposableArchitecture
import Domain
import Foundation

/// 예산 설정 — 예산 금액·시작일·만기일·위험/경고 알림 금액
@Reducer
public struct BudgetSettingsFeature {
    public enum AmountField: Equatable, Sendable {
        case budget
        case danger
        case warning
    }

    public enum DateField: Hashable, Sendable, Identifiable {
        case start
        case due

        public var id: Self { self }
    }

    @ObservableState
    public struct State: Equatable {
        public var today: Date
        /// 저장할 예산. 새 예산은 금액 0, 오늘 ~ 이번 달 말일로 시작한다
        public var draft: Budget
        public var isExisting = false
        /// 직전에 끝난 예산의 결과 — 새 예산을 정할 때 보여준다
        public var lastResult: BudgetResult?
        /// 만기가 지난 예산. 새 예산을 저장할 때 결과로 기록한다
        public var pendingResult: BudgetResult?
        public var hasLoaded = false
        public var isSaving = false
        public var errorMessage: String?
        public var datePickerField: DateField?
        @Presents public var amountEntry: AmountEntryFeature.State?

        public init(today: Date) {
            let calendar = Calendar.current
            let day = calendar.startOfDay(for: today)
            let monthEnd = DateInterval.month(containing: day).end
            let lastDay = calendar.date(byAdding: .day, value: -1, to: monthEnd) ?? day
            self.today = day
            self.draft = Budget(amount: 0, startDate: day, dueDate: lastDay, warnAmount: 0, dangerAmount: 0)
        }

        public var validationMessage: String? {
            switch draft.validationError {
            case .nonPositiveAmount: "예산 금액을 입력해요"
            case .dueDateBeforeStart: "만기일은 시작일 이후여야 해요"
            case .invalidWarnAmount: "경고 금액은 0원보다 크고 위험 금액보다 작아야 해요"
            case .dangerExceedsAmount: "위험 금액은 예산 금액을 넘을 수 없어요"
            case nil: nil
            }
        }

        public var canSave: Bool { hasLoaded && draft.isValid && !isSaving }

        public func amount(of field: AmountField) -> Int {
            switch field {
            case .budget: draft.amount
            case .danger: draft.dangerAmount
            case .warning: draft.warnAmount
            }
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case loaded(Loaded)
        case amountRowTapped(AmountField)
        case dateRowTapped(DateField)
        case dateSelected(DateField, Date)
        case saveButtonTapped
        case saveFinished
        case operationFailed(String)
        case amountEntry(PresentationAction<AmountEntryFeature.Action>)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case saved
        }

        public struct Loaded: Equatable, Sendable {
            /// 수정할 진행 중인 예산
            public var current: Budget?
            public var lastResult: BudgetResult?
            public var pendingResult: BudgetResult?

            public init(current: Budget? = nil, lastResult: BudgetResult? = nil, pendingResult: BudgetResult? = nil) {
                self.current = current
                self.lastResult = lastResult
                self.pendingResult = pendingResult
            }
        }
    }

    @Dependency(\.budgetClient) var budgetClient
    @Dependency(\.transactionClient) var transactionClient
    @Dependency(\.date.now) var now
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                guard !state.hasLoaded else { return .none }
                let today = state.today
                let resultID = uuid()
                return .run { [budgetClient, transactionClient] send in
                    guard let budget = try await budgetClient.fetch() else {
                        await send(.loaded(.init(lastResult: try await budgetClient.latestResult())))
                        return
                    }
                    guard budget.isExpired(at: today) else {
                        await send(.loaded(.init(current: budget)))
                        return
                    }
                    // 만기가 지난 예산은 새로 정하고, 그 결과를 직전 결과로 보여준다
                    let spent = try await transactionClient.fetchSummary(interval: budget.period()).expense
                    let result = budget.result(spent: spent, id: resultID)
                    await send(.loaded(.init(lastResult: result, pendingResult: result)))
                } catch: { error, send in
                    await send(.operationFailed(error.localizedDescription))
                }

            case let .loaded(loaded):
                state.hasLoaded = true
                state.lastResult = loaded.lastResult
                state.pendingResult = loaded.pendingResult
                if let current = loaded.current {
                    state.draft = current
                    state.isExisting = true
                }
                return .none

            case let .amountRowTapped(field):
                state.amountEntry = AmountEntryFeature.State(field: field, amount: state.amount(of: field))
                return .none

            case let .dateRowTapped(field):
                state.datePickerField = field
                return .none

            case let .dateSelected(field, date):
                let day = Calendar.current.startOfDay(for: date)
                switch field {
                case .start: state.draft.startDate = day
                case .due: state.draft.dueDate = day
                }
                state.datePickerField = nil
                return .none

            case let .amountEntry(.presented(.delegate(.confirmed(amount)))):
                switch state.amountEntry?.field {
                case .budget: state.draft = state.draft.withAmount(amount)
                case .danger: state.draft.dangerAmount = amount
                case .warning: state.draft.warnAmount = amount
                case nil: break
                }
                state.amountEntry = nil
                return .none

            case .amountEntry:
                return .none

            case .saveButtonTapped:
                guard state.canSave else { return .none }
                state.isSaving = true
                state.errorMessage = nil
                let budget = state.draft
                let pending = state.pendingResult.map { (result: $0, closedAt: now) }
                return .run { [budgetClient] send in
                    if let pending {
                        try await budgetClient.close(result: pending.result, closedAt: pending.closedAt, budget: budget)
                    } else {
                        try await budgetClient.save(budget: budget)
                    }
                    await send(.saveFinished)
                } catch: { error, send in
                    await send(.operationFailed(error.localizedDescription))
                }

            case .saveFinished:
                // 부모가 토스트 후 화면을 옮길 때까지 다시 저장되지 않도록 isSaving을 유지한다
                return .send(.delegate(.saved))

            case let .operationFailed(message):
                state.isSaving = false
                state.hasLoaded = true
                state.errorMessage = message
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$amountEntry, action: \.amountEntry) {
            AmountEntryFeature()
        }
    }
}
