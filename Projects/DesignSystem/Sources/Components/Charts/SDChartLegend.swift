import SwiftUI

/// 수익·지출 범례
struct SDChartLegend: View {
    var body: some View {
        HStack(spacing: SDSpacing.l) {
            item("수익", DesignSystemAsset.chartIncome.swiftUIColor)
            item("지출", DesignSystemAsset.chartExpense.swiftUIColor)
        }
        .font(.sd.caption)
        .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
        .accessibilityHidden(true)
    }

    private func item(_ title: String, _ color: Color) -> some View {
        HStack(spacing: SDSpacing.xs) {
            RoundedRectangle(cornerRadius: SDRadius.xs).fill(color).frame(width: SDSpacing.m, height: SDSpacing.s)
            Text(title)
        }
    }
}
