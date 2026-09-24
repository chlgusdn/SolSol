import Charts
import Core
import SwiftUI

/// 비중 도넛 + 범례 (지출 보고)
public struct SDDonutChart: View {
    public struct Slice: Equatable, Identifiable, Sendable {
        public let id: Int
        public let label: String
        public let amount: Int
        public let ratio: Double
        public let color: SDCategoryColor?

        /// `color`가 nil이면 `textTertiary` (기타)
        public init(id: Int, label: String, amount: Int, ratio: Double, color: SDCategoryColor?) {
            self.id = id
            self.label = label
            self.amount = amount
            self.ratio = ratio
            self.color = color
        }

        var fill: Color { color?.color ?? DesignSystemAsset.textTertiary.swiftUIColor }
        var percentText: String { ratio.formatted(.percent.precision(.fractionLength(0...1))) }
    }

    private let slices: [Slice]

    public init(slices: [Slice]) {
        self.slices = slices
    }

    public var body: some View {
        HStack(spacing: SDSpacing.xl) {
            Chart(slices) { slice in
                SectorMark(angle: .value("금액", slice.amount), innerRadius: .ratio(0.55), angularInset: 1)
                    .foregroundStyle(slice.fill)
                    .cornerRadius(SDRadius.xs)
            }
            .frame(width: SDChartMetrics.height * 0.8, height: SDChartMetrics.height * 0.8)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SDSpacing.s) {
                ForEach(slices) { slice in
                    HStack(spacing: SDSpacing.s) {
                        Circle().fill(slice.fill).frame(width: SDSpacing.s, height: SDSpacing.s)
                        Text(slice.label)
                            .font(.sd.callout)
                            .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                            .lineLimit(1)
                        Spacer(minLength: SDSpacing.xs)
                        Text(slice.percentText)
                            .font(.sd.displayCaption)
                            .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(slice.label) \(slice.percentText), \(slice.amount.wonFormatted)")
                }
            }
        }
    }
}

#Preview {
    SDDonutChart(slices: [
        .init(id: 0, label: "카페", amount: 39_650, ratio: 0.3965, color: .amber),
        .init(id: 1, label: "레저", amount: 32_180, ratio: 0.3218, color: .blue),
        .init(id: 2, label: "교통", amount: 20_140, ratio: 0.2014, color: .green),
        .init(id: 3, label: "기타", amount: 8_030, ratio: 0.0803, color: nil)
    ])
    .padding(SDSpacing.page)
    .sdScreen()
}
