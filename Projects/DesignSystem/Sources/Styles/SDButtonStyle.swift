import SwiftUI

/// 버튼 스타일 — primary(CTA), secondary(테두리), text(텍스트 버튼)
public struct SDButtonStyle: ButtonStyle {
    public enum Kind: Sendable { case primary, secondary, text }

    private let kind: Kind
    private let isFullWidth: Bool
    private let isSmall: Bool
    @Environment(\.isEnabled) private var isEnabled

    public init(_ kind: Kind = .primary, isFullWidth: Bool = true) {
        self.kind = kind
        self.isFullWidth = isFullWidth
        self.isSmall = false
    }

    fileprivate init(smallKind kind: Kind) {
        self.kind = kind
        self.isFullWidth = false
        self.isSmall = true
    }

    public func makeBody(configuration: Configuration) -> some View {
        styledLabel(configuration.label)
            .contentShape(Rectangle())
            .opacity(isEnabled ? 1 : SDOpacity.disabled)
            .scaleEffect(configuration.isPressed ? SDScale.pressed : 1)
            .animation(.sd.quick, value: configuration.isPressed)
    }

    @ViewBuilder
    private func styledLabel(_ label: Configuration.Label) -> some View {
        if isSmall {
            // 보이는 크기만 줄이고 터치 영역은 44를 유지한다
            label
                .font(.sd.callout)
                .foregroundStyle(foreground)
                .padding(.horizontal, SDSpacing.m)
                .padding(.vertical, SDSpacing.s)
                .background(background)
                .frame(minHeight: SDSize.touchTarget)
        } else {
            label
                .font(kind == .text ? .sd.callout : .sd.headline)
                .foregroundStyle(foreground)
                .frame(maxWidth: isFullWidth && kind != .text ? .infinity : nil)
                .frame(minHeight: kind == .text ? SDSize.touchTarget : (isFullWidth ? SDSize.ctaHeight : SDSize.touchTarget))
                .padding(.horizontal, isFullWidth ? 0 : SDSpacing.xl)
                .background(background)
        }
    }

    private var foreground: Color {
        switch kind {
        case .primary: DesignSystemAsset.onPrimary.swiftUIColor
        case .secondary: DesignSystemAsset.textPrimary.swiftUIColor
        case .text: DesignSystemAsset.primary.swiftUIColor
        }
    }

    @ViewBuilder
    private var background: some View {
        switch kind {
        case .primary:
            RoundedRectangle(cornerRadius: SDRadius.s)
                .fill(DesignSystemAsset.cta.swiftUIColor)
        case .secondary:
            RoundedRectangle(cornerRadius: SDRadius.s)
                .fill(DesignSystemAsset.surface.swiftUIColor)
                .overlay(
                    RoundedRectangle(cornerRadius: SDRadius.s)
                        .stroke(DesignSystemAsset.border.swiftUIColor, lineWidth: SDSize.borderThin)
                )
        case .text:
            Color.clear
        }
    }
}

extension ButtonStyle where Self == SDButtonStyle {
    /// 하단 CTA (전체 너비, 높이 54)
    public static var sdPrimary: SDButtonStyle { SDButtonStyle(.primary) }
    /// 내용 너비 CTA (빈 상태 등)
    public static var sdPrimaryCompact: SDButtonStyle { SDButtonStyle(.primary, isFullWidth: false) }
    /// 카드·배너 안의 작은 버튼 ("설정하기"). 보이는 높이 약 32, 터치 영역 44
    public static var sdPrimarySmall: SDButtonStyle { SDButtonStyle(smallKind: .primary) }
    /// 테두리 버튼 (넓은 색 채우기를 피할 때)
    public static var sdSecondary: SDButtonStyle { SDButtonStyle(.secondary) }
    /// 텍스트 버튼 ("건너뛰기", "전체보기")
    public static var sdText: SDButtonStyle { SDButtonStyle(.text) }
}

#Preview {
    VStack(spacing: SDSpacing.m) {
        Button("이제부터 시작!") {}.buttonStyle(.sdPrimary)
        Button("저장하기") {}.buttonStyle(.sdPrimary).disabled(true)
        Button {
        } label: {
            Label {
                Text("지출 추가")
            } icon: {
                SDIcon.plus.image.foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
            }
        }
        .buttonStyle(.sdSecondary)
        Button("예산 설정하기") {}.buttonStyle(.sdPrimaryCompact)
        Button("설정하기") {}.buttonStyle(.sdPrimarySmall)
        Button("건너뛰기") {}.buttonStyle(.sdText)
    }
    .padding(SDSpacing.page)
    .sdScreen()
}
