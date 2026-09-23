import Clients
import ComposableArchitecture
import Core
import Domain
import Foundation
import HomeFeature
import OnboardingFeature
import OSLog
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
        /// 온보딩 완료 여부를 확인하는 중 (확인 전에는 홈을 보여주지 않는다)
        var isCheckingOnboarding = true
        /// 첫 실행이면 온보딩을 보여준다
        var onboarding: OnboardingFeature.State?
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
        case onboardingStatusLoaded(isCompleted: Bool)
        case onboarding(OnboardingFeature.Action)
        case home(HomeFeature.Action)
        case path(StackActionOf<Path>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.timeSyncClient) var timeSyncClient
    @Dependency(\.settingsClient) var settingsClient
    @Dependency(\.date.now) var now

    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    syncTime(),
                    .run { [settingsClient] send in
                        await send(.onboardingStatusLoaded(isCompleted: try await settingsClient.isOnboardingCompleted()))
                    } catch: { error, send in
                        // 확인에 실패하면 온보딩으로 사용자를 막지 않고 홈을 보여준다
                        Logger.app.error("온보딩 상태 확인 실패: \(error.localizedDescription)")
                        await send(.onboardingStatusLoaded(isCompleted: true))
                    }
                )

            case .scenePhaseBecameActive:
                return syncTime()

            case .timeSynced:
                return .none

            case let .onboardingStatusLoaded(isCompleted):
                state.isCheckingOnboarding = false
                state.onboarding = isCompleted ? nil : OnboardingFeature.State()
                return .none

            case .onboarding(.delegate(.completed)):
                state.onboarding = nil
                return .none

            case .onboarding:
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
        .ifLet(\.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }

    private func syncTime() -> Effect<Action> {
        .run { [timeSyncClient] send in
            await send(.timeSynced(await timeSyncClient.sync()))
        }
    }
}

extension AppFeature.Path.State: Equatable {}
extension AppFeature.Destination.State: Equatable {}
