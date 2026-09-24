import Core
import DesignSystem
import SwiftUI

/// 예산 사용률 바 — 80% 초과 시 `expense` 색
struct BudgetUsageView: View {
    let budgetAmount: Int
    let ratio: Double
    let income: Int

    private var percent: Int { Int((ratio * 100).rounded()) }
    private var color: Color {
        ratio > 0.8 ? DesignSystemAsset.expense.swiftUIColor : DesignSystemAsset.primary.swiftUIColor
    }

    var body: some View {
        VStack(spacing: SDSpacing.xs) {
            GeometryReader { proxy in
                Capsule()
                    .fill(DesignSystemAsset.border.swiftUIColor)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(color)
                            .frame(width: proxy.size.width * min(max(ratio, 0), 1))
                    }
            }
            .frame(height: SDSpacing.s)
            .animation(.sd.standard, value: ratio)
            .accessibilityHidden(true)

            HStack {
                Text("예산 \(budgetAmount.wonFormatted)의 \(Text("\(percent)%").foregroundStyle(color))")
                Spacer()
                Text("수입 \(Text(income.signedWonFormatted).foregroundStyle(DesignSystemAsset.income.swiftUIColor))")
            }
            .font(.sd.caption)
            .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
        }
        .accessibilityElement(children: .combine)
    }
}
