import Core
import DesignSystem
import Domain
import SwiftUI

/// 가장 큰 수익·가장 큰 지출·자주 사용된 지출
struct HighlightsSection: View {
    let largestIncome: Transaction?
    let largestExpense: Transaction?
    let frequentCategory: CategoryTotal?

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.l) {
            if let largestIncome {
                HighlightRow(
                    heading: "가장 큰 수익",
                    headingIcon: .trendingUp,
                    headingColor: DesignSystemAsset.primary.swiftUIColor,
                    transaction: largestIncome
                )
            }
            if let largestExpense {
                HighlightRow(
                    heading: "가장 큰 지출",
                    headingIcon: .alert,
                    headingColor: DesignSystemAsset.danger.swiftUIColor,
                    transaction: largestExpense
                )
            }
            if let frequentCategory {
                FrequentCategoryRow(frequent: frequentCategory)
            }
        }
    }
}
