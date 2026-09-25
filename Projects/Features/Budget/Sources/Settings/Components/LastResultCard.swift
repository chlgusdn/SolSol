import Core
import DesignSystem
import Domain
import SwiftUI

/// 직전 예산 결과 — 넘었으면 경각심을, 지켰으면 칭찬을. 비율을 먼저, 금액은 작게
struct LastResultCard: View {
    let result: BudgetResult

    private var percent: Int { result.differencePercent }
    private var color: Color {
        percent > 0 ? DesignSystemAsset.danger.swiftUIColor : DesignSystemAsset.primary.swiftUIColor
    }

    var body: some View {
        HStack(alignment: .top, spacing: SDSpacing.m) {
            (percent > 0 ? SDIcon.alert : SDIcon.check).image
                .font(.system(size: SDSize.iconM, weight: .semibold))
                .foregroundStyle(color)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SDSpacing.xxs) {
                Text("지난번엔 \(BudgetDifferenceText.phrase(percent)) \(BudgetDifferenceText.emoji(percent))")
                    .font(.sd.body)
                    .foregroundStyle(color)
                Text("\(result.amount.wonFormatted) 중 \(result.spent.wonFormatted) · \(percent > 0 ? "이번엔 꼭 지켜 보아요" : "이번에도 이어가 보아요")")
                    .font(.sd.footnote)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                Text("\(result.startDate.dotDateFormatted) ~ \(result.dueDate.dotDateFormatted)")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
            }
            Spacer(minLength: 0)
        }
        .padding(SDSpacing.l)
        .background(RoundedRectangle(cornerRadius: SDRadius.m).fill(color.opacity(SDOpacity.tint)))
        .accessibilityElement(children: .combine)
    }
}
