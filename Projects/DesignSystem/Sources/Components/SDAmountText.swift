import Core
import SwiftUI

/// 금액 표시. 값이 바뀌면 숫자 전환 애니메이션이 적용된다.
public struct SDAmountText: View {
    public enum Style: Sendable {
        /// 부호 없이 표시, 기본 텍스트 색
        case plain
        /// +/- 부호와 수입/지출 색
        case signed
    }

    private let amount: Int
    private let style: Style
    private let font: Font

    public init(_ amount: Int, style: Style = .plain, font: Font = .sd.body) {
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
        case .signed: amount >= 0 ? DesignSystemAsset.income.swiftUIColor : DesignSystemAsset.expense.swiftUIColor
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: SDSpacing.s) {
        SDAmountText(3_200_000, font: .sd.largeTitle)
        SDAmountText(12_000, style: .signed)
        SDAmountText(-12_000, style: .signed)
    }
    .padding()
}

#Preview("Dark · XXL") {
    SDAmountText(-12_000, style: .signed, font: .sd.title)
        .padding()
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.xxxLarge)
}
