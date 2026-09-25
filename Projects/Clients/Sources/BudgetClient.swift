import Dependencies
import DependenciesMacros
import Domain
import Foundation

/// 텅장방지 예산 저장소 (예산은 하나만 존재)
@DependencyClient
public struct BudgetClient: Sendable {
    /// 설정된 예산. 미설정이면 nil
    public var fetch: @Sendable () async throws -> Budget?
    /// 예산 저장 (기존 예산을 교체). 이미 알린 단계도 초기화된다
    public var save: @Sendable (_ budget: Budget) async throws -> Void
    public var clear: @Sendable () async throws -> Void
    public var observe: @Sendable () -> AsyncThrowingStream<Budget?, any Error> = { .finished() }
    /// `budget`이 지금 예산과 같고 이미 알린 단계보다 `status`가 심각하면 기록하고 true (원자적).
    /// 예산이 없거나 바뀌었거나 이미 알렸으면 false
    public var raiseNotifiedStatus: @Sendable (_ status: BudgetStatus, _ budget: Budget) async throws -> Bool
    /// 끝난 예산의 결과를 기록하고 `budget`으로 바꾼다 (nil이면 예산을 지운다)
    public var close: @Sendable (_ result: BudgetResult, _ closedAt: Date, _ budget: Budget?) async throws -> Void
    /// 가장 최근에 끝난 예산의 결과
    public var latestResult: @Sendable () async throws -> BudgetResult?
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
        let notified = PreviewStore<BudgetStatus?>(nil)
        let results = PreviewStore<[BudgetResult]>([])
        return Self(
            fetch: { await store.get() },
            save: { budget in
                await store.update { $0 = budget }
                await notified.update { $0 = nil }
            },
            clear: { await store.update { $0 = nil } },
            observe: { store.stream() },
            raiseNotifiedStatus: { status, budget in
                guard await store.get() == budget, status.newAlert(since: await notified.get()) != nil else { return false }
                await notified.update { $0 = status }
                return true
            },
            close: { result, _, budget in
                await results.update { $0.append(result) }
                await store.update { $0 = budget }
                await notified.update { $0 = nil }
            },
            latestResult: { await results.get().last }
        )
    }
}
