import Core
import DesignSystem
import Domain
import SwiftUI

/// 만기가 지난 예산의 결과 — 예산 대비 몇 % 더 썼는지·아꼈는지 + 새 예산 설정
struct ExpiredResult: View {
    let budget: Budget
    let spent: Int
    let onNewBudget: () -> Void

    private var percent: Int { budget.differencePercent(spent: spent) }
    private var isExceeded: Bool { percent > 0 }
    private var color: Color {
        isExceeded ? DesignSystemAsset.danger.swiftUIColor : DesignSystemAsset.primary.swiftUIColor
    }

    private var difference: String {
        let diff = spent - budget.amount
        if diff > 0 { return "+\(diff.wonFormatted)" }
        if diff < 0 { return "\((-diff).wonFormatted) 남김" }
        return "남김 없음"
    }

    var body: some View {
        VStack(spacing: SDSpacing.xl) {
            VStack(spacing: SDSpacing.s) {
                (isExceeded ? SDIcon.alert : SDIcon.check).image
                    .font(.system(size: SDSize.iconL, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: SDSize.iconXXL + SDSpacing.l, height: SDSize.iconXXL + SDSpacing.l)
                    .background(Circle().fill(color.opacity(SDOpacity.tint)))
                    .accessibilityHidden(true)
                Text("이번 예산이 끝났어요")
                    .font(.sd.callout)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                Text("\(BudgetDifferenceText.phrase(percent)) \(BudgetDifferenceText.emoji(percent))")
                    .font(.sd.displayHeadline)
                    .foregroundStyle(color)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text("\(budget.startDate.dotDateFormatted) ~ \(budget.dueDate.dotDateFormatted)")
                    .font(.sd.footnote)
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
            }

            VStack(alignment: .leading, spacing: SDSpacing.m) {
                row("예산", Text(budget.amount.wonFormatted))
                row("쓴 돈", Text(spent.wonFormatted).foregroundStyle(DesignSystemAsset.expense.swiftUIColor))
                Divider().overlay(DesignSystemAsset.border.swiftUIColor)
                row("차이", Text(difference).foregroundStyle(color))
            }
            .sdCard()
            .accessibilityElement(children: .combine)

            Button("새 예산 설정하기", action: onNewBudget)
                .buttonStyle(.sdPrimary)
        }
    }

    private func row(_ title: String, _ value: Text) -> some View {
        HStack {
            Text(title)
                .font(.sd.callout)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            Spacer()
            value.font(.sd.displayBody)
        }
    }
}
