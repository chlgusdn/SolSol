import Core
import DesignSystem
import Domain
import SwiftUI

/// "하루 평균 지출 23,400원" / "월 평균 …"
struct AverageSummary: View {
    let unit: StatisticsCalculator.Unit
    let average: TransactionSummary

    private var prefix: String { unit == .day ? "하루 평균" : "월 평균" }

    var body: some View {
        HStack(alignment: .top) {
            item("\(prefix) 지출", average.expense, style: .expense)
            Spacer()
            item("\(prefix) 수입", average.income, style: .income)
        }
    }

    private func item(_ title: String, _ amount: Int, style: SDAmountText.Style) -> some View {
        VStack(alignment: .leading, spacing: SDSpacing.xxs) {
            Text(title)
                .font(.sd.footnote)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            SDAmountText(amount, style: style, font: .sd.displayBody)
        }
        .accessibilityElement(children: .combine)
    }
}
