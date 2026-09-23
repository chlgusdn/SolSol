import SwiftUI

/// 원형 진행 링 — 12시 방향에서 시계 방향으로 채운다. 텅장방지 다이얼, 온보딩 일러스트에 쓴다
public struct SDProgressRing<Center: View>: View {
    private let progress: Double
    private let color: Color
    private let lineWidth: CGFloat
    private let center: Center

    /// - Parameter progress: 0…1 (범위를 벗어나면 잘라낸다)
    public init(
        progress: Double,
        color: Color = DesignSystemAsset.primary.swiftUIColor,
        lineWidth: CGFloat = SDSpacing.m,
        @ViewBuilder center: () -> Center
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.center = center()
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(SDOpacity.tint), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            center
                .padding(lineWidth)
        }
        .padding(lineWidth / 2)
        .animation(.sd.standard, value: progress)
    }
}

extension SDProgressRing where Center == EmptyView {
    public init(progress: Double, color: Color = DesignSystemAsset.primary.swiftUIColor, lineWidth: CGFloat = SDSpacing.m) {
        self.init(progress: progress, color: color, lineWidth: lineWidth) { EmptyView() }
    }
}

#Preview {
    HStack(spacing: SDSpacing.xl) {
        SDProgressRing(progress: 0.7) {
            VStack(spacing: SDSpacing.xxs) {
                Text("만기까지").font(.sd.caption).foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                Text("67일").font(.sd.displayHeadline)
            }
        }
        .frame(width: 150, height: 150)
        SDProgressRing(progress: 0.95, color: DesignSystemAsset.danger.swiftUIColor)
            .frame(width: 80, height: 80)
    }
    .padding()
}
