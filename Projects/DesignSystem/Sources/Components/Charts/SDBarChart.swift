import Charts
import Core
import SwiftUI

/// 수익·지출 막대 차트 + 평균 점선. 드래그하면 세로 마커와 툴팁을 보여준다
public struct SDBarChart: View {
    private let points: [SDChartPoint]
    private let averageIncome: Int?
    private let averageExpense: Int?
    @Binding private var selection: Int?

    public init(points: [SDChartPoint], averageIncome: Int? = nil, averageExpense: Int? = nil, selection: Binding<Int?>) {
        self.points = points
        self.averageIncome = averageIncome
        self.averageExpense = averageExpense
        self._selection = selection
    }

    public var body: some View {
        VStack(spacing: SDSpacing.m) {
            Chart {
                ForEach(points) { point in
                    BarMark(x: .value("칸", point.key), y: .value("금액", point.income), width: .ratio(0.9))
                        .position(by: .value("구분", "수익"), axis: .horizontal, span: .ratio(0.8))
                        .foregroundStyle(DesignSystemAsset.chartIncome.swiftUIColor)
                        .cornerRadius(SDRadius.xs)
                        .shadow(color: DesignSystemAsset.chartIncome.swiftUIColor.opacity(0.4), radius: SDSpacing.s, y: SDSpacing.xs)
                    BarMark(x: .value("칸", point.key), y: .value("금액", point.expense), width: .ratio(0.9))
                        .position(by: .value("구분", "지출"), axis: .horizontal, span: .ratio(0.8))
                        .foregroundStyle(DesignSystemAsset.chartExpense.swiftUIColor)
                        .cornerRadius(SDRadius.xs)
                        .shadow(color: DesignSystemAsset.chartExpense.swiftUIColor.opacity(0.4), radius: SDSpacing.s, y: SDSpacing.xs)
                }
                if let averageExpense, averageExpense > 0 {
                    RuleMark(y: .value("평균 지출", averageExpense))
                        .foregroundStyle(DesignSystemAsset.chartExpense.swiftUIColor)
                        .lineStyle(StrokeStyle(lineWidth: SDSize.borderThin, dash: [SDSpacing.xs]))
                }
                if let averageIncome, averageIncome > 0 {
                    RuleMark(y: .value("평균 수익", averageIncome))
                        .foregroundStyle(DesignSystemAsset.chartIncome.swiftUIColor)
                        .lineStyle(StrokeStyle(lineWidth: SDSize.borderThin, dash: [SDSpacing.xs]))
                }
                if let selected = selectedPoint {
                    RuleMark(x: .value("칸", selected.key))
                        .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                        .lineStyle(StrokeStyle(lineWidth: SDSize.borderThin, dash: [SDSpacing.xxs + 1]))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            SDChartTooltip(point: selected)
                        }
                        .zIndex(1)
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
    let points = (1...12).map {
        SDChartPoint(id: $0, label: "\($0)월", title: "2026년 \($0)월", income: 2_000_000 - $0 * 90_000, expense: 300_000 + $0 * 80_000)
    }
    SDBarChart(points: points, averageIncome: 1_415_000, averageExpense: 820_000, selection: $selection)
        .padding(SDSpacing.page)
        .sdScreen()
}
