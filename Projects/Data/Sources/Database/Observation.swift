import GRDB
import SQLiteData

/// DB 관찰 → `AsyncThrowingStream`. 스트림이 끝나면 관찰도 취소된다
func observeDatabase<Value: Sendable>(
    _ database: any DatabaseWriter,
    fetch: @escaping @Sendable (Database) throws -> Value
) -> AsyncThrowingStream<Value, any Error> {
    let observation = ValueObservation.tracking(fetch)
    return AsyncThrowingStream { continuation in
        let task = Task {
            do {
                for try await value in observation.values(in: database) {
                    continuation.yield(value)
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}
