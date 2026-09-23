import Clients
import ComposableArchitecture
import Domain
import Foundation
import HomeFeature
import TransactionEditorFeature

/// 루트 Reducer — Feature 간 이동을 조립한다
@Reducer
struct AppFeature {
    @Reducer
    enum Path {
        case transactionEditor(TransactionEditorFeature)
    }

    @Reducer
    enum Destination {
        case transactionEditor(TransactionEditorFeature)
    }

    @ObservableState
    struct State: Equatable {
        var home: HomeFeature.State
        var path = StackState<Path.State>()
        @Presents var destination: Destination.State?

        init(month: DateInterval) {
            self.home = HomeFeature.State(month: month)
        }
    }

    enum Action {
        case onAppear
        case scenePhaseBecameActive
        case timeSynced(Date?)
        case home(HomeFeature.Action)
        case path(StackActionOf<Path>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.timeSyncClient) var timeSyncClient
    @Dependency(\.date.now) var now

    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear, .scenePhaseBecameActive:
                return .run { [timeSyncClient] send in
                    await send(.timeSynced(await timeSyncClient.sync()))
                }

            case .timeSynced:
                return .none

            case .home(.delegate(.addTransaction)):
                state.destination = .transactionEditor(TransactionEditorFeature.State(date: now))
                return .none

            case let .home(.delegate(.editTransaction(transaction))):
                state.path.append(.transactionEditor(TransactionEditorFeature.State(transaction: transaction)))
                return .none

            case .home:
                return .none

            case let .path(.element(id, .transactionEditor(.delegate(delegate)))):
                switch delegate {
                case .saved, .deleted, .cancelled:
                    state.path.pop(from: id)
                }
                return .none

            case .path:
                return .none

            case .destination(.presented(.transactionEditor(.delegate))):
                state.destination = nil
                return .none

            case .destination:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AppFeature.Path.State: Equatable {}
extension AppFeature.Destination.State: Equatable {}
