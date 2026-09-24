import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

public struct TransactionListView: View {
    @Bindable var store: StoreOf<TransactionListFeature>
    @State private var addTapCount = 0

    public init(store: StoreOf<TransactionListFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: SDSpacing.m) {
            MonthSummaryCard(
                label: store.isCurrentMonth ? "이번달 총 지출" : "\(store.month.start.formatted(.dateTime.month(.wide).locale(Locale(identifier: "ko_KR")))) 총 지출",
                expense: store.summary.expense,
                income: store.summary.income,
                budget: store.budget,
                usageRatio: store.budgetUsageRatio,
                onSetupBudget: { store.send(.budgetSetupButtonTapped) }
            )
            .padding(.horizontal, SDSpacing.page)

            if let message = store.errorMessage {
                Text(message)
                    .font(.sd.footnote)
                    .foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
                    .padding(.horizontal, SDSpacing.page)
            }

            if store.transactions.isEmpty && !store.isLoading {
                SDEmptyState(icon: .budget, title: "아직 거래 내역이 없어요", message: "첫 내역을 추가하고 쏠쏠하게 모아보아요")
                    .frame(maxHeight: .infinity)
            } else {
                transactionList
            }
        }
        .padding(.top, SDSpacing.s)
        .safeAreaInset(edge: .bottom) {
            Button("내역 추가") {
                addTapCount += 1
                store.send(.addButtonTapped)
            }
            .buttonStyle(.sdPrimary)
            .padding(.horizontal, SDSpacing.page)
            .padding(.vertical, SDSpacing.s)
            .background(DesignSystemAsset.background.swiftUIColor)
        }
        .sdScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(store.month.start.yearMonthFormatted)
                    .font(.sd.displayBody)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .sensoryFeedback(.impact(weight: .light), trigger: addTapCount)
        .onAppear { store.send(.onAppear) }
    }

    private var transactionList: some View {
        List {
            ForEach(store.dailyGroups) { group in
                Section {
                    ForEach(group.transactions) { transaction in
                        Button {
                            store.send(.transactionTapped(transaction))
                        } label: {
                            SDTransactionRow(
                                title: transaction.title,
                                subtitle: transaction.memo.isEmpty ? transaction.category.name : transaction.memo,
                                amount: transaction.signedAmount,
                                color: SDCategoryColor(rawValue: transaction.category.colorKey)?.color
                                    ?? DesignSystemAsset.textSecondary.swiftUIColor,
                                icon: SDIcon(key: transaction.category.iconKey)
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(DesignSystemAsset.surface.swiftUIColor)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("삭제") { store.send(.deleteSwiped(transaction)) }
                                .tint(DesignSystemAsset.expense.swiftUIColor)
                        }
                    }
                } header: {
                    DayGroupHeader(day: group.day, expense: group.expense)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .contentMargins(.horizontal, SDSpacing.page, for: .scrollContent)
    }
}

#Preview {
    NavigationStack {
        TransactionListView(
            store: Store(initialState: TransactionListFeature.State(month: .month(containing: .now), today: .now)) {
                TransactionListFeature()
            }
        )
    }
}
