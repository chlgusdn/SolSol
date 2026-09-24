import DesignSystem
import SwiftUI

struct StatisticsHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.xs) {
            Text("통계")
                .font(.sd.displayTitle)
                .foregroundStyle(DesignSystemAsset.onPrimary.swiftUIColor)
                .accessibilityAddTraits(.isHeader)
            Text("내 수입/지출 평균을 알아보아요")
                .font(.sd.callout)
                .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, SDSpacing.page)
        .padding(.bottom, SDSpacing.xl)
    }
}
