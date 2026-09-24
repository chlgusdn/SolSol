import Clients
import ComposableArchitecture
import Core
import Domain
import Foundation

/// 수익/지출 입력·수정 — 키패드 금액 + 카테고리·제목·메모·날짜·고정 지출
@Reducer
public struct TransactionEditorFeature {
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case addCategory(AddCategoryFeature)
    }

    @ObservableState
    public struct State: Equatable {
        public enum Mode: Equatable, Sendable {
            case create
            case edit(Transaction.ID)
        }

        public var mode: Mode
        public var type: TransactionType
        public var amount: Int
        public var title: String
        public var memo: String
        public var categoryID: TransactionCategory.ID
        /// 선택 가능한 지출 카테고리 (onAppear에 DB에서 불러온다)
        public var expenseCategories: [TransactionCategory] = TransactionCategory.Default.expenses
        public var date: Date
        public var isFixed: Bool
        public var isSaving = false
        public var isSaved = false
        public var shakeCount = 0
        public var toast: String?
        public var isDatePickerPresented = false
        @Presents public var destination: Destination.State?
        @Presents public var alert: AlertState<Action.Alert>?

        /// 새 거래 작성
        public init(date: Date, type: TransactionType = .expense) {
            self.mode = .create
            self.type = type
            self.amount = 0
            self.title = ""
            self.memo = ""
            self.categoryID = type == .income ? TransactionCategory.Default.income.id : TransactionCategory.Default.food.id
            self.date = date
            self.isFixed = false
        }

        /// 기존 거래 수정
        public init(transaction: Transaction) {
            self.mode = .edit(transaction.id)
            self.type = transaction.type
            self.amount = transaction.amount
            self.title = transaction.title
            self.memo = transaction.memo
            self.categoryID = transaction.category.id
            self.date = transaction.date
            self.isFixed = transaction.isFixed
            if transaction.type == .expense, !expenseCategories.contains(transaction.category) {
                expenseCategories.append(transaction.category)
            }
        }

        public var isEditing: Bool { mode != .create }
        public var canSave: Bool { amount > 0 && !isSaving }

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
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case categoriesLoaded([TransactionCategory])
        case categoriesLoadFailed(String)
        case typeChanged(TransactionType)
        case keypadTapped(AmountInput.Key)
        case categoryTapped(TransactionCategory.ID)
        case addCategoryButtonTapped
        case fixedToggled
        case dateRowTapped
        case dateSelected(Date)
        case saveButtonTapped
        case saveFinished(Transaction)
        case saveFailed(String)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        public enum Alert: Equatable, Sendable {}

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case saved(Transaction, isNew: Bool)
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

            case let .keypadTapped(key):
                switch AmountInput.apply(key, to: state.amount) {
                case let .updated(amount):
                    state.amount = amount
                case .overLimit:
                    state.shakeCount += 1
                    state.toast = "최대 \(Transaction.maxAmount.compactFormatted)원까지 입력할 수 있어요"
                }
                return .none

            case let .categoryTapped(id):
                state.categoryID = id
                return .none

            case .addCategoryButtonTapped:
                state.destination = .addCategory(AddCategoryFeature.State())
                return .none

            case .fixedToggled:
                state.isFixed.toggle()
                return .none

            case .dateRowTapped:
                state.isDatePickerPresented = true
                return .none

            case let .dateSelected(day):
                state.date = day.settingTime(from: state.date)
                state.isDatePickerPresented = false
                return .none

            case .saveButtonTapped:
                guard state.canSave, !state.isSaved else { return .none }
                state.isSaving = true
                let id: Transaction.ID = switch state.mode {
                case .create: uuid()
                case let .edit(id): id
                }
                let title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
                let transaction = Transaction(
                    id: id,
                    type: state.type,
                    amount: state.amount,
                    category: state.selectedCategory,
                    title: title.isEmpty ? Transaction.defaultTitle(for: state.type) : title,
                    memo: String(state.memo.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Transaction.memoLimit)),
                    date: state.date,
                    isFixed: state.type == .expense && state.isFixed
                )
                return .run { [transactionClient] send in
                    try await transactionClient.save(transaction: transaction)
                    await send(.saveFinished(transaction))
                } catch: { error, send in
                    await send(.saveFailed(error.localizedDescription))
                }

            case let .saveFinished(transaction):
                // 부모가 토스트 후 화면을 옮길 때까지 다시 저장되지 않도록 isSaving을 유지한다
                state.isSaved = true
                return .send(.delegate(.saved(transaction, isNew: !state.isEditing)))

            case let .saveFailed(message):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("저장하지 못했어요")
                } message: {
                    TextState(message)
                }
                return .none

            case let .destination(.presented(.addCategory(.delegate(.added(category))))):
                state.expenseCategories.append(category)
                state.categoryID = category.id
                state.destination = nil
                return .none

            case .destination, .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}

