import Domain
import Foundation
import SQLiteData
import Testing
@testable import Data

struct BudgetDAOTests {
    private let start = Date(timeIntervalSince1970: 1_767_225_600)
    private var due: Date { start.addingTimeInterval(30 * 86_400) }

    @Test func save_replacesSingleBudget() async throws {
        let dao = BudgetDAO(database: try TestDatabase.make())
        #expect(try await dao.fetch() == nil)

        try await dao.save(.suggested(amount: 1_000_000, startDate: start, dueDate: due))
        let updated = Budget.suggested(amount: 500_000, startDate: start, dueDate: due)
        try await dao.save(updated)

        #expect(try await dao.fetch() == updated)
    }

    @Test func save_invalidAmounts_isRejectedByDatabase() async throws {
        let dao = BudgetDAO(database: try TestDatabase.make())
        let invalid = Budget(amount: 1_000, startDate: start, dueDate: due, warnAmount: 900, dangerAmount: 800)
        await #expect(throws: (any Error).self) { try await dao.save(invalid) }
    }

    @Test func clear_andObserve() async throws {
        let dao = BudgetDAO(database: try TestDatabase.make())
        var iterator = dao.observe().makeAsyncIterator()
        #expect(try await iterator.next() == .some(nil))

        let budget = Budget.suggested(amount: 1_000_000, startDate: start, dueDate: due)
        try await dao.save(budget)
        #expect(try await iterator.next() == budget)

        try await dao.clear()
        #expect(try await iterator.next() == .some(nil))
    }

    @Test func notifiedStatus_persists_andResetsWhenBudgetSaved() async throws {
        let dao = BudgetDAO(database: try TestDatabase.make())
        let budget = Budget.suggested(amount: 1_000_000, startDate: start, dueDate: due)
        try await dao.save(budget)
        #expect(try await dao.notifiedStatus() == nil)

        try await dao.setNotifiedStatus(.danger)
        #expect(try await dao.notifiedStatus() == .danger)
        #expect(try await dao.fetch() == budget)

        try await dao.save(budget.withAmount(2_000_000))
        #expect(try await dao.notifiedStatus() == nil)
    }

    @Test func close_invalidResult_isRejected_andKeepsBudget() async throws {
        let dao = BudgetDAO(database: try TestDatabase.make())
        let budget = Budget.suggested(amount: 1_000_000, startDate: start, dueDate: due)
        try await dao.save(budget)
        let negative = BudgetResult(id: UUID(), amount: 1_000_000, startDate: start, dueDate: due, spent: -1)

        await #expect(throws: (any Error).self) { try await dao.close(negative, closedAt: due, replacingWith: nil) }
        #expect(try await dao.fetch() == budget)
    }

    @Test func close_archivesResult_thenReplacesOrClearsBudget() async throws {
        let dao = BudgetDAO(database: try TestDatabase.make())
        let first = Budget.suggested(amount: 1_000_000, startDate: start, dueDate: due)
        try await dao.save(first)
        #expect(try await dao.latestResult() == nil)

        let firstResult = first.result(spent: 1_200_000, id: UUID())
        let next = Budget.suggested(amount: 900_000, startDate: due, dueDate: due.addingTimeInterval(30 * 86_400))
        try await dao.close(firstResult, closedAt: due, replacingWith: next)
        #expect(try await dao.fetch() == next)
        #expect(try await dao.latestResult() == firstResult)

        let nextResult = next.result(spent: 500_000, id: UUID())
        try await dao.close(nextResult, closedAt: due.addingTimeInterval(31 * 86_400), replacingWith: nil)
        #expect(try await dao.fetch() == nil)
        #expect(try await dao.latestResult() == nextResult)
    }
}

struct SettingsDAOTests {
    @Test func onboarding_defaultsToIncompleteThenPersists() async throws {
        let dao = SettingsDAO(database: try TestDatabase.make())
        #expect(try await dao.isOnboardingCompleted() == false)

        try await dao.completeOnboarding()
        try await dao.completeOnboarding()

        #expect(try await dao.isOnboardingCompleted() == true)
    }
}
