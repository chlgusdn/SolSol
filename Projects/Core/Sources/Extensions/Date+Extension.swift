//
//  Date+Extension.swift
//  SolSol
//
//  Created by NUNU:D on 6/6/25.
//

import Foundation
import Kronos

public extension Date {

    /// NTP 동기화된 현재 시각. 동기화 전이면 시스템 시각으로 fallback.
    static var ntpNow: Date {
        Clock.now ?? Date()
    }

    var millisecond: TimeInterval {
        return floor(self.timeIntervalSince1970 * 1000)
    }

    var second: TimeInterval {
        return floor(self.timeIntervalSince1970)
    }

    var minute: TimeInterval {
        return floor(self.timeIntervalSince1970 / 60)
    }

    var hour: TimeInterval {
        return floor(self.timeIntervalSince1970 / (60 * 60))
    }

    func toString(for format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    func subtracting(milliseconds: Int) -> Date {
        return self.addingTimeInterval(-Double(milliseconds) / 1000.0)
    }

    func daysAgo(_ days: Int) -> Date {
        return Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: self
        ) ?? self
    }

    func adding(days: Int) -> Date {
        return Calendar.current.date(
            byAdding: .day,
            value: days,
            to: self
        ) ?? self
    }

    func adding(compo: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(
            byAdding: compo,
            value: value,
            to: self
        ) ?? self
    }
}
