import SQLiteData

/// 키-값 앱 설정
@Table("appSettings")
struct AppSettingRecord: Hashable, Sendable {
    @Column(primaryKey: true)
    let key: String
    var value: String

    enum Key {
        static let onboardingCompleted = "onboardingCompleted"
    }
}
