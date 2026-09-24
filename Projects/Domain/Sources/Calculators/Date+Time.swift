import Foundation

extension Date {
    /// 이 날짜(일)에 `other`의 시·분·초를 붙인 시각 — 날짜만 고른 거래에 기록 시각을 유지할 때
    public func settingTime(from other: Date, calendar: Calendar = .current) -> Date {
        let time = calendar.dateComponents([.hour, .minute, .second], from: other)
        return calendar.date(
            bySettingHour: time.hour ?? 0,
            minute: time.minute ?? 0,
            second: time.second ?? 0,
            of: self
        ) ?? self
    }
}
