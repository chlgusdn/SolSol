import Core
import DesignSystem
import Domain
import SwiftUI

/// 날짜 선택 바텀시트 — 월 이동 + 날짜 선택 + "이 날짜로 설정해요"
struct DatePickSheet: View {
    let title: String
    let today: Date
    let onSelect: (Date) -> Void
    @State private var draft: Date
    @State private var month: DateInterval

    init(title: String, date: Date, today: Date, onSelect: @escaping (Date) -> Void) {
        self.title = title
        self.today = today
        self.onSelect = onSelect
        self._draft = State(initialValue: date)
        self._month = State(initialValue: .month(containing: date))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.l) {
            Text(title)
                .font(.sd.title)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            HStack {
                monthButton(.back, label: "이전 달") { month = month.shiftedMonth(by: -1) }
                Spacer()
                Text(month.start.yearMonthFormatted)
                    .font(.sd.displayBody)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Spacer()
                monthButton(.chevronRight, label: "다음 달") { month = month.shiftedMonth(by: 1) }
            }
            SDCalendar(month: month, today: today, selection: draft, onSelect: { draft = $0 })
            Button("이 날짜로 설정해요") { onSelect(draft) }
                .buttonStyle(.sdPrimary)
        }
    }

    private func monthButton(_ icon: SDIcon, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon.image
                .font(.system(size: SDSize.iconS, weight: .semibold))
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                .frame(width: SDSize.touchTarget, height: SDSize.touchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
