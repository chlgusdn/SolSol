import Core
import DesignSystem
import SwiftUI

/// 만기까지 남은 날 다이얼 — 링은 남은 기간 비율, 색은 사용률 단계
struct DueDial: View {
    let progress: Double
    let color: Color
    let daysRemaining: Int
    let dueDate: Date

    var body: some View {
        SDProgressRing(progress: progress, color: color, lineWidth: SDSpacing.m + SDSpacing.xxs) {
            VStack(spacing: SDSpacing.xxs) {
                Text("만기까지")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                Text("\(daysRemaining)일")
                    .font(.sd.displayHero)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                    .contentTransition(.numericText(value: Double(daysRemaining)))
                Text(dueDate.dotDateFormatted)
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
            }
        }
        .frame(width: DialMetrics.size, height: DialMetrics.size)
        .animation(.sd.standard, value: progress)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("만기까지 \(daysRemaining)일, \(dueDate.monthDayFormatted)")
    }
}

enum DialMetrics {
    /// 기획서 다이얼 지름
    static let size: CGFloat = 200
}
