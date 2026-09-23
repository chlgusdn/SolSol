import Dependencies
import DependenciesMacros
import Foundation

/// 앱 설정 (온보딩 완료 여부 등)
@DependencyClient
public struct SettingsClient: Sendable {
    public var isOnboardingCompleted: @Sendable () async throws -> Bool
    public var completeOnboarding: @Sendable () async throws -> Void
}

extension DependencyValues {
    public var settingsClient: SettingsClient {
        get { self[SettingsClient.self] }
        set { self[SettingsClient.self] = newValue }
    }
}

extension SettingsClient: TestDependencyKey {
    public static let testValue = Self()

    public static var previewValue: Self {
        let store = PreviewStore<Bool>(false)
        return Self(
            isOnboardingCompleted: { await store.get() },
            completeOnboarding: { await store.update { $0 = true } }
        )
    }
}
