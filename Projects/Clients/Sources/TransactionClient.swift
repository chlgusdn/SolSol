import Dependencies
import DependenciesMacros
import Domain
import Foundation

/// 거래 저장소 인터페이스. 실제 구현(`liveValue`)은 Data 모듈에 있다.
@DependencyClient
public struct TransactionClient: Sendable {
    /// 구간 [start, end)의 거래 (최신순)
    public var fetch: @Sendable (_ interval: DateInterval) async throws -> [Transaction]
    /// 구간의 수입·지출 합계 (DB 집계)
    public var fetchSummary: @Sendable (_ interval: DateInterval) async throws -> TransactionSummary
    /// 같은 id가 있으면 수정, 없으면 추가
    public var save: @Sendable (_ transaction: Transaction) async throws -> Void
    public var delete: @Sendable (_ id: Transaction.ID) async throws -> Void
    /// 구간의 거래를 관찰한다. DB가 바뀔 때마다 다시 보낸다
    public var observe: @Sendable (_ interval: DateInterval) -> AsyncThrowingStream<[Transaction], any Error> = { _ in .finished() }
}

extension DependencyValues {
    public var transactionClient: TransactionClient {
        get { self[TransactionClient.self] }
        set { self[TransactionClient.self] = newValue }
    }
}

extension TransactionClient: TestDependencyKey {
    /// 매크로가 생성한 unimplemented 구현
    public static let testValue = Self()

    public static var previewValue: Self {
        let store = PreviewStore<[Transaction]>(Transaction.previewSamples)
        @Sendable func inInterval(_ items: [Transaction], _ interval: DateInterval) -> [Transaction] {
            items
                .filter { interval.start <= $0.date && $0.date < interval.end }
                .sorted { $0.date > $1.date }
        }
        return Self(
            fetch: { month in inInterval(await store.get(), month) },
            fetchSummary: { interval in TransactionCalculator.summary(of: inInterval(await store.get(), interval)) },
            save: { transaction in
                await store.update { items in
                    items.removeAll { $0.id == transaction.id }
                    items.append(transaction)
                }
            },
            delete: { id in await store.update { $0.removeAll { $0.id == id } } },
            observe: { month in store.stream { inInterval($0, month) } }
        )
    }
}

extension Transaction {
    /// 프리뷰용 샘플 데이터 (현재 달 기준)
    public static var previewSamples: [Transaction] {
        let now = Date()
        let calendar = Calendar.current
        func daysAgo(_ days: Int) -> Date { calendar.date(byAdding: .day, value: -days, to: now) ?? now }
        return [
            Transaction(id: UUID(), type: .income, amount: 3_200_000, category: .Default.income, title: "월급", date: daysAgo(0)),
            Transaction(id: UUID(), type: .expense, amount: 12_000, category: .Default.food, title: "점심", memo: "김치찌개", date: daysAgo(0)),
            Transaction(id: UUID(), type: .expense, amount: 4_500, category: .Default.cafe, title: "아메리카노", date: daysAgo(1)),
            Transaction(id: UUID(), type: .expense, amount: 1_450, category: .Default.transport, title: "지하철", date: daysAgo(1)),
            Transaction(id: UUID(), type: .expense, amount: 13_500, category: .Default.subscription, title: "넷플릭스", date: daysAgo(3), isFixed: true)
        ]
    }
}
