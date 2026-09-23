import Clients
import ComposableArchitecture
import Core
import Foundation
import OSLog

/// 첫 실행 온보딩 — 4장 슬라이드, 건너뛰기, 시작
@Reducer
public struct OnboardingFeature {
    @ObservableState
    public struct State: Equatable {
        public var page: OnboardingPage = .welcome
        /// 완료 처리 중 (중복 탭 방지)
        public var isCompleting = false

        public init() {}

        public var isLastPage: Bool { page == OnboardingPage.allCases.last }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case nextButtonTapped
        case skipButtonTapped
        case startButtonTapped
        case completionSaved
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            /// 온보딩을 마쳤다 (완료 플래그 저장 여부와 관계없이 홈으로 이동)
            case completed
        }
    }

    @Dependency(\.settingsClient) var settingsClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .nextButtonTapped:
                guard let next = OnboardingPage(rawValue: state.page.rawValue + 1) else {
                    return .send(.startButtonTapped)
                }
                state.page = next
                return .none

            case .skipButtonTapped, .startButtonTapped:
                guard !state.isCompleting else { return .none }
                state.isCompleting = true
                return .run { [settingsClient] send in
                    try await settingsClient.completeOnboarding()
                    await send(.completionSaved)
                } catch: { error, send in
                    // 플래그 저장에 실패해도 사용자를 막지 않는다 — 다음 실행에 온보딩이 다시 보일 뿐이다
                    Logger.app.error("온보딩 완료 저장 실패: \(error.localizedDescription)")
                    await send(.completionSaved)
                }

            case .completionSaved:
                return .send(.delegate(.completed))

            case .delegate:
                return .none
            }
        }
    }
}
