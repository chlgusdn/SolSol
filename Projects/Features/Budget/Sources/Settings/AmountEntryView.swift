import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct AmountEntryView: View {
    let store: StoreOf<AmountEntryFeature>
    @State private var keyTapCount = 0

    var body: some View {
        VStack(spacing: SDSpacing.l) {
            Text(store.field.title)
                .font(.sd.title)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(alignment: .firstTextBaseline, spacing: SDSpacing.xs) {
                Text(store.amount.formatted())
                    .font(.sd.displayTitle)
                    .contentTransition(.numericText(value: Double(store.amount)))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("원").font(.sd.displayBody)
            }
            .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            .sdShake(trigger: store.shakeCount)
            .animation(.sd.quick, value: store.amount)
            .accessibilityElement(children: .combine)

            SDKeypad { key in
                keyTapCount += 1
                store.send(.keypadTapped(key.amountKey))
            }

            Button("확인") { store.send(.confirmButtonTapped) }
                .buttonStyle(.sdPrimary)
                .disabled(!store.canConfirm)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: keyTapCount)
        .sensoryFeedback(.error, trigger: store.shakeCount)
    }
}

extension BudgetSettingsFeature.AmountField {
    var title: String {
        switch self {
        case .budget: "예산 금액"
        case .danger: "위험 알림 금액"
        case .warning: "경고 알림 금액"
        }
    }
}

private extension SDKeypad.Key {
    var amountKey: AmountInput.Key {
        switch self {
        case let .digit(digit): .digit(digit)
        case .doubleZero: .doubleZero
        case .delete: .delete
        }
    }
}
