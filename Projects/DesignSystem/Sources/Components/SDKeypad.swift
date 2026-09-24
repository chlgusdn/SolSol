import SwiftUI

/// 3×4 숫자 키패드 — 1…9, 00, 0, ⌫
public struct SDKeypad: View {
    public enum Key: Hashable, Sendable {
        case digit(Int)
        case doubleZero
        case delete
    }

    private let onKey: (Key) -> Void

    public init(onKey: @escaping (Key) -> Void) {
        self.onKey = onKey
    }

    private static let keys: [Key] = (1...9).map { .digit($0) } + [.doubleZero, .digit(0), .delete]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: SDSpacing.xxs), count: 3)

    public var body: some View {
        LazyVGrid(columns: columns, spacing: SDSpacing.xxs) {
            ForEach(Self.keys, id: \.self) { key in
                Button {
                    onKey(key)
                } label: {
                    label(for: key)
                        .frame(maxWidth: .infinity, minHeight: SDSize.ctaHeight)
                        .contentShape(Rectangle())
                }
                .buttonStyle(KeyStyle())
                .accessibilityLabel(accessibilityLabel(for: key))
            }
        }
        .padding(SDSpacing.s)
        .background(DesignSystemAsset.surface.swiftUIColor)
    }

    @ViewBuilder
    private func label(for key: Key) -> some View {
        switch key {
        case let .digit(digit):
            Text("\(digit)").font(.sd.displayBody)
        case .doubleZero:
            Text("00").font(.sd.displayBody)
        case .delete:
            SDIcon.deleteBackward.image.font(.system(size: SDSize.iconM, weight: .semibold))
        }
    }

    private func accessibilityLabel(for key: Key) -> String {
        switch key {
        case let .digit(digit): "\(digit)"
        case .doubleZero: "0 두 개"
        case .delete: "지우기"
        }
    }
}

private struct KeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            .background(
                RoundedRectangle(cornerRadius: SDRadius.m)
                    .fill(configuration.isPressed ? DesignSystemAsset.border.swiftUIColor : .clear)
            )
    }
}

#Preview {
    VStack {
        Spacer()
        SDKeypad { _ in }
    }
    .sdScreen()
}
