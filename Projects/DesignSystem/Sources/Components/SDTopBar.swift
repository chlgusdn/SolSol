import SwiftUI

/// 상단 바 — 좌측 뒤로가기(44 영역) + 가운데 제목 + 우측 액션
public struct SDTopBar<Trailing: View>: View {
    public enum Style: Sendable {
        /// 투명 배경, 기본 텍스트 색
        case light
        /// `surfaceDark` 배경, 흰 글자 (입력·통계 헤더)
        case dark
    }

    private let title: String?
    private let style: Style
    private let onBack: (() -> Void)?
    private let trailing: Trailing

    public init(
        title: String? = nil,
        style: Style = .light,
        onBack: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.style = style
        self.onBack = onBack
        self.trailing = trailing()
    }

    public var body: some View {
        ZStack {
            if let title {
                Text(title)
                    .font(.sd.displayBody)
                    .foregroundStyle(foreground)
                    .accessibilityAddTraits(.isHeader)
            }
            HStack(spacing: 0) {
                if let onBack {
                    Button(action: onBack) {
                        SDIcon.back.image
                            .font(.system(size: SDSize.iconS, weight: .semibold))
                            .frame(width: SDSize.touchTarget, height: SDSize.touchTarget)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("뒤로")
                }
                Spacer(minLength: 0)
                trailing
                    .frame(minWidth: SDSize.touchTarget, minHeight: SDSize.touchTarget)
            }
            .foregroundStyle(foreground)
        }
        .padding(.horizontal, SDSpacing.s)
        .frame(maxWidth: .infinity)
        .background(style == .dark ? DesignSystemAsset.surfaceDark.swiftUIColor : .clear)
    }

    private var foreground: Color {
        style == .dark ? DesignSystemAsset.onPrimary.swiftUIColor : DesignSystemAsset.textPrimary.swiftUIColor
    }
}

extension SDTopBar where Trailing == EmptyView {
    public init(title: String? = nil, style: Style = .light, onBack: (() -> Void)? = nil) {
        self.init(title: title, style: style, onBack: onBack) { EmptyView() }
    }
}

#Preview {
    VStack(spacing: SDSpacing.l) {
        SDTopBar(title: "텅장 방지", onBack: {}) {
            Button {} label: { SDIcon.settings.image }
                .accessibilityLabel("예산 설정")
        }
        SDTopBar(style: .dark, onBack: {}) {
            Button {} label: { SDIcon.check.image }
                .accessibilityLabel("저장")
        }
        Spacer()
    }
    .sdScreen()
}
