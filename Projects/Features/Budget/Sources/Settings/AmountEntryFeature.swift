import ComposableArchitecture
import Domain
import Foundation

/// 금액 입력 시트 — 입력 화면과 같은 키패드 방식
@Reducer
public struct AmountEntryFeature {
    @ObservableState
    public struct State: Equatable {
        public var field: BudgetSettingsFeature.AmountField
        public var amount: Int
        public var shakeCount = 0

        public init(field: BudgetSettingsFeature.AmountField, amount: Int) {
            self.field = field
            self.amount = amount
        }

        public var canConfirm: Bool { amount > 0 }
    }

    public enum Action: Equatable {
        case keypadTapped(AmountInput.Key)
        case confirmButtonTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case confirmed(Int)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .keypadTapped(key):
                switch AmountInput.apply(key, to: state.amount) {
                case let .updated(amount): state.amount = amount
                case .overLimit: state.shakeCount += 1
                }
                return .none

            case .confirmButtonTapped:
                guard state.canConfirm else { return .none }
                return .send(.delegate(.confirmed(state.amount)))

            case .delegate:
                return .none
            }
        }
    }
}
