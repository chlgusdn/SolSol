import Clients
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct TransactionEditorView: View {
    @Bindable var store: StoreOf<TransactionEditorFeature>
    @FocusState private var isAmountFocused: Bool

    public init(store: StoreOf<TransactionEditorFeature>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section {
                Picker("유형", selection: $store.type.sending(\.typeChanged)) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            Section("금액") {
                TextField("0", text: $store.amountText)
                    .keyboardType(.numberPad)
                    .font(.sd.displayHeadline)
                    .focused($isAmountFocused)
            }

            Section("분류") {
                Picker("카테고리", selection: $store.category) {
                    ForEach(store.availableCategories, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                DatePicker("날짜", selection: $store.date)
                TextField("메모", text: $store.memo)
            }

            if store.isEditing {
                Section {
                    Button("삭제", role: .destructive) {
                        store.send(.deleteButtonTapped)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(store.isEditing ? "거래 수정" : "새 거래")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !store.isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { store.send(.cancelButtonTapped) }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") { store.send(.saveButtonTapped) }
                    .disabled(!store.canSave)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .sensoryFeedback(.success, trigger: store.isSaving) { old, new in old && !new }
        .onAppear { isAmountFocused = !store.isEditing }
    }
}

#Preview("새 거래") {
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
            store: Store(
                initialState: TransactionEditorFeature.State(transaction: Transaction.previewSamples[1])
            ) {
                TransactionEditorFeature()
            }
        )
    }
}
