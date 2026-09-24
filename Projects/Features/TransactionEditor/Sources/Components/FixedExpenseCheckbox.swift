import DesignSystem
import SwiftUI

struct FixedExpenseCheckbox: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SDSpacing.s) {
                RoundedRectangle(cornerRadius: SDRadius.xs)
                    .fill(isOn ? DesignSystemAsset.primary.swiftUIColor : DesignSystemAsset.surface.swiftUIColor)
                    .strokeBorder(isOn ? .clear : DesignSystemAsset.textTertiary.swiftUIColor, lineWidth: SDSize.borderThick)
                    .frame(width: SDSize.iconM, height: SDSize.iconM)
                    .overlay {
                        if isOn {
                            SDIcon.check.image
                                .font(.system(size: SDSize.iconS - SDSpacing.xs, weight: .bold))
                                .foregroundStyle(DesignSystemAsset.onPrimary.swiftUIColor)
                        }
                    }
                Text("고정 지출로 등록")
                    .font(.sd.callout)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Spacer()
                Text("매달 반복")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
            }
            .padding(.horizontal, SDSpacing.l)
            .frame(minHeight: SDSize.touchTarget + SDSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: SDRadius.m)
                    .fill(DesignSystemAsset.surface.swiftUIColor)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}
