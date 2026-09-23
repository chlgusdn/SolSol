import Dependencies
import Foundation
@preconcurrency import Kronos

extension DateGenerator {
    /// NTP 동기화 시각, 미동기화 시 기기 시각
    public static let trusted = DateGenerator { Kronos.Clock.now ?? Date() }
}
