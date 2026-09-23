import Foundation
import SQLiteData

struct SettingsDAO: Sendable {
    let database: any DatabaseWriter

    func isOnboardingCompleted() async throws -> Bool {
        try await database.read { db in
            try AppSettingRecord
                .where { $0.key.eq(AppSettingRecord.Key.onboardingCompleted) }
                .fetchOne(db)?
                .value == "true"
        }
    }

    func completeOnboarding() async throws {
        try await database.write { db in
            try AppSettingRecord.upsert {
                AppSettingRecord(key: AppSettingRecord.Key.onboardingCompleted, value: "true")
            }
            .execute(db)
        }
    }
}
