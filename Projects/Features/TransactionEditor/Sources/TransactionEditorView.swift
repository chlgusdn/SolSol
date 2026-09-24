import Clients
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

public struct TransactionEditorView: View {
    @Bindable var store: StoreOf<TransactionEditorFeature>
    @State private var keyTapCount = 0
    @FocusState private var focusedField: InputFieldsCard.Field?

    public init(store: StoreOf<TransactionEditorFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            AmountHeader(amount: store.amount, type: store.type, shakeCount: store.shakeCount)
                // 금액을 누르면 키보드를 내리고 키패드로 돌아간다
                .onTapGesture { focusedField = nil }

            ScrollView {
                VStack(spacing: SDSpacing.m) {
                    if store.type == .expense {
                        CategoryChips(
                            categories: store.availableCategories,
                            selectedID: store.categoryID,
                            onSelect: { focusedField = nil; store.send(.categoryTapped($0)) },
                            onAdd: { focusedField = nil; store.send(.addCategoryButtonTapped) }
                        )
                    }
                    InputFieldsCard(
                        title: $store.title,
                        memo: $store.memo,
                        date: store.date,
                        onDateTap: { store.send(.dateRowTapped) },
                        focusedField: $focusedField
                    )
                    if store.type == .expense {
                        FixedExpenseCheckbox(isOn: store.isFixed) {
                            focusedField = nil
                            store.send(.fixedToggled)
                        }
                    }
                }
                .padding(SDSpacing.page)
                // 입력 칸·버튼이 아닌 빈 곳을 누르면 키보드를 내린다
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = nil }
                }
            }
            .scrollDismissesKeyboard(.interactively)

            // 텍스트 입력 중에는 시스템 키보드와 겹치지 않도록 키패드를 숨긴다
            if focusedField == nil {
                SDKeypad { key in
                    keyTapCount += 1
                    store.send(.keypadTapped(key.amountKey))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.sd.standard, value: focusedField)
        .sdScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DesignSystemAsset.surfaceDark.swiftUIColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TypeToggle(type: store.type) {
                    focusedField = nil
                    store.send(.typeChanged($0))
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    store.send(.saveButtonTapped)
                } label: {
                    SDIcon.check.image
                        .font(.system(size: SDSize.iconM, weight: .bold))
                        .foregroundStyle(DesignSystemAsset.onPrimary.swiftUIColor)
                }
                .disabled(!store.canSave)
                .opacity(store.canSave ? 1 : SDOpacity.disabled)
                .accessibilityLabel("저장")
            }
        }
        .sdToast($store.toast)
        .sheet(item: $store.scope(state: \.destination?.addCategory, action: \.destination.addCategory)) { store in
            AddCategoryView(store: store).sdSheetStyle()
        }
        .sdSheet(isPresented: $store.isDatePickerPresented) {
            DatePickerSheet(date: store.date) { store.send(.dateSelected($0)) }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .sensoryFeedback(.impact(weight: .light), trigger: keyTapCount)
        .sensoryFeedback(.error, trigger: store.shakeCount)
        .sensoryFeedback(.success, trigger: store.isSaved) { old, new in !old && new }
        .onAppear { store.send(.onAppear) }
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

#Preview("새 지출") {
    NavigationStack {
        TransactionEditorView(
            store: Store(initialState: TransactionEditorFeature.State(date: .now)) {
                TransactionEditorFeature()
            }
        )
    }
}

#Preview("수정") {
    NavigationStack {
        TransactionEditorView(
            store: Store(initialState: TransactionEditorFeature.State(transaction: Transaction.previewSamples[0])) {
                TransactionEditorFeature()
            }
        )
    }
}
