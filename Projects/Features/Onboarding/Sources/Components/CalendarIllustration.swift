import DesignSystem
import SwiftUI

struct CalendarIllustration: View {
    /// 0: 수입, 1: 지출, 2: 기록 없음 (프로토타입의 21칸 패턴)
    private let pattern = [2, 0, 2, 2, 1, 2, 0, 2, 1, 2, 0, 2, 2, 1, 0, 2, 1, 2, 2, 0, 2]

    var body: some View {
        VStack(spacing: SDSpacing.s) {
            Text("2025년 1월")
                .font(.sd.displayCaption)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: SDSpacing.xs), count: 7), spacing: SDSpacing.xs) {
                ForEach(Array(pattern.enumerated()), id: \.offset) { _, kind in
                    Circle()
                        .fill(color(for: kind))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .sdCard(.floating, radius: SDRadius.l)
        .frame(width: IllustrationSize.card)
    }

    private func color(for kind: Int) -> Color {
        switch kind {
        case 0: DesignSystemAsset.income.swiftUIColor
        case 1: DesignSystemAsset.expense.swiftUIColor
        default: DesignSystemAsset.border.swiftUIColor
        }
    }
}
