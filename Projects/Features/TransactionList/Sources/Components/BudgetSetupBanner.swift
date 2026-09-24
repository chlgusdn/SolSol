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
            // 배너 안이라 CTA보다 작게 그리고, 터치 영역은 44를 유지한다
            Button(action: action) {
                Text("설정하기")
                    .font(.sd.callout)
                    .foregroundStyle(DesignSystemAsset.onPrimary.swiftUIColor)
                    .padding(.horizontal, SDSpacing.m)
                    .padding(.vertical, SDSpacing.s)
                    .background(RoundedRectangle(cornerRadius: SDRadius.s).fill(DesignSystemAsset.cta.swiftUIColor))
                    .frame(minHeight: SDSize.touchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(SDSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: SDRadius.m)
                .fill(DesignSystemAsset.primary.swiftUIColor.opacity(SDOpacity.tint))
        )
    }
}
