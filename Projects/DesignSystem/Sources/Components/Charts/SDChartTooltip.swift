import Core
import SwiftUI

/// 차트 드래그 마커 툴팁 — 칸 제목 + 수익·지출 금액
struct SDChartTooltip: View {
    let point: SDChartPoint

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.xxs) {
            Text(point.title)
                .font(.sd.footnote)
                .foregroundStyle(DesignSystemAsset.onPrimary.swiftUIColor)
            Text("수익 \(point.income.wonFormatted)")
                .foregroundStyle(DesignSystemAsset.chartIncome.swiftUIColor)
            Text("지출 \(point.expense.wonFormatted)")
                .foregroundStyle(DesignSystemAsset.chartExpense.swiftUIColor)
        }
        .font(.sd.caption)
        .padding(SDSpacing.s)
        .background(
            RoundedRectangle(cornerRadius: SDRadius.s)
                .fill(DesignSystemAsset.surfaceDark.swiftUIColor.opacity(SDOpacity.toast))
        )
        .fixedSize()
    }
}
