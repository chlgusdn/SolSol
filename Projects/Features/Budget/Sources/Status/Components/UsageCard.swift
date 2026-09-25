import Core
import DesignSystem
import Domain
import SwiftUI

/// 예산 사용 현황 — 경고·위험 표시가 있는 막대 + 지출·남은 예산
struct UsageCard: View {
    let budget: Budget
    let spent: Int
    let remaining: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.m) {
            HStack {
                Text("예산 사용 현황")
                    .font(.sd.footnote)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                Spacer()
                SDAmountText(budget.amount, font: .sd.displayCaption)
            }
            BudgetRangeBar(
                warnRatio: budget.usageRatio(spent: budget.warnAmount),
                dangerRatio: budget.usageRatio(spent: budget.dangerAmount),
                usedRatio: budget.usageRatio(spent: spent),
                fillColor: color
            )
            HStack {
                amount("지출 금액", spent, style: .expense)
                Spacer()
                amount(remaining < 0 ? "초과 금액" : "남은 예산", abs(remaining), style: remaining < 0 ? .expense : .income)
            }
        }
        .sdCard()
    }

    private func amount(_ title: String, _ value: Int, style: SDAmountText.Style) -> some View {
        VStack(alignment: .leading, spacing: SDSpacing.xxs) {
            Text(title)
                .font(.sd.caption)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            SDAmountText(value, style: style)
        }
        .accessibilityElement(children: .combine)
    }
}
