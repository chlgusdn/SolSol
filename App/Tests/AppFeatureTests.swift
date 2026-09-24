import Clients
import ComposableArchitecture
import Domain
import Foundation
import HomeFeature
import OnboardingFeature
import Testing
import TransactionEditorFeature
@testable import SolSol

@MainActor
struct AppFeatureTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func addTransaction_presentsEditorSheet_andDismissesOnSave() async {
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.uuid = .incrementing
            $0.transactionClient.save = { _ in }
        }

        await store.send(\.home.delegate.addTransaction) {
            $0.destination = .transactionEditor(TransactionEditorFeature.State(date: self.now))
        }
        await store.send(\.destination.transactionEditor.binding.amountText, "1000") {
            $0.destination?.modify(\.transactionEditor) { $0.amountText = "1000" }
        }
        await store.send(\.destination.transactionEditor.saveButtonTapped) {
            $0.destination?.modify(\.transactionEditor) { $0.isSaving = true }
        }
        await store.receive(\.destination.transactionEditor.saveFinished) {
            $0.destination?.modify(\.transactionEditor) { $0.isSaving = false }
        }
        await store.receive(\.destination.transactionEditor.delegate.saved) {
            $0.destination = nil
        }
    }

    @Test func editTransaction_pushesEditor_andPopsOnDelete() async {
        let transaction = Domain.Transaction(id: UUID(1), type: .expense, amount: 5_000, category: .Default.food, title: "점심", date: now)
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.transactionClient.delete = { _ in }
        }

        await store.send(\.home.delegate.editTransaction, transaction) {
            $0.path[id: 0] = .transactionEditor(TransactionEditorFeature.State(transaction: transaction))
        }
        await store.send(\.path[id: 0].transactionEditor.deleteButtonTapped) {
            $0.path[id: 0]?.modify(\.transactionEditor) { $0.isSaving = true }
        }
        await store.receive(\.path[id: 0].transactionEditor.deleteFinished) {
            $0.path[id: 0]?.modify(\.transactionEditor) { $0.isSaving = false }
        }
        await store.receive(\.path[id: 0].transactionEditor.delegate.deleted) {
            $0.path = StackState()
        }
    }

    @Test func shortcut_pushesComingSoonScreenWithTitle() async {
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        }

        await store.send(\.home.delegate.open, .statistics) {
            $0.path[id: 0] = .comingSoon(ComingSoonFeature.State(title: "통계"))
        }
        await store.send(\.home.delegate.open, .transactionList) {
            $0.path[id: 1] = .comingSoon(ComingSoonFeature.State(title: "지출 리스트"))
        }
    }

    @Test func onAppear_firstLaunch_showsOnboarding_thenHomeAfterCompletion() async {
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.timeSyncClient.sync = { nil }
            $0.settingsClient.isOnboardingCompleted = { false }
            $0.settingsClient.completeOnboarding = {}
        }

        // 시간 동기화와 온보딩 확인은 병렬로 실행되어 받는 순서가 정해져 있지 않다
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.onAppear)
        await store.receive(\.onboardingStatusLoaded) {
            $0.isCheckingOnboarding = false
            $0.onboarding = OnboardingFeature.State()
        }
        await store.finish()
        await store.skipReceivedActions(strict: false)
        store.exhaustivity = .on

        await store.send(\.onboarding.skipButtonTapped) { $0.onboarding?.isCompleting = true }
        await store.receive(\.onboarding.completionSaved)
        await store.receive(\.onboarding.delegate.completed) { $0.onboarding = nil }
    }

    @Test func onAppear_returningUser_skipsOnboarding() async {
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.timeSyncClient.sync = { self.now }
            $0.settingsClient.isOnboardingCompleted = { true }
        }

        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.onAppear)
        await store.receive(\.onboardingStatusLoaded) { $0.isCheckingOnboarding = false }
        await store.finish()
        await store.skipReceivedActions(strict: false)
        #expect(store.state.onboarding == nil)
    }

    @Test func onAppear_statusCheckFails_showsHome() async {
        struct Failure: Error {}
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.timeSyncClient.sync = { nil }
            $0.settingsClient.isOnboardingCompleted = { throw Failure() }
        }

        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.onAppear)
        await store.receive(\.onboardingStatusLoaded) { $0.isCheckingOnboarding = false }
        await store.finish()
        await store.skipReceivedActions(strict: false)
        #expect(store.state.onboarding == nil)
    }

    @Test func scenePhaseActive_syncsTimeAndRefreshesHome_withoutRecheckingOnboarding() async {
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.timeSyncClient.sync = { self.now }
        }

        await store.send(.scenePhaseBecameActive)
        await store.receive(\.home.sceneBecameActive)
        await store.receive(\.timeSynced)
    }
}
