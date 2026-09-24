import DesignSystem
import SwiftUI

struct ChartIllustration: View {
    /// (막대 높이, 수입 여부)
    private let bars: [(height: CGFloat, isIncome: Bool)] = [(38, true), (72, false), (52, true), (90, false)]

    var body: some View {
        HStack(alignment: .bottom, spacing: SDSpacing.s) {
            ForEach(Array(bars.enumerated()), id: \.offset) { _, bar in
                let color = bar.isIncome
                    ? DesignSystemAsset.chartIncome.swiftUIColor
                    : DesignSystemAsset.chartExpense.swiftUIColor
                RoundedRectangle(cornerRadius: SDRadius.xs)
                    .fill(color)
                    .frame(width: SDSize.iconS, height: bar.height)
                    .sdShadow(.glow(color))
            }
        }
        .frame(width: IllustrationSize.card, height: IllustrationSize.square, alignment: .bottom)
        .padding(.bottom, SDSpacing.xxl)
        .frame(width: IllustrationSize.card, height: IllustrationSize.square)
        .background(
            RoundedRectangle(cornerRadius: SDRadius.l)
                .fill(DesignSystemAsset.surface.swiftUIColor)
                .sdShadow(.floating)
        )
    }
}
