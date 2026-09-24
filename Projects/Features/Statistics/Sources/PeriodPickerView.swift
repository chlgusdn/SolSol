import ComposableArchitecture
import Core
import DesignSystem
import SwiftUI

struct PeriodPickerView: View {
    let store: StoreOf<PeriodPickerFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.l) {
            HStack(spacing: SDSpacing.s) {
                ForEach([7, 14, 30], id: \.self) { days in
                    Button("최근 \(days)일") { store.send(.quickRangeTapped(days: days)) }
                        .font(.sd.callout)
                        .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                        .padding(.horizontal, SDSpacing.m)
                        .frame(minHeight: SDSize.touchTarget)
                        .background(Capsule().fill(DesignSystemAsset.background.swiftUIColor))
                        .buttonStyle(.plain)
                }
            }

            HStack {
                monthButton(.back, label: "이전 달", enabled: true) { store.send(.previousMonthButtonTapped) }
                Spacer()
                Text(store.displayedMonth.start.yearMonthFormatted)
                    .font(.sd.displayBody)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Spacer()
                monthButton(.chevronRight, label: "다음 달", enabled: store.canMoveToNextMonth) {
                    store.send(.nextMonthButtonTapped)
                }
            }

            SDCalendar(
                month: store.displayedMonth,
                today: store.today,
                selection: store.start,
                range: store.range,
                onSelect: { store.send(.dayTapped($0)) }
            )

            Text(hint)
                .font(.sd.caption)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                .frame(maxWidth: .infinity)

            Button("이 기간으로 볼게요") { store.send(.confirmButtonTapped) }
                .buttonStyle(.sdPrimary)
                .disabled(!store.canConfirm)
        }
    }

    private var hint: String {
        guard let end = store.end else { return "종료일을 골라요" }
        let days = (Calendar.current.dateComponents([.day], from: store.start, to: end).day ?? 0) + 1
        return "\(store.start.dotDateFormatted) ~ \(end.dotDateFormatted) · \(days)일"
    }

    private func monthButton(_ icon: SDIcon, label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon.image
                .font(.system(size: SDSize.iconS, weight: .semibold))
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                .frame(width: SDSize.touchTarget, height: SDSize.touchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(enabled ? 1 : 0)
        .disabled(!enabled)
        .accessibilityLabel(label)
        .accessibilityHidden(!enabled)
    }
}
