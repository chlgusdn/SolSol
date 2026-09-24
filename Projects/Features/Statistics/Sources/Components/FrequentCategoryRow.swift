import Core
import DesignSystem
import Domain
import SwiftUI

struct FrequentCategoryRow: View {
    let frequent: CategoryTotal

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.s) {
            HighlightHeading(title: "자주 사용된 지출", icon: .repeat, color: DesignSystemAsset.warning.swiftUIColor)
            HStack(spacing: SDSpacing.s) {
                Circle()
                    .fill(SDCategoryColor(rawValue: frequent.category.colorKey)?.color ?? DesignSystemAsset.textTertiary.swiftUIColor)
                    .frame(width: SDSpacing.s, height: SDSpacing.s)
                Text(frequent.category.name)
                    .font(.sd.body)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Text("\(frequent.count)회")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                Spacer()
                SDAmountText(frequent.amount, style: .expense)
            }
            .padding(SDSpacing.m)
            .background(RoundedRectangle(cornerRadius: SDRadius.m).fill(DesignSystemAsset.background.swiftUIColor))
            .accessibilityElement(children: .combine)
        }
    }
}
