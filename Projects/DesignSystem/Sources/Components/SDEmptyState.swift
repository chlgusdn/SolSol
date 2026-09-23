import SwiftUI

/// 빈 상태 — 무엇이 없는지 + 다음 행동
public struct SDEmptyState: View {
    private let icon: SDIcon
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        icon: SDIcon,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: SDSpacing.m) {
            icon.image
                .font(.system(size: SDSize.iconL, weight: .semibold))
                .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
                .frame(width: SDSize.iconXXL + SDSpacing.l, height: SDSize.iconXXL + SDSpacing.l)
                .background(Circle().fill(DesignSystemAsset.primary.swiftUIColor.opacity(SDOpacity.tint)))
                .accessibilityHidden(true)
            Text(title)
                .font(.sd.displayBody)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(.sd.callout)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.sdPrimaryCompact)
                    .padding(.top, SDSpacing.s)
            }
        }
        .padding(SDSpacing.xxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SDEmptyState(
        icon: .budget,
        title: "아직 예산이 없어요",
        message: "예산과 만기일을 설정하면\n텅장이 되지 않게 미리 알려드려요",
        actionTitle: "예산 설정하기"
    ) {}
    .sdScreen()
}
