import Core
import DesignSystem
import SwiftUI

/// "2026.09.01 ~ 2026.09.24 ›" — 누르면 기간 선택 시트
struct PeriodButton: View {
    let period: DateInterval
    let action: () -> Void

    private var lastDay: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: period.end) ?? period.start
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: SDSpacing.s) {
                SDIcon.calendar.image
                    .font(.system(size: SDSize.iconM))
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                Text("\(period.start.dotDateFormatted) ~ \(lastDay.dotDateFormatted)")
                    .font(.sd.body)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Spacer()
                SDIcon.chevronRight.image
                    .font(.system(size: SDSize.iconS - SDSpacing.xs, weight: .semibold))
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
            }
            .padding(.horizontal, SDSpacing.l)
            .frame(minHeight: SDSize.touchTarget + SDSpacing.xs)
            .background(RoundedRectangle(cornerRadius: SDRadius.m).fill(DesignSystemAsset.background.swiftUIColor))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("기간, \(period.start.monthDayFormatted)부터 \(lastDay.monthDayFormatted)까지")
        .accessibilityHint("눌러서 기간을 바꿔요")
    }
}
