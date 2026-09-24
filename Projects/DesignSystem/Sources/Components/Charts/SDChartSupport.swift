import Charts
import Core
import SwiftUI

enum SDChartMetrics {
    static let height: CGFloat = 200
    /// x축 라벨을 최대 이 개수만큼만 보여준다 (하루 단위 30칸 등)
    static let maxAxisLabels = 7
}

extension View {
    /// 수익·지출 차트 공통 축 — x축은 칸 라벨을 간격을 두고, y축은 축약 금액
    func sdChartAxes(points: [SDChartPoint]) -> some View {
        let stride = max(1, Int((Double(points.count) / Double(SDChartMetrics.maxAxisLabels)).rounded(.up)))
        let labeled = points.enumerated().filter { $0.offset % stride == 0 }.map(\.element.key)
        return chartXAxis {
            AxisMarks(values: labeled) { value in
                AxisValueLabel {
                    if let key = value.as(String.self), let point = points.first(where: { $0.key == key }) {
                        Text(point.label).font(.sd.caption)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine().foregroundStyle(DesignSystemAsset.border.swiftUIColor)
                AxisValueLabel {
                    if let amount = value.as(Int.self) {
                        Text(amount.compactFormatted).font(.sd.caption)
                    }
                }
            }
        }
    }
}

/// VoiceOver 오디오 그래프용 설명
struct SDChartDescriptor: AXChartDescriptorRepresentable {
    let points: [SDChartPoint]

    func makeChartDescriptor() -> AXChartDescriptor {
        let maxValue = Double(points.map { max($0.income, $0.expense) }.max() ?? 0)
        let xAxis = AXCategoricalDataAxisDescriptor(title: "기간", categoryOrder: points.map(\.title))
        let yAxis = AXNumericDataAxisDescriptor(title: "금액", range: 0...max(maxValue, 1), gridlinePositions: []) {
            "\(Int($0).wonFormatted)"
        }
        let series = [("수익", \SDChartPoint.income), ("지출", \SDChartPoint.expense)].map { name, keyPath in
            AXDataSeriesDescriptor(name: name, isContinuous: false, dataPoints: points.map {
                AXDataPoint(x: $0.title, y: Double($0[keyPath: keyPath]))
            })
        }
        return AXChartDescriptor(title: "수익·지출", summary: nil, xAxis: xAxis, yAxis: yAxis, additionalAxes: [], series: series)
    }
}
