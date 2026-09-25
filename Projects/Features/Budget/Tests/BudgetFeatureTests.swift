import Clients
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import BudgetFeature

@MainActor
struct BudgetStatusFeatureTests {
    private let calendar = Calendar.current
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func day(_ offset: Int) -> Date {
        calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: now)!)
    }

    private var budget: Budget {
        .suggested(amount: 1_000_000, startDate: day(-10), dueDate: day(10))
    }

    @Test func onAppear_loadsBudget_thenSpentWithinBudgetPeriod() async {
        let budget = budget
        let requested = LockIsolated<[DateInterval]>([])
        let store = TestStore(initialState: BudgetStatusFeature.State(today: now)) {
            BudgetStatusFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.budgetClient.observe = { AsyncThrowingStream { $0.yield(budget); $0.finish() } }
            $0.transactionClient.fetchSummary = { interval in
                requested.withValue { $0.append(interval) }
                return TransactionSummary(expense: 750_000)
            }
        }

        await store.send(.onAppear)
        await store.receive(\.budgetUpdated) { $0.budget = budget }
        await store.receive(\.spentLoaded) {
            $0.spent = 750_000
            $0.hasLoaded = true
        }

        #expect(requested.value == [budget.period()])
        #expect(store.state.status == .warning)
        #expect(store.state.usageRatio == 0.75)
        #expect(store.state.remaining == 250_000)
        #expect(store.state.daysRemaining == 10)
        #expect(store.state.remainingPeriodRatio == 0.5)
    }

    @Test func noBudget_showsEmptyState() async {
        let store = TestStore(initialState: BudgetStatusFeature.State(today: now)) {
            BudgetStatusFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.budgetClient.observe = { AsyncThrowingStream { $0.yield(nil); $0.finish() } }
        }

        await store.send(.onAppear)
        await store.receive(\.budgetUpdated) { $0.hasLoaded = true }
        #expect(store.state.status == nil)
    }

    @Test func exceeded_andExpired_states() {
        var state = BudgetStatusFeature.State(today: now)
        state.budget = budget
        state.spent = 1_200_000
        #expect(state.status == .exceeded)
        #expect(state.overAmount == 200_000)
        #expect(!state.isExpired)

        state.today = day(11)
        #expect(state.isExpired)
    }

    @Test func delete_activeBudget_clearsWithoutResult() async {
        let cleared = LockIsolated(false)
        var state = BudgetStatusFeature.State(today: now)
        state.budget = budget
        let store = TestStore(initialState: state) {
            BudgetStatusFeature()
        } withDependencies: {
            $0.budgetClient.clear = { cleared.setValue(true) }
        }

        await store.send(.deleteButtonTapped) {
            $0.alert = AlertState {
                TextState("예산을 삭제할까요?")
            } actions: {
                ButtonState(role: .destructive, action: .confirmDelete) { TextState("삭제") }
                ButtonState(role: .cancel) { TextState("취소") }
            } message: {
                TextState("진행 중인 예산이 사라져요")
            }
        }
        await store.send(\.alert.confirmDelete) { $0.alert = nil }
        await store.receive(\.deleteFinished)
        #expect(cleared.value)
    }

    @Test func delete_expiredBudget_archivesResultWithSpentFromDatabase() async {
        let closed = LockIsolated<(BudgetResult, Budget?)?>(nil)
        var state = BudgetStatusFeature.State(today: day(11))
        state.budget = budget
        // 화면의 spent를 아직 못 불러온 상태여도 DB 합계로 기록한다
        state.spent = 0
        let store = TestStore(initialState: state) {
            BudgetStatusFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.uuid = .incrementing
            $0.transactionClient.fetchSummary = { _ in TransactionSummary(expense: 1_200_000) }
            $0.budgetClient.close = { result, _, next in closed.setValue((result, next)) }
        }
        store.exhaustivity = .off

        await store.send(.deleteButtonTapped)
        await store.send(\.alert.confirmDelete)
        await store.receive(\.deleteFinished)
        #expect(closed.value?.0 == budget.result(spent: 1_200_000, id: UUID(0)))
        #expect(closed.value?.1 == nil)
    }

    @Test func delete_expiredBudget_summaryFailure_keepsBudget() async {
        struct Failure: Error {}
        var state = BudgetStatusFeature.State(today: day(11))
        state.budget = budget
        let store = TestStore(initialState: state) {
            BudgetStatusFeature()
        } withDependencies: {
            $0.date = .constant(now)
            $0.uuid = .incrementing
            $0.transactionClient.fetchSummary = { _ in throw Failure() }
        }
        store.exhaustivity = .off

        await store.send(.deleteButtonTapped)
        await store.send(\.alert.confirmDelete)
        await store.receive(\.loadFailed)
        #expect(store.state.budget == state.budget)
    }

    @Test func buttons_sendDelegates() async {
        let store = TestStore(initialState: BudgetStatusFeature.State(today: now)) { BudgetStatusFeature() }

        await store.send(.settingsButtonTapped)
        await store.receive(\.delegate.openSettings)
        await store.send(.addExpenseButtonTapped)
        await store.receive(\.delegate.addExpense)
    }
}

@MainActor
struct BudgetSettingsFeatureTests {
    private let calendar = Calendar.current
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func day(_ offset: Int) -> Date {
        calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: now)!)
    }

    @Test func init_newBudgetStartsTodayUntilMonthEnd_andCannotSave() {
        let state = BudgetSettingsFeature.State(today: now)
        let monthEnd = DateInterval.month(containing: now).end

        #expect(state.draft.startDate == day(0))
        #expect(state.draft.dueDate == calendar.date(byAdding: .day, value: -1, to: monthEnd))
        #expect(state.draft.amount == 0)
        #expect(state.validationMessage == "예산 금액을 입력해요")
        #expect(!state.canSave)
    }

    @Test func onAppear_existingBudget_isEdited() async {
        let existing = Budget.suggested(amount: 500_000, startDate: day(-3), dueDate: day(20))
        let store = TestStore(initialState: BudgetSettingsFeature.State(today: now)) {
            BudgetSettingsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.budgetClient.fetch = { existing }
        }

        await store.send(.onAppear)
        await store.receive(\.loaded) {
            $0.hasLoaded = true
            $0.draft = existing
            $0.isExisting = true
        }
        #expect(store.state.canSave)
    }

    @Test func loadFailure_blocksSave_untilRetrySucceeds() async {
        struct Failure: Error {}
        let existing = Budget.suggested(amount: 500_000, startDate: day(-3), dueDate: day(20))
        let fails = LockIsolated(true)
        let store = TestStore(initialState: BudgetSettingsFeature.State(today: now)) {
            BudgetSettingsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.budgetClient.fetch = {
                if fails.value { throw Failure() }
                return existing
            }
        }

        await store.send(.onAppear)
        await store.receive(\.loadFailed) { $0.loadErrorMessage = Failure().localizedDescription }
        #expect(!store.state.hasLoaded)
        #expect(!store.state.canSave)

        fails.setValue(false)
        await store.send(.retryLoadButtonTapped) { $0.loadErrorMessage = nil }
        await store.receive(\.loaded) {
            $0.hasLoaded = true
            $0.draft = existing
            $0.isExisting = true
        }
        #expect(store.state.canSave)
    }

    @Test func onAppear_noBudget_showsLatestResult() async {
        let last = BudgetResult(id: UUID(9), amount: 1_000_000, startDate: day(-40), dueDate: day(-11), spent: 1_200_000)
        let store = TestStore(initialState: BudgetSettingsFeature.State(today: now)) {
            BudgetSettingsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.budgetClient.fetch = { nil }
            $0.budgetClient.latestResult = { last }
        }

        await store.send(.onAppear)
        await store.receive(\.loaded) {
            $0.hasLoaded = true
            $0.lastResult = last
        }
        #expect(!store.state.isExisting)
    }

    @Test func expiredBudget_startsNew_andArchivesItOnSave() async {
        let expired = Budget.suggested(amount: 1_000_000, startDate: day(-40), dueDate: day(-11))
        let closed = LockIsolated<(BudgetResult, Budget?)?>(nil)
        let store = TestStore(initialState: BudgetSettingsFeature.State(today: now)) {
            BudgetSettingsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date = .constant(now)
            $0.budgetClient.fetch = { expired }
            $0.transactionClient.fetchSummary = { _ in TransactionSummary(expense: 1_200_000) }
            $0.budgetClient.close = { result, _, next in closed.setValue((result, next)) }
        }

        let result = expired.result(spent: 1_200_000, id: UUID(0))
        await store.send(.onAppear)
        await store.receive(\.loaded) {
            $0.hasLoaded = true
            $0.lastResult = result
            $0.pendingResult = result
        }
        #expect(!store.state.isExisting)
        #expect(store.state.draft.startDate == day(0))

        await store.send(.amountRowTapped(.budget)) {
            $0.amountEntry = AmountEntryFeature.State(field: .budget, amount: 0)
        }
        await store.send(\.amountEntry.keypadTapped, .digit(9)) { $0.amountEntry?.amount = 9 }
        await store.send(\.amountEntry.keypadTapped, .doubleZero) { $0.amountEntry?.amount = 900 }
        await store.send(\.amountEntry.keypadTapped, .doubleZero) { $0.amountEntry?.amount = 90_000 }
        await store.send(\.amountEntry.keypadTapped, .digit(0)) { $0.amountEntry?.amount = 900_000 }
        await store.send(\.amountEntry.confirmButtonTapped)
        await store.receive(\.amountEntry.delegate.confirmed, 900_000) {
            $0.draft = $0.draft.withAmount(900_000)
            $0.amountEntry = nil
        }
        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.saveFinished) { $0.savedCount = 1 }
        await store.receive(\.delegate.saved)

        #expect(closed.value?.0 == result)
        #expect(closed.value?.1 == store.state.draft)
    }

    @Test func budgetAmount_viaKeypad_setsSuggestedThresholds_thenSaves() async {
        let saved = LockIsolated<Budget?>(nil)
        var state = BudgetSettingsFeature.State(today: now)
        state.hasLoaded = true
        let store = TestStore(initialState: state) {
            BudgetSettingsFeature()
        } withDependencies: {
            $0.budgetClient.save = { saved.setValue($0) }
        }

        await store.send(.amountRowTapped(.budget)) {
            $0.amountEntry = AmountEntryFeature.State(field: .budget, amount: 0)
        }
        await store.send(\.amountEntry.keypadTapped, .digit(1)) { $0.amountEntry?.amount = 1 }
        await store.send(\.amountEntry.keypadTapped, .doubleZero) { $0.amountEntry?.amount = 100 }
        await store.send(\.amountEntry.keypadTapped, .doubleZero) { $0.amountEntry?.amount = 10_000 }
        await store.send(\.amountEntry.keypadTapped, .doubleZero) { $0.amountEntry?.amount = 1_000_000 }
        await store.send(\.amountEntry.confirmButtonTapped)
        await store.receive(\.amountEntry.delegate.confirmed, 1_000_000) {
            $0.draft.amount = 1_000_000
            $0.draft.warnAmount = 700_000
            $0.draft.dangerAmount = 900_000
            $0.amountEntry = nil
        }
        #expect(store.state.canSave)

        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.saveFinished) { $0.savedCount = 1 }
        await store.receive(\.delegate.saved)
        #expect(saved.value == store.state.draft)
    }

    @Test func invalidThresholds_blockSave_withMessage() async {
        var state = BudgetSettingsFeature.State(today: now)
        state.hasLoaded = true
        state.draft = .suggested(amount: 1_000_000, startDate: day(0), dueDate: day(10))
        let store = TestStore(initialState: state) { BudgetSettingsFeature() }

        await store.send(.amountRowTapped(.warning)) {
            $0.amountEntry = AmountEntryFeature.State(field: .warning, amount: 700_000)
        }
        await store.send(\.amountEntry.keypadTapped, .digit(0)) { $0.amountEntry?.amount = 7_000_000 }
        await store.send(\.amountEntry.confirmButtonTapped)
        await store.receive(\.amountEntry.delegate.confirmed, 7_000_000) {
            $0.draft.warnAmount = 7_000_000
            $0.amountEntry = nil
        }

        #expect(!store.state.canSave)
        #expect(store.state.validationMessage == "경고 금액은 0원보다 크고 위험 금액보다 작아야 해요")
        await store.send(.saveButtonTapped)
    }

    @Test func dateSelection_setsStartAndDue_andRejectsDueBeforeStart() async {
        var state = BudgetSettingsFeature.State(today: now)
        state.hasLoaded = true
        state.draft = .suggested(amount: 1_000_000, startDate: day(0), dueDate: day(10))
        let store = TestStore(initialState: state) { BudgetSettingsFeature() }

        await store.send(.dateRowTapped(.due)) { $0.datePickerField = .due }
        await store.send(.dateSelected(.due, calendar.date(byAdding: .hour, value: 5, to: day(-2))!)) {
            $0.draft.dueDate = self.day(-2)
            $0.datePickerField = nil
        }
        #expect(store.state.validationMessage == "만기일은 시작일 이후여야 해요")

        await store.send(.dateRowTapped(.start)) { $0.datePickerField = .start }
        await store.send(.dateSelected(.start, day(-5))) {
            $0.draft.startDate = self.day(-5)
            $0.datePickerField = nil
        }
        #expect(store.state.canSave)
    }

    @Test func amountEntry_overLimit_shakes_andZeroCannotConfirm() async {
        let store = TestStore(initialState: AmountEntryFeature.State(field: .budget, amount: 100_000_000)) {
            AmountEntryFeature()
        }

        await store.send(.keypadTapped(.digit(9))) { $0.shakeCount = 1 }
        let zero = TestStore(initialState: AmountEntryFeature.State(field: .budget, amount: 0)) { AmountEntryFeature() }
        await zero.send(.confirmButtonTapped)
    }

    @Test func saveFailure_showsMessage_andAllowsRetry() async {
        struct Failure: Error, LocalizedError { var errorDescription: String? { "디스크 오류" } }
        var state = BudgetSettingsFeature.State(today: now)
        state.hasLoaded = true
        state.draft = .suggested(amount: 1_000_000, startDate: day(0), dueDate: day(10))
        let store = TestStore(initialState: state) {
            BudgetSettingsFeature()
        } withDependencies: {
            $0.budgetClient.save = { _ in throw Failure() }
        }

        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.operationFailed) {
            $0.isSaving = false
            $0.errorMessage = "디스크 오류"
        }
        #expect(store.state.canSave)
    }
}
