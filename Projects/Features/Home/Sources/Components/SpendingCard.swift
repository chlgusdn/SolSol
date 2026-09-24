import Core
import DesignSystem
import SwiftUI

struct SpendingCard: View {
    let label: String
    let amount: Int
    let monthLabel: String
    let monthExpense: Int

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.xs) {
            Text(label)
                .font(.sd.footnote)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            SDAmountText(amount, font: .sd.displayTitle)
            Text("\(monthLabel) 총 지출 \(monthExpense.wonFormatted)")
                .font(.sd.footnote)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
        }
        .sdCard()
        .accessibilityElement(children: .combine)
    }
}
