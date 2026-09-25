import Core
import DesignSystem
import Domain
import SwiftUI

/// "경고 · 예산의 75% 사용" + 안내. 초과면 "초과 · 예산보다 20% 더 썼어요" + 넘은 금액
struct StatusBanner: View {
    let status: BudgetStatus
    let usageRatio: Double
    let overAmount: Int
    let differencePercent: Int

    private var percent: Int { Int((usageRatio * 100).rounded()) }

    var body: some View {
        HStack(spacing: SDSpacing.m) {
            status.icon.image
                .font(.system(size: SDSize.iconM, weight: .semibold))
                .foregroundStyle(status.color)
                .frame(width: SDSize.iconXL, height: SDSize.iconXL)
                .background(RoundedRectangle(cornerRadius: SDRadius.s).fill(DesignSystemAsset.surface.swiftUIColor))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SDSpacing.xxs) {
                Text(status == .exceeded
                     ? "\(status.displayName) · \(BudgetDifferenceText.phrase(differencePercent))"
                     : "\(status.displayName) · 예산의 \(percent)% 사용")
                    .font(.sd.body)
                    .foregroundStyle(status.color)
                Text(status == .exceeded
                     ? "\(overAmount.wonFormatted) 넘었어요. \(status.message)"
                     : status.message)
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            }
            Spacer(minLength: 0)
        }
        .padding(SDSpacing.l)
        .background(RoundedRectangle(cornerRadius: SDRadius.m).fill(status.color.opacity(SDOpacity.tint)))
        .accessibilityElement(children: .combine)
    }
}
