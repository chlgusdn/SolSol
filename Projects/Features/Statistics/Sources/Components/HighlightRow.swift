import Core
import DesignSystem
import Domain
import SwiftUI

struct HighlightRow: View {
    let heading: String
    let headingIcon: SDIcon
    let headingColor: Color
    let transaction: Transaction

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.s) {
            HighlightHeading(title: heading, icon: headingIcon, color: headingColor)
            SDTransactionRow(
                title: transaction.title,
                subtitle: "\(transaction.date.dotDateFormatted) · \(transaction.category.name)",
                amount: transaction.signedAmount,
                color: SDCategoryColor(rawValue: transaction.category.colorKey)?.color
                    ?? DesignSystemAsset.textSecondary.swiftUIColor,
                icon: SDIcon(key: transaction.category.iconKey)
            )
            .padding(.horizontal, SDSpacing.m)
            .background(RoundedRectangle(cornerRadius: SDRadius.m).fill(DesignSystemAsset.background.swiftUIColor))
        }
    }
}
