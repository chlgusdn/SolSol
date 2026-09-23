import Dependencies
import DependenciesMacros
import Foundation

/// NTP 시간 동기화. 현재 시각은 항상 `@Dependency(\.date)`로 얻는다.
@DependencyClient
public struct TimeSyncClient: Sendable {
    /// NTP 동기화 실행. 성공 시 동기화된 시각, 실패 시 nil
    public var sync: @Sendable () async -> Date? = { nil }
}

extension DependencyValues {
    public var timeSyncClient: TimeSyncClient {
        get { self[TimeSyncClient.self] }
        set { self[TimeSyncClient.self] = newValue }
    }
}

extension TimeSyncClient: TestDependencyKey {
    public static let testValue = Self()
    public static let previewValue = Self(sync: { nil })
}
