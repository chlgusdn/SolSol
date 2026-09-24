import Charts
import Core
import SwiftUI

/// 수익·지출 꺾은선 차트. 드래그하면 세로 마커·점·툴팁을 보여준다
public struct SDLineChart: View {
    private let points: [SDChartPoint]
    @Binding private var selection: Int?

    public init(points: [SDChartPoint], selection: Binding<Int?>) {
        self.points = points
        self._selection = selection
    }

    public var body: some View {
        VStack(spacing: SDSpacing.m) {
            Chart {
                ForEach(points) { point in
                    LineMark(x: .value("칸", point.key), y: .value("금액", point.income), series: .value("구분", "수익"))
                        .foregroundStyle(DesignSystemAsset.chartIncome.swiftUIColor)
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: SDSpacing.xxs))
                        .shadow(color: DesignSystemAsset.chartIncome.swiftUIColor.opacity(0.4), radius: SDSpacing.s, y: SDSpacing.xs)
                    LineMark(x: .value("칸", point.key), y: .value("금액", point.expense), series: .value("구분", "지출"))
                        .foregroundStyle(DesignSystemAsset.chartExpense.swiftUIColor)
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: SDSpacing.xxs))
                        .shadow(color: DesignSystemAsset.chartExpense.swiftUIColor.opacity(0.4), radius: SDSpacing.s, y: SDSpacing.xs)
                }
                if let selected = selectedPoint {
                    RuleMark(x: .value("칸", selected.key))
                        .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                        .lineStyle(StrokeStyle(lineWidth: SDSize.borderThin, dash: [SDSpacing.xxs + 1]))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            SDChartTooltip(point: selected)
                        }
                    PointMark(x: .value("칸", selected.key), y: .value("금액", selected.income))
                        .foregroundStyle(DesignSystemAsset.chartIncome.swiftUIColor)
                    PointMark(x: .value("칸", selected.key), y: .value("금액", selected.expense))
                        .foregroundStyle(DesignSystemAsset.chartExpense.swiftUIColor)
                }
            }
            .sdChartAxes(points: points)
            .chartXSelection(value: keySelection)
            .frame(height: SDChartMetrics.height)
            .accessibilityChartDescriptor(SDChartDescriptor(points: points))

            SDChartLegend()
        }
    }

    /// 범주형 x축은 문자열 키로 선택된다
    private var keySelection: Binding<String?> {
        Binding(
            get: { selection.map(String.init) },
            set: { selection = $0.flatMap(Int.init) }
        )
    }

    private var selectedPoint: SDChartPoint? {
        guard let selection else { return nil }
        return points.first { $0.id == selection }
    }
}

#Preview {
    @Previewable @State var selection: Int?
    let points = (1...24).map {
        SDChartPoint(id: $0, label: "\($0)", title: "9월 \($0)일", income: $0 % 7 == 0 ? 200_000 : 0, expense: 10_000 + ($0 * 3_700) % 40_000)
    }
    SDLineChart(points: points, selection: $selection)
        .padding(SDSpacing.page)
        .sdScreen()
}
