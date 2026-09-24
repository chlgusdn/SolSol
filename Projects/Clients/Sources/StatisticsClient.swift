import Dependencies
import DependenciesMacros
import Domain
import Foundation

/// 통계 집계 조회. 합계·그룹화·최댓값은 DB가 계산하고 실제 구현(`liveValue`)은 Data 모듈에 있다.
@DependencyClient
public struct StatisticsClient: Sendable {
    /// `period` 전체와 `buckets` 칸별 합계를 집계한다. 거래가 바뀔 때마다 다시 보낸다
    public var observe: @Sendable (_ period: DateInterval, _ buckets: [DateInterval]) -> AsyncThrowingStream<StatisticsSnapshot, any Error> = { _, _ in .finished() }
}

extension DependencyValues {
    public var statisticsClient: StatisticsClient {
        get { self[StatisticsClient.self] }
        set { self[StatisticsClient.self] = newValue }
    }
}

extension StatisticsClient: TestDependencyKey {
    public static let testValue = Self()

    /// 프리뷰는 샘플 거래를 메모리에서 집계한다
    public static var previewValue: Self {
        Self(observe: { period, buckets in
            let samples = Transaction.previewSamples.filter { period.start <= $0.date && $0.date < period.end }
            func summary(_ interval: DateInterval) -> TransactionSummary {
                TransactionCalculator.summary(of: samples.filter { interval.start <= $0.date && $0.date < interval.end })
            }
            let expenses = samples.filter { $0.type == .expense }
            let snapshot = StatisticsSnapshot(
                bucketTotals: buckets.map(summary),
                categoryTotals: Dictionary(grouping: expenses, by: \.category).map {
                    CategoryTotal(category: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }, count: $0.value.count)
                },
                largestIncome: samples.filter { $0.type == .income }.max { $0.amount < $1.amount },
                largestExpense: expenses.max { $0.amount < $1.amount },
                transactionCount: samples.count
            )
            return AsyncThrowingStream { $0.yield(snapshot); $0.finish() }
        })
    }
}
