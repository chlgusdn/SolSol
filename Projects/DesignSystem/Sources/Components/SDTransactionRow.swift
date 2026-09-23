import SwiftUI

/// 거래 행 — 색 원형 아이콘 + 제목/부제 + 우측 금액
public struct SDTransactionRow: View {
    private let title: String
    private let subtitle: String?
    private let amount: Int
    private let color: Color
    private let icon: SDIcon

    public init(title: String, subtitle: String? = nil, amount: Int, color: Color, icon: SDIcon = .tag) {
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.color = color
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: SDSpacing.m) {
            icon.image
                .font(.system(size: SDSize.iconS, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: SDSize.iconXL, height: SDSize.iconXL)
                .background(Circle().fill(color.opacity(SDOpacity.tint)))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: SDSpacing.xxs) {
                Text(title)
                    .font(.sd.body)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                    .lineLimit(1)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.sd.footnote)
                        .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: SDSpacing.s)
            SDAmountText(amount, style: .signed)
        }
        .padding(.vertical, SDSpacing.s)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 0) {
        SDTransactionRow(title: "점심", subtitle: "식비", amount: -12_000, color: SDCategoryColor.red.color)
        SDTransactionRow(title: "월급", subtitle: "수입", amount: 3_200_000, color: SDCategoryColor.brand.color, icon: .money)
    }
    .sdCard()
    .padding(SDSpacing.page)
    .sdScreen()
}
