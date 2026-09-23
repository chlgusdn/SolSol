import Clients
import ComposableArchitecture
import Domain
import Foundation
import Testing
@testable import HomeFeature

@MainActor
struct HomeFeatureTests {
    private let month = DateInterval.month(containing: Date(timeIntervalSince1970: 1_800_000_000))
    private var sample: Domain.Transaction {
        Domain.Transaction(id: UUID(0), type: .expense, amount: 12_000, category: .Default.food, title: "점심", date: month.start)
    }

    @Test func onAppear_observesTransactionsAndLoadsSummary() async {
        let sample = sample
        let store = TestStore(initialState: HomeFeature.State(month: month)) {
            HomeFeature()
        } withDependencies: {
            $0.transactionClient.observeMonth = { _ in
                AsyncThrowingStream { $0.yield([sample]); $0.finish() }
            }
            $0.transactionClient.fetchSummary = { _ in TransactionSummary(income: 0, expense: 12_000) }
        }

        await store.send(.onAppear) { $0.isLoading = true }
        await store.receive(\.transactionsUpdated) {
            $0.isLoading = false
            $0.transactions = [sample]
        }
        await store.receive(\.summaryLoaded) { $0.summary = TransactionSummary(income: 0, expense: 12_000) }
    }

    @Test func previousMonth_restartsObservationForNewMonth() async {
        let requested = LockIsolated<[DateInterval]>([])
        let store = TestStore(initialState: HomeFeature.State(month: month)) {
            HomeFeature()
        } withDependencies: {
            $0.transactionClient.observeMonth = { month in
                requested.withValue { $0.append(month) }
                return .finished()
            }
        }

        let previous = month.shiftedMonth(by: -1)
        await store.send(.previousMonthButtonTapped) {
            $0.month = previous
            $0.isLoading = true
        }
        await store.finish()
        #expect(requested.value == [previous])
    }

    @Test func observationFailure_setsError() async {
        struct Failure: Error {}
        let store = TestStore(initialState: HomeFeature.State(month: month)) {
            HomeFeature()
        } withDependencies: {
            $0.transactionClient.observeMonth = { _ in AsyncThrowingStream { $0.finish(throwing: Failure()) } }
        }

        await store.send(.onAppear) { $0.isLoading = true }
        await store.receive(\.loadFailed) {
            $0.isLoading = false
            $0.errorMessage = Failure().localizedDescription
        }
    }

    @Test func buttons_sendDelegates() async {
        let sample = sample
        let store = TestStore(initialState: HomeFeature.State(month: month)) { HomeFeature() }

        await store.send(.addButtonTapped)
        await store.receive(\.delegate.addTransaction)
        await store.send(.transactionTapped(sample))
        await store.receive(\.delegate.editTransaction)
    }
}
