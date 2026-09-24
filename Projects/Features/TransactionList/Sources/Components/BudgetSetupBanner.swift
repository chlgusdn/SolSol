import DesignSystem
import SwiftUI

struct BudgetSetupBanner: View {
    let action: () -> Void

    var body: some View {
        HStack(spacing: SDSpacing.m) {
            VStack(alignment: .leading, spacing: SDSpacing.xxs) {
                Text("아직 예산을 설정하지 않았어요")
                    .font(.sd.callout)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Text("예산을 정하면 사용률이 한눈에 보여요")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            }
            Spacer(minLength: 0)
            Button("설정하기", action: action)
                .buttonStyle(.sdPrimarySmall)
        }
        .padding(SDSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: SDRadius.m)
                .fill(DesignSystemAsset.primary.swiftUIColor.opacity(SDOpacity.tint))
        )
    }
}
