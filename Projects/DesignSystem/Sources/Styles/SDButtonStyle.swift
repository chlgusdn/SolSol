import SwiftUI

/// 기본 버튼 스타일
public struct SDButtonStyle: ButtonStyle {
    public enum Kind: Sendable { case primary, secondary }

    private let kind: Kind
    @Environment(\.isEnabled) private var isEnabled

    public init(_ kind: Kind = .primary) {
        self.kind = kind
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sd.bodyBold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SDSpacing.m)
            .foregroundStyle(kind == .primary ? DesignSystemAsset.onPrimary.swiftUIColor : DesignSystemAsset.primary.swiftUIColor)
            .background(
                RoundedRectangle(cornerRadius: SDRadius.m)
                    .fill(kind == .primary ? DesignSystemAsset.primary.swiftUIColor : DesignSystemAsset.primary.swiftUIColor.opacity(0.12))
            )
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? SDScale.pressed : 1)
            .animation(.sd.quick, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SDButtonStyle {
    public static var sdPrimary: SDButtonStyle { SDButtonStyle(.primary) }
    public static var sdSecondary: SDButtonStyle { SDButtonStyle(.secondary) }
}

#Preview {
    VStack(spacing: SDSpacing.m) {
        Button("저장") {}.buttonStyle(.sdPrimary)
        Button("취소") {}.buttonStyle(.sdSecondary)
        Button("비활성") {}.buttonStyle(.sdPrimary).disabled(true)
    }
    .padding()
}
