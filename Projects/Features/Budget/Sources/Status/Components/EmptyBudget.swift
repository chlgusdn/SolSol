import DesignSystem
import SwiftUI

/// 예산 미설정 — 점선 다이얼 + 설정 유도
struct EmptyBudget: View {
    let onSetup: () -> Void

    var body: some View {
        VStack(spacing: SDSpacing.l) {
            Circle()
                .strokeBorder(
                    DesignSystemAsset.textTertiary.swiftUIColor,
                    style: StrokeStyle(lineWidth: SDSpacing.xxs, dash: [SDSpacing.s])
                )
                .frame(width: DialMetrics.size * 0.7, height: DialMetrics.size * 0.7)
                .overlay {
                    SDIcon.budget.image
                        .font(.system(size: SDSize.iconXL))
                        .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
                }
                .accessibilityHidden(true)
            Text("아직 예산이 없어요")
                .font(.sd.displayBody)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            Text("예산과 만기일을 설정하면\n텅장이 되기 전에 미리 알려드려요")
                .font(.sd.callout)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                .multilineTextAlignment(.center)
            Button("예산 설정하기", action: onSetup)
                .buttonStyle(.sdPrimaryCompact)
        }
    }
}
