import Foundation

extension Date {
    /// 기기 언어와 관계없이 한국어 형식으로 표시한다
    private static let korean = Locale(identifier: "ko_KR")

    /// "2025년 1월"
    public var yearMonthFormatted: String {
        formatted(.dateTime.year().month().locale(Self.korean))
    }

    /// "1월 15일"
    public var monthDayFormatted: String {
        formatted(.dateTime.month().day().locale(Self.korean))
    }

    /// "1월 15일 수요일"
    public var monthDayWeekdayFormatted: String {
        formatted(.dateTime.month().day().weekday(.wide).locale(Self.korean))
    }

    /// "2025.01.15 (수)" — 기획서 고정 형식
    public var dotDateWeekdayFormatted: String {
        formatted(Date.VerbatimFormatStyle(
            format: "\(year: .defaultDigits).\(month: .twoDigits).\(day: .twoDigits) (\(weekday: .abbreviated))",
            locale: Self.korean,
            timeZone: .current,
            calendar: Calendar(identifier: .gregorian)
        ))
    }
}
