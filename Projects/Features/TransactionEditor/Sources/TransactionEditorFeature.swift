import Clients
import ComposableArchitecture
import Domain
import Foundation

/// 거래 추가/수정 화면
@Reducer
public struct TransactionEditorFeature {
    @ObservableState
    public struct State: Equatable {
        public enum Mode: Equatable, Sendable {
            case create
            case edit(Transaction.ID)
        }

        public var mode: Mode
        public var type: TransactionType
        public var amountText: String
        public var category: TransactionCategory
        public var memo: String
        public var date: Date
        public var isSaving = false
        @Presents public var alert: AlertState<Action.Alert>?

        /// 새 거래 작성
        public init(date: Date) {
            self.mode = .create
            self.type = .expense
            self.amountText = ""
            self.category = .food
            self.memo = ""
            self.date = date
        }

        /// 기존 거래 수정
        public init(transaction: Transaction) {
            self.mode = .edit(transaction.id)
            self.type = transaction.type
            self.amountText = String(transaction.amount)
            self.category = transaction.category
            self.memo = transaction.memo
            self.date = transaction.date
        }

        public var amount: Int? {
            Int(amountText.filter(\.isNumber)).flatMap { $0 > 0 ? $0 : nil }
        }

        public var canSave: Bool { amount != nil && !isSaving }
        public var availableCategories: [TransactionCategory] { TransactionCategory.available(for: type) }
        public var isEditing: Bool { mode != .create }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case typeChanged(TransactionType)
        case saveButtonTapped
        case deleteButtonTapped
        case cancelButtonTapped
        case saveFinished
        case deleteFinished
        case operationFailed(String)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        public enum Alert: Equatable, Sendable {}

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case saved
            case deleted
            case cancelled
        }
    }

    @Dependency(\.transactionClient) var transactionClient
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case let .typeChanged(type):
                state.type = type
                if !state.availableCategories.contains(state.category) {
                    state.category = state.availableCategories.first ?? .etc
                }
                return .none

            case .saveButtonTapped:
                guard let amount = state.amount, !state.isSaving else { return .none }
                state.isSaving = true
                let id: Transaction.ID = switch state.mode {
                case .create: uuid()
                case let .edit(id): id
                }
                let transaction = Transaction(
                    id: id,
                    type: state.type,
                    amount: amount,
                    category: state.category,
                    memo: state.memo.trimmingCharacters(in: .whitespacesAndNewlines),
                    date: state.date
                )
                return .run { [transactionClient] send in
                    try await transactionClient.save(transaction: transaction)
                    await send(.saveFinished)
                } catch: { error, send in
                    await send(.operationFailed(error.localizedDescription))
                }

            case .deleteButtonTapped:
                guard case let .edit(id) = state.mode, !state.isSaving else { return .none }
                state.isSaving = true
                return .run { [transactionClient] send in
                    try await transactionClient.delete(id: id)
                    await send(.deleteFinished)
                } catch: { error, send in
                    await send(.operationFailed(error.localizedDescription))
                }

            case .cancelButtonTapped:
                return .send(.delegate(.cancelled))

            case .saveFinished:
                state.isSaving = false
                return .send(.delegate(.saved))

            case .deleteFinished:
                state.isSaving = false
                return .send(.delegate(.deleted))

            case let .operationFailed(message):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("저장하지 못했어요")
                } message: {
                    TextState(message)
                }
                return .none

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
