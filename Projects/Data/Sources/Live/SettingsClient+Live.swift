import Clients
import Dependencies
import SQLiteData

extension SettingsClient: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.defaultDatabase) var database
        return .live(database: database)
    }

    static func live(database: any DatabaseWriter) -> Self {
        let dao = SettingsDAO(database: database)
        return Self(
            isOnboardingCompleted: dao.isOnboardingCompleted,
            completeOnboarding: dao.completeOnboarding
        )
    }
}
