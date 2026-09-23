import Dependencies
import DependenciesMacros
import Domain
import Foundation

/// 텅장방지 예산 저장소 (예산은 하나만 존재)
@DependencyClient
public struct BudgetClient: Sendable {
    /// 설정된 예산. 미설정이면 nil
    public var fetch: @Sendable () async throws -> Budget?
    /// 예산 저장 (기존 예산을 교체)
    public var save: @Sendable (_ budget: Budget) async throws -> Void
    public var clear: @Sendable () async throws -> Void
    public var observe: @Sendable () -> AsyncThrowingStream<Budget?, any Error> = { .finished() }
}

extension DependencyValues {
    public var budgetClient: BudgetClient {
        get { self[BudgetClient.self] }
        set { self[BudgetClient.self] = newValue }
    }
}

extension BudgetClient: TestDependencyKey {
    public static let testValue = Self()

    public static var previewValue: Self {
        let now = Date()
        let dueDate = Calendar.current.date(byAdding: .day, value: 20, to: now) ?? now
        let store = PreviewStore<Budget?>(.suggested(amount: 1_000_000, startDate: now, dueDate: dueDate))
        return Self(
            fetch: { await store.get() },
            save: { budget in await store.update { $0 = budget } },
            clear: { await store.update { $0 = nil } },
            observe: { store.stream() }
        )
    }
}
