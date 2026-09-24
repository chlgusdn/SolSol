import SwiftUI

/// 페이지 점 — 현재 페이지는 넓은 `primary` 막대, 나머지는 작은 점. 표시 전용
///
/// 점마다 44pt 터치 영역을 줄 수 없어 탭은 받지 않는다. 페이지 이동은 스와이프·CTA로 하고,
/// VoiceOver에서는 조절 요소(위·아래 스와이프)로 이동한다.
public struct SDPageIndicator: View {
    private let count: Int
    @Binding private var current: Int

    public init(count: Int, current: Binding<Int>) {
        self.count = count
        self._current = current
    }

    public var body: some View {
        HStack(spacing: SDSpacing.s) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current
                          ? DesignSystemAsset.primary.swiftUIColor
                          : DesignSystemAsset.textTertiary.swiftUIColor)
                    .frame(width: index == current ? SDSpacing.xxl : SDSpacing.s, height: SDSpacing.s)
            }
        }
        .frame(height: SDSize.iconL)
        .animation(.sd.standard, value: current)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("페이지")
        .accessibilityValue("\(current + 1) / \(count)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: current = min(current + 1, count - 1)
            case .decrement: current = max(current - 1, 0)
            @unknown default: break
            }
        }
    }
}

#Preview {
    @Previewable @State var current = 1
    SDPageIndicator(count: 4, current: $current)
        .padding()
}
