import Clients
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

public struct BudgetSettingsView: View {
    @Bindable var store: StoreOf<BudgetSettingsFeature>

    public init(store: StoreOf<BudgetSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SDSpacing.xl) {
                VStack(alignment: .leading, spacing: SDSpacing.xs) {
                    Text("내가 설정한 예산")
                        .font(.sd.displayHeadline)
                        .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                        .accessibilityAddTraits(.isHeader)
                    Text("예산과 알림 금액을 관리해요")
                        .font(.sd.callout)
                        .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                }

                if !store.isExisting, let lastResult = store.lastResult {
                    LastResultCard(result: lastResult)
                }

                VStack(spacing: 0) {
                    SettingRow(icon: .money, tint: DesignSystemAsset.primary.swiftUIColor, title: "예산 금액", value: amountText(store.draft.amount)) {
                        store.send(.amountRowTapped(.budget))
                    }
                    SettingRow(icon: .calendar, tint: DesignSystemAsset.categoryBlue.swiftUIColor, title: "시작일", value: store.draft.startDate.dotDateFormatted) {
                        store.send(.dateRowTapped(.start))
                    }
                    SettingRow(icon: .calendar, tint: DesignSystemAsset.categoryBlue.swiftUIColor, title: "만기일", value: store.draft.dueDate.dotDateFormatted) {
                        store.send(.dateRowTapped(.due))
                    }
                    SettingRow(icon: .alert, tint: DesignSystemAsset.danger.swiftUIColor, title: "위험 알림 금액", value: amountText(store.draft.dangerAmount)) {
                        store.send(.amountRowTapped(.danger))
                    }
                    SettingRow(icon: .info, tint: DesignSystemAsset.warning.swiftUIColor, title: "경고 알림 금액", value: amountText(store.draft.warnAmount)) {
                        store.send(.amountRowTapped(.warning))
                    }
                }
                .padding(.horizontal, SDSpacing.l)
                .background(RoundedRectangle(cornerRadius: SDRadius.m).fill(DesignSystemAsset.surface.swiftUIColor))

                // 금액이 0이면 비율을 계산할 수 없어 미리보기를 숨긴다
                if store.draft.amount > 0 {
                    AlertRangePreview(budget: store.draft)
                }

                if let message = store.validationMessage ?? store.errorMessage {
                    Text(message)
                        .font(.sd.footnote)
                        .foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
                }
            }
            .padding(SDSpacing.page)
        }
        .safeAreaInset(edge: .bottom) {
            Button("저장하기") { store.send(.saveButtonTapped) }
                .buttonStyle(.sdPrimary)
                .disabled(!store.canSave)
                .padding(.horizontal, SDSpacing.page)
                .padding(.vertical, SDSpacing.s)
                .background(DesignSystemAsset.background.swiftUIColor)
        }
        .sdScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("예산 설정")
                    .font(.sd.displayBody)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .sheet(item: $store.scope(state: \.amountEntry, action: \.amountEntry)) { store in
            AmountEntryView(store: store).sdSheetStyle()
        }
        .sheet(item: $store.datePickerField) { field in
            DatePickSheet(
                title: field == .start ? "시작일" : "만기일",
                date: field == .start ? store.draft.startDate : store.draft.dueDate,
                today: store.today
            ) { store.send(.dateSelected(field, $0)) }
            .sdSheetStyle()
        }
        .sensoryFeedback(.success, trigger: store.isSaving) { old, new in !old && new }
        .onAppear { store.send(.onAppear) }
    }

    private func amountText(_ amount: Int) -> String {
        amount > 0 ? amount.wonFormatted : "입력해요"
    }
}

#Preview {
    NavigationStack {
        BudgetSettingsView(
            store: Store(initialState: BudgetSettingsFeature.State(today: .now)) {
                BudgetSettingsFeature()
            }
        )
    }
}
