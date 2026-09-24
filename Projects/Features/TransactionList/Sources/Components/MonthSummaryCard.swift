import Core
import DesignSystem
import Domain
import SwiftUI

struct MonthSummaryCard: View {
    let label: String
    let expense: Int
    let income: Int
    let budget: Budget?
    let usageRatio: Double?
    let onSetupBudget: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.m) {
            VStack(alignment: .leading, spacing: SDSpacing.xs) {
                Text(label)
                    .font(.sd.footnote)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                SDAmountText(expense, style: .expense, font: .sd.displayTitle)
            }
            .accessibilityElement(children: .combine)

            if let budget, let usageRatio {
                BudgetUsageView(budgetAmount: budget.amount, ratio: usageRatio, income: income)
            } else {
                IncomeLine(income: income)
                BudgetSetupBanner(action: onSetupBudget)
            }
        }
        .sdCard()
    }
}
