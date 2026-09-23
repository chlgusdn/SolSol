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
        public var title: String
        public var categoryID: TransactionCategory.ID
        /// 선택 가능한 지출 카테고리 (onAppear에 DB에서 불러온다)
        public var expenseCategories: [TransactionCategory] = TransactionCategory.Default.expenses
        public var memo: String
        public var date: Date
        public var isFixed: Bool
        public var isSaving = false
        @Presents public var alert: AlertState<Action.Alert>?

        /// 새 거래 작성
        public init(date: Date) {
            self.mode = .create
            self.type = .expense
            self.amountText = ""
            self.title = ""
            self.categoryID = TransactionCategory.Default.food.id
            self.memo = ""
            self.date = date
            self.isFixed = false
        }

        /// 기존 거래 수정
        public init(transaction: Transaction) {
            self.mode = .edit(transaction.id)
            self.type = transaction.type
            self.amountText = String(transaction.amount)
            self.title = transaction.title
            self.categoryID = transaction.category.id
            self.memo = transaction.memo
            self.date = transaction.date
            self.isFixed = transaction.isFixed
            if transaction.type == .expense, !expenseCategories.contains(transaction.category) {
                expenseCategories.append(transaction.category)
            }
        }

        /// 1 … `Transaction.maxAmount` 범위의 금액
        public var amount: Int? {
            Int(amountText.filter(\.isNumber)).flatMap { (1...Transaction.maxAmount).contains($0) ? $0 : nil }
        }

        public var isAmountOverLimit: Bool {
            (Int(amountText.filter(\.isNumber)) ?? 0) > Transaction.maxAmount
        }

        public var canSave: Bool { amount != nil && !isSaving }

        public var availableCategories: [TransactionCategory] {
            switch type {
            case .income: [TransactionCategory.Default.income]
            case .expense: expenseCategories
            }
        }

        public var selectedCategory: TransactionCategory {
            availableCategories.first { $0.id == categoryID }
                ?? availableCategories.first
                ?? TransactionCategory.Default.food
        }
        public var isEditing: Bool { mode != .create }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case categoriesLoaded([TransactionCategory])
        case categoriesLoadFailed(String)
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
    @Dependency(\.categoryClient) var categoryClient
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.memo):
                if state.memo.count > Transaction.memoLimit {
                    state.memo = String(state.memo.prefix(Transaction.memoLimit))
                }
                return .none

            case .binding:
                return .none

            case .onAppear:
                return .run { [categoryClient] send in
                    await send(.categoriesLoaded(try await categoryClient.fetchAll()))
                } catch: { error, send in
                    await send(.categoriesLoadFailed(error.localizedDescription))
                }

            case let .categoriesLoaded(categories):
                var expenses = categories.filter { $0.type == .expense }
                // 수정 중인 거래의 카테고리는 목록에 없더라도 유지한다
                if state.type == .expense, !expenses.contains(where: { $0.id == state.categoryID }),
                   let current = state.expenseCategories.first(where: { $0.id == state.categoryID }) {
                    expenses.append(current)
                }
                state.expenseCategories = expenses
                return .none

            case let .categoriesLoadFailed(message):
                state.alert = AlertState {
                    TextState("카테고리를 불러오지 못했어요")
                } message: {
                    TextState(message)
                }
                return .none

            case let .typeChanged(type):
                state.type = type
                if type == .income { state.isFixed = false }
                if !state.availableCategories.contains(where: { $0.id == state.categoryID }) {
                    state.categoryID = state.availableCategories.first?.id ?? TransactionCategory.Default.food.id
                }
                return .none

            case .saveButtonTapped:
                guard let amount = state.amount, !state.isSaving else { return .none }
                state.isSaving = true
                let id: Transaction.ID = switch state.mode {
                case .create: uuid()
                case let .edit(id): id
                }
                let title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
                let transaction = Transaction(
                    id: id,
                    type: state.type,
                    amount: amount,
                    category: state.selectedCategory,
                    title: title.isEmpty ? Transaction.defaultTitle(for: state.type) : title,
                    memo: String(state.memo.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Transaction.memoLimit)),
                    date: state.date,
                    isFixed: state.type == .expense && state.isFixed
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
