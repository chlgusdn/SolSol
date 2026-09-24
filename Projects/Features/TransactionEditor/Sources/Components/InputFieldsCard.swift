import Core
import DesignSystem
import Domain
import SwiftUI

/// 제목·메모·날짜 입력 카드
struct InputFieldsCard: View {
    enum Field: Hashable {
        case title
        case memo
    }

    @Binding var title: String
    @Binding var memo: String
    let date: Date
    let onDateTap: () -> Void
    var focusedField: FocusState<Field?>.Binding

    var body: some View {
        VStack(spacing: 0) {
            InputRow(icon: .tag) {
                TextField("제목을 입력해요", text: $title)
                    .font(.sd.body)
                    .focused(focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField.wrappedValue = .memo }
            }
            Divider().overlay(DesignSystemAsset.border.swiftUIColor)
            InputRow(icon: .clock) {
                TextField("메모를 남겨보아요 (선택)", text: $memo)
                    .font(.sd.callout)
                    .focused(focusedField, equals: .memo)
                    .submitLabel(.done)
                    .onSubmit { focusedField.wrappedValue = nil }
                Text("\(memo.count)/\(Transaction.memoLimit)")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                    .accessibilityLabel("메모 \(memo.count)자, 최대 \(Transaction.memoLimit)자")
            }
            Divider().overlay(DesignSystemAsset.border.swiftUIColor)
            Button {
                focusedField.wrappedValue = nil
                onDateTap()
            } label: {
                InputRow(icon: .calendar) {
                    Text(date.dotDateWeekdayFormatted)
                        .font(.sd.callout)
                        .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                    Spacer()
                    SDIcon.chevronRight.image
                        .font(.system(size: SDSize.iconS - SDSpacing.xs, weight: .semibold))
                        .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("날짜, \(date.monthDayWeekdayFormatted)")
            .accessibilityHint("눌러서 날짜를 바꿔요")
        }
        .padding(.horizontal, SDSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: SDRadius.m)
                .fill(DesignSystemAsset.surface.swiftUIColor)
        )
    }
}
