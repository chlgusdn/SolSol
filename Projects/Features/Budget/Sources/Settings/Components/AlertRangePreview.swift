import DesignSystem
import Domain
import SwiftUI

/// 알림 구간 미리보기 — 경고·위험 금액이 예산의 몇 %인지
struct AlertRangePreview: View {
    let budget: Budget

    private var warnRatio: Double { budget.usageRatio(spent: budget.warnAmount) }
    private var dangerRatio: Double { budget.usageRatio(spent: budget.dangerAmount) }

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.s) {
            Text("알림 구간 미리보기")
                .font(.sd.footnote)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            BudgetRangeBar(warnRatio: warnRatio, dangerRatio: dangerRatio)
            HStack(spacing: SDSpacing.l) {
                legend("경고", warnRatio, DesignSystemAsset.warning.swiftUIColor)
                legend("위험", dangerRatio, DesignSystemAsset.danger.swiftUIColor)
            }
        }
        .sdCard()
        .accessibilityElement(children: .combine)
    }

    private func legend(_ title: String, _ ratio: Double, _ color: Color) -> some View {
        HStack(spacing: SDSpacing.xs) {
            Circle().fill(color).frame(width: SDSpacing.s, height: SDSpacing.s)
            Text("\(title) \(Int((ratio * 100).rounded()))%")
                .font(.sd.caption)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
        }
    }
}
