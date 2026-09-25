import DesignSystem
import SwiftUI

/// 예산 막대 — 경고·위험 위치 표시. `usedRatio`가 있으면 사용한 만큼 채운다
struct BudgetRangeBar: View {
    let warnRatio: Double
    let dangerRatio: Double
    var usedRatio: Double?
    var fillColor: Color = DesignSystemAsset.primary.swiftUIColor

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(DesignSystemAsset.border.swiftUIColor)
                if let usedRatio {
                    Capsule()
                        .fill(fillColor)
                        .frame(width: width * clamp(usedRatio))
                } else {
                    // 미리보기: 경고~위험, 위험~끝 구간을 단계 색으로 칠한다
                    Rectangle()
                        .fill(DesignSystemAsset.warning.swiftUIColor.opacity(SDOpacity.dim))
                        .frame(width: width * max(0, clamp(dangerRatio) - clamp(warnRatio)))
                        .offset(x: width * clamp(warnRatio))
                    Rectangle()
                        .fill(DesignSystemAsset.danger.swiftUIColor.opacity(SDOpacity.dim))
                        .frame(width: width * (1 - clamp(dangerRatio)))
                        .offset(x: width * clamp(dangerRatio))
                }
                marker(at: warnRatio, width: width, color: markerColor(warnRatio, DesignSystemAsset.warning.swiftUIColor))
                marker(at: dangerRatio, width: width, color: markerColor(dangerRatio, DesignSystemAsset.danger.swiftUIColor))
            }
            .clipShape(Capsule())
        }
        .frame(height: SDSpacing.m)
        .animation(.sd.standard, value: usedRatio)
        .accessibilityHidden(true)
    }

    private func marker(at ratio: Double, width: CGFloat, color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: SDSpacing.xxs)
            .offset(x: width * clamp(ratio) - SDSpacing.xxs / 2)
    }

    /// 채운 막대가 표시선을 덮으면 같은 색에 묻히므로 흰색으로 그린다
    private func markerColor(_ ratio: Double, _ color: Color) -> Color {
        guard let usedRatio, usedRatio >= ratio else { return color }
        return DesignSystemAsset.onPrimary.swiftUIColor
    }

    private func clamp(_ value: Double) -> Double { min(1, max(0, value)) }
}
