import Dependencies
import DependenciesMacros
import Domain
import Foundation

/// 거래 저장소 인터페이스. 실제 구현(`liveValue`)은 Data 모듈에 있다.
@DependencyClient
public struct TransactionClient: Sendable {
    public var fetchMonth: @Sendable (_ month: DateInterval) async throws -> [Transaction]
    public var fetchSummary: @Sendable (_ month: DateInterval) async throws -> TransactionSummary
    /// 같은 id가 있으면 수정, 없으면 추가
    public var save: @Sendable (_ transaction: Transaction) async throws -> Void
    public var delete: @Sendable (_ id: Transaction.ID) async throws -> Void
    public var observeMonth: @Sendable (_ month: DateInterval) -> AsyncThrowingStream<[Transaction], any Error> = { _ in .finished() }
}

extension DependencyValues {
    public var transactionClient: TransactionClient {
        get { self[TransactionClient.self] }
        set { self[TransactionClient.self] = newValue }
    }
}

// MARK: - Preview

extension TransactionClient: TestDependencyKey {
    /// 매크로가 생성한 unimplemented 구현
    public static let testValue = Self()

    public static var previewValue: Self {
        let storage = InMemoryTransactionStorage(Transaction.previewSamples)
        return Self(
            fetchMonth: { month in await storage.transactions(in: month) },
            fetchSummary: { month in
                TransactionCalculator.summary(of: await storage.transactions(in: month))
            },
            save: { transaction in await storage.save(transaction) },
            delete: { id in await storage.delete(id) },
            observeMonth: { month in storage.observe(month) }
        )
    }
}

/// previewValue 전용 인메모리 저장소
private actor InMemoryTransactionStorage {
    private var items: [Transaction.ID: Transaction]
    private var continuations: [UUID: (DateInterval, AsyncThrowingStream<[Transaction], any Error>.Continuation)] = [:]

    init(_ transactions: [Transaction]) {
        items = Dictionary(uniqueKeysWithValues: transactions.map { ($0.id, $0) })
    }

    func transactions(in month: DateInterval) -> [Transaction] {
        items.values
            .filter { month.start <= $0.date && $0.date < month.end }
            .sorted { $0.date > $1.date }
    }

    func save(_ transaction: Transaction) {
        items[transaction.id] = transaction
        notify()
    }

    func delete(_ id: Transaction.ID) {
        items[id] = nil
        notify()
    }

    nonisolated func observe(_ month: DateInterval) -> AsyncThrowingStream<[Transaction], any Error> {
        AsyncThrowingStream { continuation in
            let key = UUID()
            Task { await self.register(key, month, continuation) }
            continuation.onTermination = { _ in
                Task { await self.unregister(key) }
            }
        }
    }

    private func register(
        _ key: UUID,
        _ month: DateInterval,
        _ continuation: AsyncThrowingStream<[Transaction], any Error>.Continuation
    ) {
        continuations[key] = (month, continuation)
        continuation.yield(transactions(in: month))
    }

    private func unregister(_ key: UUID) {
        continuations[key] = nil
    }

    private func notify() {
        for (month, continuation) in continuations.values {
            continuation.yield(transactions(in: month))
        }
    }
}

extension Transaction {
    /// 프리뷰용 샘플 데이터 (현재 달 기준)
    public static var previewSamples: [Transaction] {
        let now = Date()
        let calendar = Calendar.current
        func daysAgo(_ days: Int) -> Date { calendar.date(byAdding: .day, value: -days, to: now) ?? now }
        return [
            Transaction(id: UUID(), type: .income, amount: 3_200_000, category: .salary, memo: "월급", date: daysAgo(0)),
            Transaction(id: UUID(), type: .expense, amount: 12_000, category: .food, memo: "점심", date: daysAgo(0)),
            Transaction(id: UUID(), type: .expense, amount: 1_450, category: .transport, memo: "지하철", date: daysAgo(1)),
            Transaction(id: UUID(), type: .expense, amount: 54_900, category: .shopping, memo: "생필품", date: daysAgo(2))
        ]
    }
}
