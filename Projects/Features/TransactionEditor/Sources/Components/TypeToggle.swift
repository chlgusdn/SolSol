import DesignSystem
import Domain
import SwiftUI

/// 수익·지출 토글 — 선택된 쪽만 흰 배경 + 포인트 색 글자
struct TypeToggle: View {
    let type: TransactionType
    let onChange: (TransactionType) -> Void

    var body: some View {
        HStack(spacing: 0) {
            option(.income, title: "수익", color: DesignSystemAsset.income.swiftUIColor)
            option(.expense, title: "지출", color: DesignSystemAsset.expense.swiftUIColor)
        }
        .padding(SDSpacing.xxs)
        .background(Capsule().fill(DesignSystemAsset.onPrimary.swiftUIColor.opacity(SDOpacity.onDarkTrack)))
        .animation(.sd.quick, value: type)
    }

    private func option(_ option: TransactionType, title: String, color: Color) -> some View {
        let isSelected = type == option
        return Button {
            onChange(option)
        } label: {
            Text(title)
                .font(.sd.footnote)
                .foregroundStyle(isSelected ? color : DesignSystemAsset.onPrimary.swiftUIColor)
                .padding(.horizontal, SDSpacing.l)
                .frame(minHeight: SDSpacing.xxxl - SDSpacing.xs)
                .background(Capsule().fill(isSelected ? DesignSystemAsset.onPrimary.swiftUIColor : .clear))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
