import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct AddCategoryView: View {
    @Bindable var store: StoreOf<AddCategoryFeature>
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.l) {
            Text("카테고리 추가")
                .font(.sd.title)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)

            VStack(alignment: .leading, spacing: SDSpacing.xs) {
                HStack {
                    TextField("이름을 입력해요", text: $store.name)
                        .font(.sd.body)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                    Text("\(store.nameLength)/\(TransactionCategory.nameLimit)")
                        .font(.sd.caption)
                        .foregroundStyle(
                            store.nameLength > TransactionCategory.nameLimit
                                ? DesignSystemAsset.expense.swiftUIColor
                                : DesignSystemAsset.textTertiary.swiftUIColor
                        )
                }
                .padding(SDSpacing.m)
                .background(RoundedRectangle(cornerRadius: SDRadius.s).fill(DesignSystemAsset.background.swiftUIColor))

                if let message = store.errorMessage {
                    Text(message)
                        .font(.sd.caption)
                        .foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
                }
            }

            HStack(spacing: SDSpacing.m) {
                ForEach(SDCategoryColor.allCases, id: \.self) { color in
                    let isSelected = store.colorKey == color.rawValue
                    Button {
                        store.send(.colorTapped(color.rawValue))
                    } label: {
                        Circle()
                            .fill(color.color)
                            .frame(width: SDSize.iconXL - SDSpacing.s, height: SDSize.iconXL - SDSpacing.s)
                            .padding(SDSpacing.xxs + SDSpacing.xxs)
                            .overlay(Circle().strokeBorder(isSelected ? color.color : .clear, lineWidth: SDSize.borderThick))
                            .frame(minWidth: SDSize.touchTarget, minHeight: SDSize.touchTarget)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(color.displayName)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }

            Button("추가하기") { store.send(.addButtonTapped) }
                .buttonStyle(.sdPrimary)
                .disabled(!store.canAdd)
        }
        .onAppear { isNameFocused = true }
    }
}

#Preview {
    Color.clear.sdSheet(isPresented: .constant(true)) {
        AddCategoryView(store: Store(initialState: AddCategoryFeature.State()) { AddCategoryFeature() })
    }
}
