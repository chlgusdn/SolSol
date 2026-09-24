import DesignSystem
import SwiftUI

struct InsightBanner: View {
    struct Insight {
        let icon: SDIcon
        let title: String
        let message: String
    }

    let insight: Insight

    var body: some View {
        HStack(spacing: SDSpacing.m) {
            insight.icon.image
                .font(.system(size: SDSize.iconM))
                .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
                .frame(width: SDSize.iconXL, height: SDSize.iconXL)
                .background(
                    RoundedRectangle(cornerRadius: SDRadius.s)
                        .fill(DesignSystemAsset.surface.swiftUIColor)
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SDSpacing.xxs) {
                Text(insight.title)
                    .font(.sd.callout)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Text(insight.message)
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, SDSpacing.m)
        .padding(.horizontal, SDSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: SDRadius.m)
                .fill(DesignSystemAsset.primary.swiftUIColor.opacity(SDOpacity.tint))
        )
        .accessibilityElement(children: .combine)
    }
}
