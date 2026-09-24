import Clients
import ComposableArchitecture
import Domain
import Foundation
import HomeFeature
import OnboardingFeature
import Testing
import TransactionEditorFeature
import TransactionListFeature
@testable import SolSol

@MainActor
struct AppFeatureTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func addFromHome_pushesEditorOnSelectedDay_thenToastAndMovesToList() async {
        let clock = TestClock()
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -2, to: now)!)
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.uuid = .incrementing
            $0.continuousClock = clock
            $0.transactionClient.save = { _ in }
        }

        let recordedAt = selectedDay.settingTime(from: now)
        await store.send(\.home.delegate.addTransaction, selectedDay) {
            $0.path[id: 0] = .transactionEditor(TransactionEditorFeature.State(date: recordedAt))
        }
        await store.send(\.path[id: 0].transactionEditor.keypadTapped, .digit(5)) {
            $0.path[id: 0]?.modify(\.transactionEditor) { $0.amount = 5 }
        }
        await store.send(\.path[id: 0].transactionEditor.saveButtonTapped) {
            $0.path[id: 0]?.modify(\.transactionEditor) { $0.isSaving = true }
        }
        await store.receive(\.path[id: 0].transactionEditor.saveFinished) {
            $0.path[id: 0]?.modify(\.transactionEditor) { $0.isSaved = true }
        }
        await store.receive(\.path[id: 0].transactionEditor.delegate.saved) {
            $0.toast = "지출을 저장했어요"
        }
        await clock.advance(by: .milliseconds(650))
        await store.receive(\.saveTransitionFinished) {
            $0.path[id: 0] = nil
            $0.path[id: 1] = .transactionList(TransactionListFeature.State(month: .month(containing: recordedAt), today: self.now))
        }
    }

    @Test func addFromList_returnsToThatList() async {
        let clock = TestClock()
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.continuousClock = clock
        }
        let transaction = Domain.Transaction(id: UUID(1), type: .income, amount: 5_000, category: .Default.income, title: "용돈", date: now)

        await store.send(\.home.delegate.open, .transactionList) {
            $0.path[id: 0] = .transactionList(TransactionListFeature.State(month: .month(containing: self.now), today: self.now))
        }
        await store.send(\.path[id: 0].transactionList.delegate.addTransaction) {
            $0.path[id: 1] = .transactionEditor(TransactionEditorFeature.State(date: self.now))
        }
        await store.send(.path(.element(id: 1, action: .transactionEditor(.delegate(.saved(transaction, isNew: true)))))) {
            $0.toast = "수익을 저장했어요"
        }
        await clock.advance(by: .milliseconds(650))
        await store.receive(\.saveTransitionFinished) {
            $0.path[id: 1] = nil
        }
    }

    @Test func edit_savesThenPopsBack_withEditToast() async {
        let clock = TestClock()
        let transaction = Domain.Transaction(id: UUID(1), type: .expense, amount: 5_000, category: .Default.food, title: "점심", date: now)
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(\.home.delegate.editTransaction, transaction) {
            $0.path[id: 0] = .transactionEditor(TransactionEditorFeature.State(transaction: transaction))
        }
        await store.send(.path(.element(id: 0, action: .transactionEditor(.delegate(.saved(transaction, isNew: false)))))) {
            $0.toast = "지출을 수정했어요"
        }
        await clock.advance(by: .milliseconds(650))
        await store.receive(\.saveTransitionFinished) {
            $0.path = StackState()
        }
    }

    @Test func saveTransition_afterUserLeftEditor_doesNothing() async {
        let clock = TestClock()
        let transaction = Domain.Transaction(id: UUID(1), type: .expense, amount: 5_000, category: .Default.food, title: "점심", date: now)
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(\.home.delegate.editTransaction, transaction) {
            $0.path[id: 0] = .transactionEditor(TransactionEditorFeature.State(transaction: transaction))
        }
        await store.send(.path(.element(id: 0, action: .transactionEditor(.delegate(.saved(transaction, isNew: true)))))) {
            $0.toast = "지출을 저장했어요"
        }
        await store.send(.path(.popFrom(id: 0))) { $0.path = StackState() }
        await clock.advance(by: .milliseconds(650))
        await store.receive(\.saveTransitionFinished)
    }

    @Test func shortcut_pushesComingSoonScreenWithTitle() async {
        let store = TestStore(initialState: AppFeature.State(today: now)) {
            AppFeature()
        }

        await store.send(\.home.delegate.open, .statistics) {
            $0.path[id: 0] = .comingSoon(ComingSoonFeature.State(title: "통계"))
        }
        await store.send(\.home.delegate.open, .fixedExpense) {
            $0.path[id: 1] = .comingSoon(ComingSoonFeature.State(title: "고정 지출"))
        }
    }

    @Test func viewAll_pushesTransactionListForHomeMonth_andRoutesItsDelegates() async {
        let transaction = Domain.Transaction(id: UUID(1), type: .expense, amount: 5_000, category: .Default.food, title: "점심", date: now)
        var initialState = AppFeature.State(today: now)
        initialState.home.month = initialState.home.month.shiftedMonth(by: -1)
        let store = TestStore(initialState: initialState) {
            AppFeature()
        } withDependencies: {
            $0.date = .constant(now)
        }

        await store.send(\.home.delegate.open, .transactionList) {
            $0.path[id: 0] = .transactionList(TransactionListFeature.State(month: initialState.home.month, today: self.now))
        }
        await store.send(\.path[id: 0].transactionList.delegate.editTransaction, transaction) {
            $0.path[id: 1] = .transactionEditor(TransactionEditorFeature.State(transaction: transaction))
        }
        await store.send(\.path[id: 0].transactionList.delegate.openBudgetSettings) {
            $0.path[id: 2] = .comingSoon(ComingSoonFeature.State(title: "예산 설정"))
        }
        await store.send(\.path[id: 0].transactionList.delegate.addTransaction) {
            $0.path[id: 3] = .transactionEditor(TransactionEditorFeature.State(date: self.now))
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
