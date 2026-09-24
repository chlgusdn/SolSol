import DesignSystem
import Domain
import SwiftUI

struct CategoryChips: View {
    let categories: [TransactionCategory]
    let selectedID: TransactionCategory.ID
    let onSelect: (TransactionCategory.ID) -> Void
    let onAdd: () -> Void

    var body: some View {
        SDFlowLayout(spacing: SDSpacing.xs) {
            ForEach(categories) { category in
                SDCategoryChip(
                    category.name,
                    color: SDCategoryColor(rawValue: category.colorKey) ?? .brand,
                    isSelected: category.id == selectedID
                ) {
                    onSelect(category.id)
                }
            }
            AddCategoryChip(action: onAdd)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
