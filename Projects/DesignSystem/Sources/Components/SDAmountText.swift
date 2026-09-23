import Core
import SwiftUI

/// 금액 표시 (Moneygraphy-Pixel). 값이 바뀌면 숫자 전환 애니메이션이 적용된다
public struct SDAmountText: View {
    public enum Style: Sendable {
        /// 부호 없이 기본 텍스트 색
        case plain
        /// +/- 부호와 수입·지출 색
        case signed
        /// 부호 없이 수입 색
        case income
        /// 부호 없이 지출 색
        case expense
    }

    private let amount: Int
    private let style: Style
    private let font: Font

    public init(_ amount: Int, style: Style = .plain, font: Font = .sd.displayBody) {
        self.amount = amount
        self.style = style
        self.font = font
    }

    public var body: some View {
        Text(style == .signed ? amount.signedWonFormatted : amount.wonFormatted)
            .font(font)
            .monospacedDigit()
            .foregroundStyle(color)
            .contentTransition(.numericText(value: Double(amount)))
            .animation(.sd.standard, value: amount)
    }

    private var color: Color {
        switch style {
        case .plain: DesignSystemAsset.textPrimary.swiftUIColor
        case .signed:
            amount > 0 ? DesignSystemAsset.income.swiftUIColor
                : amount < 0 ? DesignSystemAsset.expense.swiftUIColor
                : DesignSystemAsset.textPrimary.swiftUIColor
        case .income: DesignSystemAsset.income.swiftUIColor
        case .expense: DesignSystemAsset.expense.swiftUIColor
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: SDSpacing.s) {
        SDAmountText(3_200_000, font: .sd.displayTitle)
        SDAmountText(12_000, style: .signed)
        SDAmountText(-12_000, style: .signed)
        SDAmountText(12_000, style: .income, font: .sd.displayCaption)
        SDAmountText(12_000, style: .expense, font: .sd.displayCaption)
    }
    .padding()
}

#Preview("XXL") {
    SDAmountText(-1_234_000, style: .signed, font: .sd.displayHero)
        .padding()
        .dynamicTypeSize(.xxxLarge)
}
