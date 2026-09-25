import Clients
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

public struct BudgetStatusView: View {
    @Bindable var store: StoreOf<BudgetStatusFeature>

    public init(store: StoreOf<BudgetStatusFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: SDSpacing.xl) {
                if let message = store.errorMessage {
                    Text(message)
                        .font(.sd.footnote)
                        .foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
                }

                if let budget = store.budget, store.isExpired {
                    ExpiredResult(budget: budget, spent: store.spent) { store.send(.settingsButtonTapped) }
                } else if let budget = store.budget, let status = store.status {
                    DueDial(
                        progress: store.remainingPeriodRatio,
                        color: status.color,
                        daysRemaining: store.daysRemaining,
                        dueDate: budget.dueDate
                    )
                    StatusBanner(
                        status: status,
                        usageRatio: store.usageRatio,
                        overAmount: store.overAmount,
                        differencePercent: budget.differencePercent(spent: store.spent)
                    )
                    UsageCard(budget: budget, spent: store.spent, remaining: store.remaining, color: status.color)
                    Button {
                        store.send(.addExpenseButtonTapped)
                    } label: {
                        Label {
                            Text("지출 추가")
                        } icon: {
                            SDIcon.plus.image.foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
                        }
                    }
                    .buttonStyle(.sdSecondary)
                } else if store.hasLoaded {
                    EmptyBudget { store.send(.settingsButtonTapped) }
                        .padding(.top, SDSpacing.huge)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(SDSpacing.page)
        }
        .sdScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("텅장 방지")
                    .font(.sd.displayBody)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                    .accessibilityAddTraits(.isHeader)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("예산 설정") { store.send(.settingsButtonTapped) }
                    if store.budget != nil {
                        Button("예산 삭제", role: .destructive) { store.send(.deleteButtonTapped) }
                    }
                } label: {
                    SDIcon.settings.image.foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                }
                .accessibilityLabel("예산 메뉴")
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear { store.send(.onAppear) }
    }
}

#Preview {
    NavigationStack {
        BudgetStatusView(
            store: Store(initialState: BudgetStatusFeature.State(today: .now)) {
                BudgetStatusFeature()
            }
        )
    }
}
