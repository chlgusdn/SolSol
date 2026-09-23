import Clients
import ComposableArchitecture
import Domain
import Foundation
import HomeFeature
import Testing
import TransactionEditorFeature
@testable import SolSol

@MainActor
struct AppFeatureTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func addTransaction_presentsEditorSheet_andDismissesOnSave() async {
        let store = TestStore(initialState: AppFeature.State(month: .month(containing: now))) {
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
        let transaction = Domain.Transaction(id: UUID(1), type: .expense, amount: 5_000, category: .food, date: now)
        let store = TestStore(initialState: AppFeature.State(month: .month(containing: now))) {
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

    @Test func onAppear_syncsTime() async {
        let store = TestStore(initialState: AppFeature.State(month: .month(containing: now))) {
            AppFeature()
        } withDependencies: {
            $0.timeSyncClient.sync = { self.now }
        }

        await store.send(.onAppear)
        await store.receive(\.timeSynced)
    }
}
