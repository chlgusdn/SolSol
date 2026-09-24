import DesignSystem
import Domain
import SwiftUI

/// 입력 화면 상단 금액 — `surfaceDark` 배경은 수익·지출과 관계없이 그대로 둔다
struct AmountHeader: View {
    let amount: Int
    let type: TransactionType
    let shakeCount: Int

    private var sign: String {
        guard amount > 0 else { return "" }
        return type == .income ? "+" : "-"
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SDSpacing.xs) {
            Text("\(sign)\(amount.formatted())")
                .font(.sd.displayHero)
                .contentTransition(.numericText(value: Double(amount)))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text("원")
                .font(.sd.displayHeadline)
        }
        .foregroundStyle(DesignSystemAsset.onPrimary.swiftUIColor)
        .sdShake(trigger: shakeCount)
        .animation(.sd.quick, value: amount)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, SDSpacing.page)
        .padding(.top, SDSpacing.s)
        .padding(.bottom, SDSpacing.xl)
        .background(DesignSystemAsset.surfaceDark.swiftUIColor)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(type.displayName) \(amount.formatted())원")
    }
}
