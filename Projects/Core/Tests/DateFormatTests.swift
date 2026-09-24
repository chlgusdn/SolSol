import Foundation
import Testing
@testable import Core

struct DateFormatTests {
    private let date: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
    }()

    @Test func formats_useKoreanRegardlessOfDeviceLocale() {
        #expect(date.yearMonthFormatted == "2025년 1월")
        #expect(date.monthDayFormatted == "1월 15일")
        #expect(date.monthDayWeekdayFormatted == "1월 15일 수요일")
    }
}
