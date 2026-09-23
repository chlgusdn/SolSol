import Clients
import ComposableArchitecture
import Testing
@testable import OnboardingFeature

@MainActor
struct OnboardingFeatureTests {
    @Test func next_advancesPages_thenStartsOnLastPage() async {
        let completed = LockIsolated(false)
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        } withDependencies: {
            $0.settingsClient.completeOnboarding = { completed.setValue(true) }
        }

        await store.send(.nextButtonTapped) { $0.page = .calendar }
        await store.send(.nextButtonTapped) { $0.page = .statistics }
        await store.send(.nextButtonTapped) {
            $0.page = .budget
            #expect($0.isLastPage)
        }
        await store.send(.nextButtonTapped)
        await store.receive(\.startButtonTapped) { $0.isCompleting = true }
        await store.receive(\.completionSaved)
        await store.receive(\.delegate.completed)
        #expect(completed.value)
    }

    @Test func swipe_changesPage() async {
        let store = TestStore(initialState: OnboardingFeature.State()) { OnboardingFeature() }
        await store.send(\.binding.page, .statistics) { $0.page = .statistics }
    }

    @Test func skip_savesFlagAndCompletes() async {
        let completed = LockIsolated(false)
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        } withDependencies: {
            $0.settingsClient.completeOnboarding = { completed.setValue(true) }
        }

        await store.send(.skipButtonTapped) { $0.isCompleting = true }
        await store.receive(\.completionSaved)
        await store.receive(\.delegate.completed)
        #expect(completed.value)
    }

    @Test func completionFailure_stillCompletes() async {
        struct Failure: Error {}
        let store = TestStore(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        } withDependencies: {
            $0.settingsClient.completeOnboarding = { throw Failure() }
        }

        await store.send(.skipButtonTapped) { $0.isCompleting = true }
        await store.receive(\.completionSaved)
        await store.receive(\.delegate.completed)
    }

    @Test func tapWhileCompleting_isIgnored() async {
        var state = OnboardingFeature.State()
        state.isCompleting = true
        let store = TestStore(initialState: state) { OnboardingFeature() }

        // settingsClient는 unimplemented — 호출되면 테스트가 실패한다
        await store.send(.skipButtonTapped)
        await store.send(.startButtonTapped)
    }
}
