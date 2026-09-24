import Core
import SwiftUI

/// 월 캘린더 — 일요일 시작 7열. 오늘은 `primary` 원, 선택일은 `primary` 링, 날짜 아래 금액.
/// `range`를 주면 기간 선택 모드: 양 끝은 `primary` 원, 사이는 연한 `primary`
public struct SDCalendar: View {
    /// 날짜 아래 표시할 금액
    public struct Amount: Equatable, Sendable {
        public let text: String
        public let accessibilityText: String

        public init(text: String, accessibilityText: String) {
            self.text = text
            self.accessibilityText = accessibilityText
        }
    }

    private let month: DateInterval
    private let today: Date
    private let selection: Date
    private let range: ClosedRange<Date>?
    private let calendar: Calendar
    private let amount: (Date) -> Amount?
    private let onSelect: (Date) -> Void

    public init(
        month: DateInterval,
        today: Date,
        selection: Date,
        range: ClosedRange<Date>? = nil,
        calendar: Calendar = .current,
        amount: @escaping (Date) -> Amount? = { _ in nil },
        onSelect: @escaping (Date) -> Void
    ) {
        self.month = month
        self.today = today
        self.selection = selection
        self.range = range
        self.calendar = calendar
        self.amount = amount
        self.onSelect = onSelect
    }

    private static let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    public var body: some View {
        LazyVGrid(columns: columns, spacing: SDSpacing.xxs) {
            ForEach(Self.weekdaySymbols.indices, id: \.self) { index in
                Text(Self.weekdaySymbols[index])
                    .font(.sd.caption)
                    .foregroundStyle(weekdayColor(index))
                    .padding(.bottom, SDSpacing.xs)
                    .accessibilityHidden(true)
            }
            ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.accessibilityHidden(true)
                }
            }
        }
    }

    /// 1일 앞은 요일에 맞춰 빈 칸으로 채운다
    private var cells: [Date?] {
        let leading = calendar.component(.weekday, from: month.start) - 1
        let count = calendar.range(of: .day, in: .month, for: month.start)?.count ?? 0
        let days = (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: month.start) }
        return Array(repeating: nil, count: leading) + days
    }

    private enum RangeRole { case endpoint, inside }

    private func rangeRole(_ day: Date) -> RangeRole? {
        guard let range else { return nil }
        if calendar.isDate(day, inSameDayAs: range.lowerBound) || calendar.isDate(day, inSameDayAs: range.upperBound) {
            return .endpoint
        }
        return range.contains(day) ? .inside : nil
    }

    private func dayCell(_ day: Date) -> some View {
        let role = rangeRole(day)
        let isToday = range == nil && calendar.isDate(day, inSameDayAs: today)
        let isSelected = range == nil ? calendar.isDate(day, inSameDayAs: selection) : role != nil
        let isFilled = isToday || role == .endpoint
        let amount = amount(day)
        let weekdayIndex = calendar.component(.weekday, from: day) - 1

        return Button {
            onSelect(day)
        } label: {
            VStack(spacing: SDSpacing.xxs) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.sd.displayCaption)
                    .foregroundStyle(isFilled ? DesignSystemAsset.onPrimary.swiftUIColor : weekdayColor(weekdayIndex, fallback: DesignSystemAsset.textPrimary.swiftUIColor))
                    .frame(width: SDSize.iconXL - SDSpacing.s, height: SDSize.iconXL - SDSpacing.s)
                    .background {
                        if isFilled {
                            Circle().fill(DesignSystemAsset.primary.swiftUIColor)
                        } else if role == .inside {
                            Circle().fill(DesignSystemAsset.primary.swiftUIColor.opacity(SDOpacity.tint))
                        } else if isSelected {
                            Circle().strokeBorder(DesignSystemAsset.primary.swiftUIColor, lineWidth: SDSize.borderThick)
                        }
                    }
                Text(amount?.text ?? " ")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: SDSize.touchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(day, isToday: isToday, amount: amount))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func weekdayColor(_ index: Int, fallback: Color = DesignSystemAsset.textSecondary.swiftUIColor) -> Color {
        switch index {
        case 0: DesignSystemAsset.calendarSunday.swiftUIColor
        case 6: DesignSystemAsset.calendarSaturday.swiftUIColor
        default: fallback
        }
    }

    private func accessibilityLabel(_ day: Date, isToday: Bool, amount: Amount?) -> String {
        [isToday ? "오늘" : nil, day.monthDayWeekdayFormatted, amount?.accessibilityText]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date.now
    let month = calendar.dateInterval(of: .month, for: today)!
    SDCalendar(
        month: month,
        today: today,
        selection: calendar.date(byAdding: .day, value: -2, to: today)!,
        amount: { day in
            calendar.component(.day, from: day) % 3 == 0
                ? SDCalendar.Amount(text: "1.2만", accessibilityText: "지출 12,000원")
                : nil
        },
        onSelect: { _ in }
    )
    .sdCard(.floating, padding: SDSpacing.m)
    .padding(SDSpacing.page)
    .sdScreen()
}
