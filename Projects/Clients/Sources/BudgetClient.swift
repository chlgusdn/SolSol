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
        // 예산·알린 단계·결과를 한 상태로 두어 조건 확인과 갱신이 DAO 트랜잭션처럼 한 번에 일어나게 한다
        let store = PreviewStore(PreviewBudgetState(
            budget: .suggested(amount: 1_000_000, startDate: now, dueDate: dueDate)
        ))
        return Self(
            fetch: { await store.get().budget },
            save: { budget in
                await store.update {
                    $0.budget = budget
                    $0.notified = nil
                }
            },
            clear: { await store.update { $0.budget = nil } },
            observe: { store.stream(\.budget) },
            raiseNotifiedStatus: { status, budget in
                await store.modify { state in
                    guard state.budget == budget, status.newAlert(since: state.notified) != nil else { return false }
                    state.notified = status
                    return true
                }
            },
            close: { result, _, budget in
                await store.update {
                    $0.results.append(result)
                    $0.budget = budget
                    $0.notified = nil
                }
            },
            latestResult: { await store.get().results.last }
        )
    }
}

private struct PreviewBudgetState: Sendable {
    var budget: Budget?
    var notified: BudgetStatus?
    var results: [BudgetResult] = []
}
