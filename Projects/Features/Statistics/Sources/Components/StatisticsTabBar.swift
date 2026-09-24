import DesignSystem
import SwiftUI

struct StatisticsTabBar: View {
    let selection: StatisticsFeature.Tab
    let onSelect: (StatisticsFeature.Tab) -> Void

    var body: some View {
        HStack(spacing: SDSpacing.xs) {
            ForEach(StatisticsFeature.Tab.allCases, id: \.self) { tab in
                let isSelected = tab == selection
                Button {
                    onSelect(tab)
                } label: {
                    HStack(spacing: SDSpacing.xs) {
                        tab.icon.image.font(.system(size: SDSize.iconS, weight: .semibold))
                        Text(tab.title).font(.sd.callout)
                    }
                    .foregroundStyle(isSelected ? DesignSystemAsset.primary.swiftUIColor : DesignSystemAsset.textSecondary.swiftUIColor)
                    .frame(maxWidth: .infinity, minHeight: SDSize.touchTarget)
                    .background(
                        RoundedRectangle(cornerRadius: SDRadius.m)
                            .fill(isSelected ? DesignSystemAsset.primary.swiftUIColor.opacity(SDOpacity.tint) : .clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .animation(.sd.quick, value: selection)
    }
}

private extension StatisticsFeature.Tab {
    var title: String {
        switch self {
        case .average: "평균"
        case .trend: "추세"
        case .report: "지출 보고"
        }
    }

    var icon: SDIcon {
        switch self {
        case .average: .barChart
        case .trend: .trendingUp
        case .report: .pieChart
        }
    }
}
