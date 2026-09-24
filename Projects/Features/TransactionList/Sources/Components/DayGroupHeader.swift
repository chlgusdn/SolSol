import Core
import DesignSystem
import SwiftUI

/// 날짜 그룹 헤더 — "2025.01.15 (수)" + 그날 지출 합계
struct DayGroupHeader: View {
    let day: Date
    let expense: Int

    var body: some View {
        HStack {
            Text(day.dotDateWeekdayFormatted)
                .font(.sd.footnote)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            Spacer()
            Text("지출 \(expense.wonFormatted)")
                .font(.sd.caption)
                .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
        }
        .textCase(nil)
        .accessibilityElement(children: .combine)
    }
}
