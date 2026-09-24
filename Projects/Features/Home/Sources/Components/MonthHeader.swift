import Core
import DesignSystem
import SwiftUI

struct MonthHeader: View {
    let month: Date
    let canMoveNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            arrow(.back, label: "이전 달", action: onPrevious)
            Spacer()
            Text(month.yearMonthFormatted)
                .font(.sd.displayHeadline)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                .contentTransition(.numericText())
                .accessibilityAddTraits(.isHeader)
            Spacer()
            arrow(.chevronRight, label: "다음 달", action: onNext)
                .disabled(!canMoveNext)
                .opacity(canMoveNext ? 1 : 0)
                .accessibilityHidden(!canMoveNext)
        }
    }

    private func arrow(_ icon: SDIcon, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon.image
                .font(.system(size: SDSize.iconS, weight: .semibold))
                .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                .frame(width: SDSize.touchTarget, height: SDSize.touchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
