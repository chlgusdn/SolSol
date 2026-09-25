import Foundation

/// previewValue 전용 인메모리 저장소. 값이 바뀌면 관찰 중인 스트림에 새 값을 보낸다
actor PreviewStore<Value: Sendable> {
    private var value: Value
    private var continuations: [UUID: AsyncThrowingStream<Value, any Error>.Continuation] = [:]

    init(_ value: Value) {
        self.value = value
    }

    func get() -> Value {
        value
    }

    func update(_ transform: @Sendable (inout Value) -> Void) {
        modify(transform)
    }

    /// 읽고 판단하고 바꾸는 일을 actor 안에서 한 번에 한다 (조건부 갱신용)
    @discardableResult
    func modify<Result: Sendable>(_ transform: @Sendable (inout Value) -> Result) -> Result {
        let result = transform(&value)
        for continuation in continuations.values {
            continuation.yield(value)
        }
        return result
    }

    /// 현재 값을 먼저 보내고, 이후 변경마다 보낸다
    nonisolated func stream() -> AsyncThrowingStream<Value, any Error> {
        AsyncThrowingStream { continuation in
            let key = UUID()
            Task { await self.register(key, continuation) }
            continuation.onTermination = { _ in
                Task { await self.unregister(key) }
            }
        }
    }

    /// 현재 값에서 파생한 값을 보내는 스트림
    nonisolated func stream<T: Sendable>(
        _ transform: @escaping @Sendable (Value) -> T
    ) -> AsyncThrowingStream<T, any Error> {
        let source = stream()
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await value in source {
                        continuation.yield(transform(value))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func register(_ key: UUID, _ continuation: AsyncThrowingStream<Value, any Error>.Continuation) {
        continuations[key] = continuation
        continuation.yield(value)
    }

    private func unregister(_ key: UUID) {
        continuations[key] = nil
    }
}
