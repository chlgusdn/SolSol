import DesignSystem
import SwiftUI

/// "+ 카테고리 추가" 점선 칩
struct AddCategoryChip: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SDSpacing.xxs) {
                SDIcon.plus.image.font(.system(size: SDSize.iconS - SDSpacing.xs, weight: .semibold))
                Text("카테고리 추가").font(.sd.callout)
            }
            .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            .padding(.horizontal, SDSpacing.m)
            .padding(.vertical, SDSpacing.s)
            .overlay(
                Capsule().strokeBorder(
                    DesignSystemAsset.textTertiary.swiftUIColor,
                    style: StrokeStyle(lineWidth: SDSize.borderThin, dash: [SDSpacing.xs])
                )
            )
            .frame(minHeight: SDSize.touchTarget)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
