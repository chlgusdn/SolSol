import Foundation

extension DateInterval {
    /// `date`가 속한 달의 [1일 00:00, 다음 달 1일 00:00) 구간
    public static func month(containing date: Date, calendar: Calendar = .current) -> DateInterval {
        guard let interval = calendar.dateInterval(of: .month, for: date) else {
            return DateInterval(start: date, duration: 0)
        }
        return interval
    }

    /// `offset`개월 이동한 달 구간
    public func shiftedMonth(by offset: Int, calendar: Calendar = .current) -> DateInterval {
        let shifted = calendar.date(byAdding: .month, value: offset, to: start) ?? start
        return .month(containing: shifted, calendar: calendar)
    }
}
