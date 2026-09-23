import Dependencies
import DependenciesMacros
import Domain
import Foundation

/// 카테고리 저장소. 기본 카테고리는 마이그레이션이 만들고, 사용자는 지출 카테고리를 추가한다
@DependencyClient
public struct CategoryClient: Sendable {
    /// 유형 → 정렬 순서로 정렬된 전체 카테고리
    public var fetchAll: @Sendable () async throws -> [TransactionCategory]
    /// 새 카테고리 추가. `sortOrder`는 저장 시 같은 유형의 맨 뒤로 정해진다
    public var add: @Sendable (_ category: TransactionCategory) async throws -> Void
    public var observeAll: @Sendable () -> AsyncThrowingStream<[TransactionCategory], any Error> = { .finished() }
}

extension DependencyValues {
    public var categoryClient: CategoryClient {
        get { self[CategoryClient.self] }
        set { self[CategoryClient.self] = newValue }
    }
}

extension CategoryClient: TestDependencyKey {
    public static let testValue = Self()

    public static var previewValue: Self {
        let store = PreviewStore<[TransactionCategory]>(TransactionCategory.Default.all)
        return Self(
            fetchAll: { await store.get() },
            add: { category in
                await store.update { items in
                    var category = category
                    category.sortOrder = (items.filter { $0.type == category.type }.map(\.sortOrder).max() ?? 0) + 1
                    items.append(category)
                }
            },
            observeAll: { store.stream() }
        )
    }
}
