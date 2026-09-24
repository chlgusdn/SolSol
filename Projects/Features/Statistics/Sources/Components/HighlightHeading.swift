import DesignSystem
import SwiftUI

struct HighlightHeading: View {
    let title: String
    let icon: SDIcon
    let color: Color

    var body: some View {
        HStack(spacing: SDSpacing.xs) {
            icon.image.font(.system(size: SDSize.iconS, weight: .semibold)).foregroundStyle(color)
            Text(title).font(.sd.footnote).foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
        }
        .accessibilityAddTraits(.isHeader)
    }
}
