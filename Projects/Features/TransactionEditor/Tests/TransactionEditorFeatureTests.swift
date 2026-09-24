import Clients
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import TransactionEditorFeature

@MainActor
struct TransactionEditorFeatureTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func keypad_buildsAmount_andSaveCreatesExpense() async {
        let saved = LockIsolated<Domain.Transaction?>(nil)
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.transactionClient.save = { transaction in saved.setValue(transaction) }
        }

        #expect(!store.state.canSave)
        await store.send(.keypadTapped(.digit(4))) { $0.amount = 4 }
        await store.send(.keypadTapped(.digit(5))) { $0.amount = 45 }
        await store.send(.keypadTapped(.doubleZero)) { $0.amount = 4_500 }
        await store.send(.categoryTapped(TransactionCategory.Default.cafe.id)) {
            $0.categoryID = TransactionCategory.Default.cafe.id
        }
        await store.send(\.binding.title, " 아메리카노 ") { $0.title = " 아메리카노 " }
        await store.send(.fixedToggled) { $0.isFixed = true }
        await store.send(.saveButtonTapped) { $0.isSaving = true }

        let expected = Domain.Transaction(
            id: UUID(0), type: .expense, amount: 4_500, category: .Default.cafe,
            title: "아메리카노", date: now, isFixed: true
        )
        await store.receive(\.saveFinished) { $0.isSaved = true }
        await store.receive(.delegate(.saved(expected, isNew: true)))
        #expect(saved.value == expected)
    }

    @Test func overLimit_shakesAndShowsToast_keepingAmount() async {
        var state = TransactionEditorFeature.State(date: now)
        state.amount = 100_000_000
        let store = TestStore(initialState: state) { TransactionEditorFeature() }

        await store.send(.keypadTapped(.digit(1))) {
            $0.shakeCount = 1
            $0.toast = "최대 10억원까지 입력할 수 있어요"
        }
        await store.send(.keypadTapped(.digit(0))) { $0.amount = 1_000_000_000 }
    }

    @Test func income_isNeverFixed_andUsesIncomeCategory_withDefaultTitle() async {
        let saved = LockIsolated<Domain.Transaction?>(nil)
        var state = TransactionEditorFeature.State(date: now)
        state.amount = 3_000_000
        state.isFixed = true
        let store = TestStore(initialState: state) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.transactionClient.save = { transaction in saved.setValue(transaction) }
        }

        await store.send(.typeChanged(.income)) {
            $0.type = .income
            $0.isFixed = false
            $0.categoryID = TransactionCategory.Default.income.id
        }
        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.saveFinished) { $0.isSaved = true }
        await store.receive(\.delegate.saved)

        #expect(saved.value?.type == .income)
        #expect(saved.value?.category == .Default.income)
        #expect(saved.value?.title == "수익")
        #expect(saved.value?.isFixed == false)
    }

    @Test func edit_keepsId_andReportsNotNew() async {
        let original = Domain.Transaction(id: UUID(7), type: .expense, amount: 5_000, category: .Default.food, title: "점심", date: now)
        let store = TestStore(initialState: TransactionEditorFeature.State(transaction: original)) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.transactionClient.save = { _ in }
        }

        await store.send(.keypadTapped(.delete)) { $0.amount = 500 }
        await store.send(.saveButtonTapped) { $0.isSaving = true }
        var edited = original
        edited.amount = 500
        await store.receive(\.saveFinished) { $0.isSaved = true }
        await store.receive(.delegate(.saved(edited, isNew: false)))
    }

    @Test func save_afterSaved_isIgnored() async {
        var state = TransactionEditorFeature.State(date: now)
        state.amount = 1_000
        state.isSaving = true
        state.isSaved = true
        let store = TestStore(initialState: state) { TransactionEditorFeature() }

        await store.send(.saveButtonTapped)
    }

    @Test func dateSelected_changesDayButKeepsTime() async {
        let calendar = Calendar.current
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) { TransactionEditorFeature() }
        let threeDaysAgo = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -3, to: now)!)

        await store.send(.dateRowTapped) { $0.isDatePickerPresented = true }
        await store.send(.dateSelected(threeDaysAgo)) {
            $0.date = calendar.date(byAdding: .day, value: -3, to: self.now)!
            $0.isDatePickerPresented = false
        }
    }

    @Test func addCategory_appendsAndSelectsNewCategory() async {
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.categoryClient.add = { _ in }
        }

        await store.send(.addCategoryButtonTapped) {
            $0.destination = .addCategory(AddCategoryFeature.State())
        }
        await store.send(\.destination.addCategory.binding.name, "반려동물") {
            $0.destination?.modify(\.addCategory) { $0.name = "반려동물" }
        }
        await store.send(\.destination.addCategory.colorTapped, "purple") {
            $0.destination?.modify(\.addCategory) { $0.colorKey = "purple" }
        }
        await store.send(\.destination.addCategory.addButtonTapped) {
            $0.destination?.modify(\.addCategory) { $0.isSaving = true }
        }
        let added = TransactionCategory(id: UUID(0), type: .expense, name: "반려동물", colorKey: "purple", sortOrder: 0)
        await store.receive(\.destination.addCategory.delegate.added, added) {
            $0.expenseCategories.append(added)
            $0.categoryID = added.id
            $0.destination = nil
        }
    }

    @Test func addCategory_invalidName_cannotAdd() {
        var state = AddCategoryFeature.State()
        state.name = "   "
        #expect(!state.canAdd)
        state.name = "아홉글자카테고리임"
        #expect(!state.canAdd)
        state.name = " 여덟글자카테고리 "
        #expect(state.canAdd)
    }

    @Test func onAppear_loadsExpenseCategoriesFromClient() async {
        let custom = TransactionCategory(id: UUID(9), type: .expense, name: "반려동물", colorKey: "purple", sortOrder: 7)
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.categoryClient.fetchAll = { TransactionCategory.Default.all + [custom] }
        }

        await store.send(.onAppear)
        await store.receive(\.categoriesLoaded) {
            $0.expenseCategories = TransactionCategory.Default.expenses + [custom]
        }
    }

    @Test func memo_isTruncatedToLimit() async {
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) { TransactionEditorFeature() }
        let long = String(repeating: "가", count: Domain.Transaction.memoLimit + 5)

        await store.send(\.binding.memo, long) {
            $0.memo = String(repeating: "가", count: Domain.Transaction.memoLimit)
        }
    }

    @Test func saveFailure_showsAlert_andAllowsRetry() async {
        struct Failure: Error, LocalizedError { var errorDescription: String? { "디스크 오류" } }
        var state = TransactionEditorFeature.State(date: now)
        state.amount = 1_000
        let store = TestStore(initialState: state) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.transactionClient.save = { _ in throw Failure() }
        }

        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.saveFailed) {
            $0.isSaving = false
            $0.alert = AlertState {
                TextState("저장하지 못했어요")
            } message: {
                TextState("디스크 오류")
            }
        }
        #expect(store.state.canSave)
    }
}
