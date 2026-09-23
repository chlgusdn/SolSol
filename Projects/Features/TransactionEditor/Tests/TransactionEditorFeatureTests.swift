import Clients
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import TransactionEditorFeature

@MainActor
struct TransactionEditorFeatureTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func save_createsTransactionAndDelegates() async {
        let saved = LockIsolated<Domain.Transaction?>(nil)
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.transactionClient.save = { transaction in saved.setValue(transaction) }
        }

        await store.send(\.binding.amountText, "12,000") { $0.amountText = "12,000" }
        await store.send(\.binding.memo, " 점심 ") { $0.memo = " 점심 " }
        await store.send(.saveButtonTapped) { $0.isSaving = true }
        await store.receive(\.saveFinished) { $0.isSaving = false }
        await store.receive(\.delegate.saved)

        #expect(saved.value == Domain.Transaction(
            id: UUID(0),
            type: .expense,
            amount: 12_000,
            category: .food,
            memo: "점심",
            date: now
        ))
    }

    @Test func save_withoutAmount_doesNothing() async {
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        }
        await store.send(.saveButtonTapped)
    }

    @Test func typeChanged_resetsUnavailableCategory() async {
        let store = TestStore(initialState: TransactionEditorFeature.State(date: now)) {
            TransactionEditorFeature()
        }
        await store.send(.typeChanged(.income)) {
            $0.type = .income
            $0.category = .salary
        }
    }

    @Test func delete_editMode_deletesAndDelegates() async {
        let transaction = Domain.Transaction(id: UUID(7), type: .expense, amount: 1_000, category: .food, date: now)
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
