import DesignSystem
import SwiftUI

struct ShortcutCard: View {
    let icon: SDIcon
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: SDSpacing.xs) {
                icon.image
                    .font(.system(size: SDSize.iconS, weight: .semibold))
                    .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
                    .frame(width: SDSpacing.xxxl, height: SDSpacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: SDRadius.s)
                            .fill(DesignSystemAsset.primary.swiftUIColor.opacity(SDOpacity.tint))
                    )
                    .accessibilityHidden(true)
                Text(title)
                    .font(.sd.footnote)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Text(subtitle)
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.vertical, SDSpacing.m)
            .padding(.horizontal, SDSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: SDRadius.m)
                    .fill(DesignSystemAsset.surface.swiftUIColor)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}
