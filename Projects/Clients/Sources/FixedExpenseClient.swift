import Dependencies
import DependenciesMacros
import Domain
import Foundation

/// 고정 지출 저장소
@DependencyClient
public struct FixedExpenseClient: Sendable {
    /// 정렬 순서대로 정렬된 전체 항목
    public var fetchAll: @Sendable () async throws -> [FixedExpense]
    /// 같은 id가 있으면 수정, 없으면 맨 뒤에 추가
    public var save: @Sendable (_ item: FixedExpense) async throws -> Void
    /// 자동 등록 대상 체크 상태 변경
    public var setEnabled: @Sendable (_ id: FixedExpense.ID, _ isEnabled: Bool) async throws -> Void
    public var delete: @Sendable (_ id: FixedExpense.ID) async throws -> Void
    public var observeAll: @Sendable () -> AsyncThrowingStream<[FixedExpense], any Error> = { .finished() }
}

extension DependencyValues {
    public var fixedExpenseClient: FixedExpenseClient {
        get { self[FixedExpenseClient.self] }
        set { self[FixedExpenseClient.self] = newValue }
    }
}

extension FixedExpenseClient: TestDependencyKey {
    public static let testValue = Self()

    public static var previewValue: Self {
        let store = PreviewStore<[FixedExpense]>(FixedExpense.previewSamples)
        return Self(
            fetchAll: { await store.get() },
            save: { item in
                await store.update { items in
                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                        items[index] = item
                    } else {
                        var item = item
                        item.sortOrder = (items.map(\.sortOrder).max() ?? -1) + 1
                        items.append(item)
                    }
                }
            },
            setEnabled: { id, isEnabled in
                await store.update { items in
                    if let index = items.firstIndex(where: { $0.id == id }) { items[index].isEnabled = isEnabled }
                }
            },
            delete: { id in await store.update { $0.removeAll { $0.id == id } } },
            observeAll: { store.stream() }
        )
    }
}

extension FixedExpense {
    /// 프리뷰용 샘플 (프로토타입 기준)
    public static var previewSamples: [FixedExpense] {
        [
            FixedExpense(id: UUID(), name: "넷플릭스", amount: 13_500, isEnabled: true, sortOrder: 0),
            FixedExpense(id: UUID(), name: "티빙", amount: 13_500, isEnabled: true, sortOrder: 1),
            FixedExpense(id: UUID(), name: "유튜브 프리미엄", amount: 14_900, isEnabled: false, sortOrder: 2),
            FixedExpense(id: UUID(), name: "쏠쏠 헬스장", amount: 49_000, isEnabled: true, sortOrder: 3),
            FixedExpense(id: UUID(), name: "통신요금", amount: 55_000, isEnabled: false, sortOrder: 4),
            FixedExpense(id: UUID(), name: "월세", amount: 500_000, isEnabled: true, sortOrder: 5)
        ]
    }
}
