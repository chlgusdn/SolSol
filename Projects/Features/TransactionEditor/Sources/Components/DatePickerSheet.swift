import DesignSystem
import SwiftUI

/// 날짜 선택 바텀시트 — 고른 날은 "이 날짜로 설정해요"를 눌러야 반영된다
struct DatePickerSheet: View {
    let onSelect: (Date) -> Void
    @State private var draft: Date

    init(date: Date, onSelect: @escaping (Date) -> Void) {
        self.onSelect = onSelect
        self._draft = State(initialValue: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.l) {
            Text("날짜 선택")
                .font(.sd.title)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            DatePicker("날짜", selection: $draft, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .tint(DesignSystemAsset.primary.swiftUIColor)
            Button("이 날짜로 설정해요") { onSelect(draft) }
                .buttonStyle(.sdPrimary)
        }
    }
}
