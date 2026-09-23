import SwiftUI

/// 페이지 점 — 현재 페이지는 넓은 `primary` 막대, 나머지는 작은 점. 점을 누르면 해당 페이지로 이동
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
                Button {
                    current = index
                } label: {
                    Capsule()
                        .fill(index == current
                              ? DesignSystemAsset.primary.swiftUIColor
                              : DesignSystemAsset.textTertiary.swiftUIColor)
                        .frame(width: index == current ? SDSpacing.xxl : SDSpacing.s, height: SDSpacing.s)
                        .frame(height: SDSize.iconL)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(index + 1)번째 페이지")
                .accessibilityAddTraits(index == current ? .isSelected : [])
            }
        }
        .animation(.sd.standard, value: current)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("페이지 \(current + 1) / \(count)")
    }
}

#Preview {
    @Previewable @State var current = 1
    SDPageIndicator(count: 4, current: $current)
        .padding()
}
