import DesignSystem
import Domain
import SwiftUI

struct DayTransactionsCard: View {
    let title: String
    let emptyTitle: String
    let transactions: [Transaction]
    let onViewAll: () -> Void
    let onAdd: () -> Void
    let onSelect: (Transaction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.s) {
            HStack {
                Text(title)
                    .font(.sd.footnote)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button(action: onViewAll) {
                    HStack(spacing: SDSpacing.xxs) {
                        Text("전체보기")
                        SDIcon.chevronRight.image.font(.system(size: SDSize.iconS - SDSpacing.xs))
                    }
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                    .frame(minHeight: SDSize.touchTarget)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if transactions.isEmpty {
                SDEmptyState(icon: .money, title: emptyTitle, actionTitle: "첫 지출 기록하기", action: onAdd)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SDSpacing.m)
            } else {
                ForEach(transactions) { transaction in
                    Divider().overlay(DesignSystemAsset.border.swiftUIColor)
                    Button {
                        onSelect(transaction)
                    } label: {
                        SDTransactionRow(
                            title: transaction.title,
                            subtitle: transaction.category.name,
                            amount: transaction.signedAmount,
                            color: SDCategoryColor(rawValue: transaction.category.colorKey)?.color
                                ?? DesignSystemAsset.textSecondary.swiftUIColor,
                            icon: SDIcon(key: transaction.category.iconKey)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, SDSpacing.l)
        .padding(.bottom, SDSpacing.s)
        .background(
            RoundedRectangle(cornerRadius: SDRadius.m)
                .fill(DesignSystemAsset.surface.swiftUIColor)
        )
    }
}
