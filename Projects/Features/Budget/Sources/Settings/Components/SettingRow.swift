import DesignSystem
import SwiftUI

struct SettingRow: View {
    let icon: SDIcon
    let tint: Color
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SDSpacing.m) {
                icon.image
                    .font(.system(size: SDSize.iconS, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: SDSpacing.xxxl + SDSpacing.xs, height: SDSpacing.xxxl + SDSpacing.xs)
                    .background(RoundedRectangle(cornerRadius: SDRadius.s).fill(tint.opacity(SDOpacity.tint)))
                    .accessibilityHidden(true)
                Text(title)
                    .font(.sd.body)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Spacer(minLength: SDSpacing.s)
                Text(value)
                    .font(.sd.displayCaption)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                SDIcon.chevronRight.image
                    .font(.system(size: SDSize.iconS - SDSpacing.xs, weight: .semibold))
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
            }
            .padding(.vertical, SDSpacing.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("눌러서 바꿔요")
    }
}
