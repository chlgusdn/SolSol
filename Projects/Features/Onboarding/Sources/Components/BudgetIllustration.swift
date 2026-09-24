import DesignSystem
import SwiftUI

struct BudgetIllustration: View {
    var body: some View {
        SDProgressRing(progress: 0.7) {
            VStack(spacing: SDSpacing.xxs) {
                Text("만기까지")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                Text("67일")
                    .font(.sd.displayHeadline)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Circle().fill(DesignSystemAsset.surface.swiftUIColor))
        }
        .frame(width: IllustrationSize.square, height: IllustrationSize.square)
    }
}
