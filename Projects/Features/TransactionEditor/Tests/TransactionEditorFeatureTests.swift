import Clients
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import TransactionEditorFeature

@MainActor
struct TransactionEditorFeatureTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func save_createsExpenseWithTitleCategoryAndFixedFlag() async {
        let saved = LockIsolated<Domain.Transaction?>(nil)
        var state = TransactionEditorFeature.State(date: now)
        state.categoryID = TransactionCategory.Default.cafe.id
        let store = TestStore(initialState: state) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.transactionClient.save = { transaction in saved.setValue(transaction) }
        }

        await store.send(\.binding.amountText, "4,500") { $0.amountText = "4,500" }
        await store.send(\.binding.title, " 아메리카노 ") { $0.title = " 아메리카노 " }
        await store.send(\.binding.isFixed, true) { $0.isFixed = true }
        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.saveFinished) { $0.isSaving = false }
        await store.receive(\.delegate.saved)

        #expect(saved.value == Domain.Transaction(
            id: UUID(0),
            type: .expense,
            amount: 4_500,
            category: .Default.cafe,
            title: "아메리카노",
            date: now,
            isFixed: true
        ))
    }

    @Test func save_emptyTitle_usesDefaultTitle_andIncomeIsNeverFixed() async {
        let saved = LockIsolated<Domain.Transaction?>(nil)
        var state = TransactionEditorFeature.State(date: now)
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
        await store.send(\.binding.amountText, "3000000") { $0.amountText = "3000000" }
        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.saveFinished) { $0.isSaving = false }
        await store.receive(\.delegate.saved)

        #expect(saved.value?.title == "수익")
        #expect(saved.value?.category == .Default.income)
        #expect(saved.value?.isFixed == false)
    }

    @Test func onAppear_loadsExpenseCategoriesFromClient() async {
        let custom = TransactionCategory(id: UUID(9), type: .expense, name: "배달", colorKey: "purple", sortOrder: 7)
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

    @Test func amountOverLimit_cannotSave() async {
        var state = TransactionEditorFeature.State(date: now)
        state.amountText = "1000000001"
        #expect(state.isAmountOverLimit)
        #expect(state.canSave == false)

        let store = TestStore(initialState: state) { TransactionEditorFeature() }
        await store.send(.saveButtonTapped)
    }

    @Test func memo_isTruncatedToLimit() async {
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        }
        let long = String(repeating: "가", count: Transaction.memoLimit + 5)
        await store.send(\.binding.memo, long) {
            $0.memo = String(repeating: "가", count: Transaction.memoLimit)
        }
    }

    @Test func save_withoutAmount_doesNothing() async {
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        }
        await store.send(.saveButtonTapped)
    }

    @Test func delete_editMode_deletesAndDelegates() async {
        let transaction = Domain.Transaction(id: UUID(7), type: .expense, amount: 1_000, category: .Default.food, title: "점심", date: now)
        let deletedID = LockIsolated<UUID?>(nil)
        let store = TestStore(initialState: TransactionEditorFeature.State(transaction: transaction)) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.transactionClient.delete = { id in deletedID.setValue(id) }
        }

        await store.send(.deleteButtonTapped) { $0.isSaving = true }
        await store.receive(\.deleteFinished) { $0.isSaving = false }
        await store.receive(\.delegate.deleted)
        #expect(deletedID.value == transaction.id)
    }

    @Test func saveFailure_showsAlert() async {
        struct Failure: Error {}
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.transactionClient.save = { _ in throw Failure() }
        }
        store.exhaustivity = .off

        await store.send(\.binding.amountText, "500")
        await store.send(.saveButtonTapped)
        await store.receive(\.operationFailed)
        #expect(store.state.alert != nil)
        #expect(store.state.isSaving == false)
    }
}
