import DesignSystem
import SwiftUI

/// 아이콘 + 입력 내용 한 줄
struct InputRow<Content: View>: View {
    let icon: SDIcon
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: SDSpacing.m) {
            icon.image
                .font(.system(size: SDSize.iconS, weight: .semibold))
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                .frame(width: SDSpacing.xxxl + SDSpacing.xs, height: SDSpacing.xxxl + SDSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: SDRadius.s)
                        .fill(DesignSystemAsset.textSecondary.swiftUIColor.opacity(SDOpacity.tint))
                )
                .accessibilityHidden(true)
            content
        }
        .padding(.vertical, SDSpacing.m)
        .contentShape(Rectangle())
    }
}
