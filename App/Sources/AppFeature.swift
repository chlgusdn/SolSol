import Clients
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import Foundation
import HomeFeature
import OnboardingFeature
import OSLog
import TransactionEditorFeature
import StatisticsFeature
import TransactionListFeature

/// 루트 Reducer — Feature 간 이동을 조립한다
@Reducer
struct AppFeature {
    @Reducer
    enum Path {
        case transactionEditor(TransactionEditorFeature)
        case transactionList(TransactionListFeature)
        case statistics(StatisticsFeature)
        case comingSoon(ComingSoonFeature)
    }

    @ObservableState
    struct State: Equatable {
        /// 온보딩 완료 여부를 확인하는 중 (확인 전에는 홈을 보여주지 않는다)
        var isCheckingOnboarding = true
        /// 첫 실행이면 온보딩을 보여준다
        var onboarding: OnboardingFeature.State?
        var home: HomeFeature.State
        var path = StackState<Path.State>()
        var toast: String?

        init(today: Date) {
            self.home = HomeFeature.State(today: today)
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
        case toastChanged(String?)
        case saveTransitionFinished(editor: StackElementID, transaction: Domain.Transaction, isNew: Bool)
    }

    @Dependency(\.timeSyncClient) var timeSyncClient
    @Dependency(\.settingsClient) var settingsClient
    @Dependency(\.date.now) var now
    @Dependency(\.continuousClock) var clock

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
                return .merge(syncTime(), .send(.home(.sceneBecameActive)))

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

            case let .home(.delegate(.addTransaction(day))):
                state.path.append(.transactionEditor(TransactionEditorFeature.State(date: day.settingTime(from: now))))
                return .none

            case let .home(.delegate(.editTransaction(transaction))):
                state.path.append(.transactionEditor(TransactionEditorFeature.State(transaction: transaction)))
                return .none

            case .home(.delegate(.open(.transactionList))):
                state.path.append(.transactionList(TransactionListFeature.State(month: state.home.month, today: now)))
                return .none

            case .home(.delegate(.open(.statistics))):
                state.path.append(.statistics(StatisticsFeature.State(today: now)))
                return .none

            case let .home(.delegate(.open(shortcut))):
                state.path.append(.comingSoon(ComingSoonFeature.State(title: shortcut.title)))
                return .none

            case .home:
                return .none

            case let .path(.element(id, .transactionEditor(.delegate(.saved(transaction, isNew))))):
                let kind = transaction.type == .income ? "수익" : "지출"
                state.toast = isNew ? "\(kind)을 저장했어요" : "\(kind)을 수정했어요"
                // 기획서: 토스트를 보여준 뒤 잠시 후 화면을 옮긴다
                return .run { [clock] send in
                    try await clock.sleep(for: SDDuration.saveToNavigate)
                    await send(.saveTransitionFinished(editor: id, transaction: transaction, isNew: isNew))
                }

            case let .saveTransitionFinished(editorID, transaction, isNew):
                guard state.path.ids.contains(editorID) else { return .none }
                state.path.pop(from: editorID)
                // 새 거래는 지출 리스트로 이동한다. 리스트에서 왔다면 그 리스트로 돌아간다
                if isNew, !isTransactionList(state.path.last) {
                    state.path.append(.transactionList(TransactionListFeature.State(
                        month: .month(containing: transaction.date),
                        today: now
                    )))
                }
                return .none

            case let .toastChanged(toast):
                state.toast = toast
                return .none

            case let .path(.element(_, .transactionList(.delegate(delegate)))):
                switch delegate {
                case .addTransaction:
                    state.path.append(.transactionEditor(TransactionEditorFeature.State(date: now)))
                case let .editTransaction(transaction):
                    state.path.append(.transactionEditor(TransactionEditorFeature.State(transaction: transaction)))
                case .openBudgetSettings:
                    state.path.append(.comingSoon(ComingSoonFeature.State(title: "예산 설정")))
                }
                return .none

            case .path:
                return .none
            }
        }
        .ifLet(\.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        .forEach(\.path, action: \.path)
    }

    private func isTransactionList(_ element: Path.State?) -> Bool {
        if case .transactionList = element { return true }
        return false
    }

    private func syncTime() -> Effect<Action> {
        .run { [timeSyncClient] send in
            await send(.timeSynced(await timeSyncClient.sync()))
        }
    }
}

extension HomeFeature.Shortcut {
    var title: String {
        switch self {
        case .budget: "0원의 기적"
        case .statistics: "통계"
        case .fixedExpense: "고정 지출"
        case .transactionList: "지출 리스트"
        }
    }
}

extension AppFeature.Path.State: Equatable {}
