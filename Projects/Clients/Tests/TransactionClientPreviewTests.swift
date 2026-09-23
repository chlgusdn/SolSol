import Dependencies
import Domain
import Foundation
import Testing
@testable import Clients

struct TransactionClientPreviewTests {
    @Test func previewValue_saveThenFetch() async throws {
        let client = TransactionClient.previewValue
        let month = DateInterval.month(containing: Date())
        let before = try await client.fetchMonth(month: month)

        let new = Transaction(id: UUID(), type: .expense, amount: 1_000, category: .food, date: month.start)
        try await client.save(transaction: new)

        let after = try await client.fetchMonth(month: month)
        #expect(after.count == before.count + 1)
        #expect(after.contains(new))
    }
}
