import Dependencies
import Domain
import Foundation
import Testing
@testable import Clients

struct PreviewValueTests {
    @Test func transaction_saveThenFetch() async throws {
        let client = TransactionClient.previewValue
        let month = DateInterval.month(containing: Date())
        let before = try await client.fetchMonth(month: month)

        let new = Transaction(id: UUID(), type: .expense, amount: 1_000, category: .Default.food, title: "간식", date: month.start)
        try await client.save(transaction: new)

        let after = try await client.fetchMonth(month: month)
        #expect(after.count == before.count + 1)
        #expect(after.contains(new))
    }

    @Test func transaction_observeEmitsAfterSave() async throws {
        let client = TransactionClient.previewValue
        let month = DateInterval.month(containing: Date())
        var iterator = client.observeMonth(month: month).makeAsyncIterator()
        let initial = try #require(try await iterator.next())

        try await client.save(transaction: Transaction(id: UUID(), type: .expense, amount: 1, category: .Default.cafe, title: "t", date: month.start))

        let updated = try #require(try await iterator.next())
        #expect(updated.count == initial.count + 1)
    }

    @Test func category_addAppendsAtEndOfType() async throws {
        let client = CategoryClient.previewValue
        try await client.add(category: TransactionCategory(id: UUID(), type: .expense, name: "배달", colorKey: "purple", sortOrder: 0))

        let expenses = try await client.fetchAll().filter { $0.type == .expense }
        #expect(expenses.last?.name == "배달")
        #expect(expenses.last?.sortOrder == TransactionCategory.Default.expenses.count + 1)
    }

    @Test func fixedExpense_setEnabledChangesTotal() async throws {
        let client = FixedExpenseClient.previewValue
        let items = try await client.fetchAll()
        let disabled = try #require(items.first { !$0.isEnabled })

        try await client.setEnabled(id: disabled.id, isEnabled: true)

        #expect(try await client.fetchAll().enabledTotal == items.enabledTotal + disabled.amount)
    }

    @Test func settings_completeOnboarding() async throws {
        let client = SettingsClient.previewValue
        #expect(try await client.isOnboardingCompleted() == false)
        try await client.completeOnboarding()
        #expect(try await client.isOnboardingCompleted() == true)
    }
}
