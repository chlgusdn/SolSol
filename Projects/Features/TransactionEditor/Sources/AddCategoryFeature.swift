import Clients
import ComposableArchitecture
import Domain
import Foundation

/// 카테고리 추가 바텀시트 — 이름(8자) + 색상 6종
@Reducer
public struct AddCategoryFeature {
    @ObservableState
    public struct State: Equatable {
        public var name = ""
        /// DesignSystem `SDCategoryColor`의 rawValue
        public var colorKey = "red"
        public var isSaving = false
        public var errorMessage: String?

        public init() {}

        public var validatedName: String? { TransactionCategory.validatedName(name) }
        public var nameLength: Int { name.trimmingCharacters(in: .whitespacesAndNewlines).unicodeScalars.count }
        public var canAdd: Bool { validatedName != nil && !isSaving }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case colorTapped(String)
        case addButtonTapped
        case addFailed(String)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case added(TransactionCategory)
        }
    }

    @Dependency(\.categoryClient) var categoryClient
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                state.errorMessage = nil
                return .none

            case let .colorTapped(key):
                state.colorKey = key
                return .none

            case .addButtonTapped:
                guard let name = state.validatedName, !state.isSaving else { return .none }
                state.isSaving = true
                // sortOrder는 DAO가 마지막 순서 다음으로 정한다
                let category = TransactionCategory(id: uuid(), type: .expense, name: name, colorKey: state.colorKey, sortOrder: 0)
                return .run { [categoryClient] send in
                    try await categoryClient.add(category: category)
                    await send(.delegate(.added(category)))
                } catch: { error, send in
                    await send(.addFailed(error.localizedDescription))
                }

            case let .addFailed(message):
                state.isSaving = false
                state.errorMessage = message
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
