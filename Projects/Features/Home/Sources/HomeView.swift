import Clients
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

public struct HomeView: View {
    let store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            Section {
                SummaryCard(month: store.month, summary: store.summary) {
                    store.send(.previousMonthButtonTapped)
                } onNext: {
                    store.send(.nextMonthButtonTapped)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if let message = store.errorMessage {
                Text(message)
                    .font(.sd.footnote)
                    .foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
            }

            ForEach(store.dailyGroups) { group in
                Section {
                    ForEach(group.transactions) { transaction in
                        Button {
                            store.send(.transactionTapped(transaction))
                        } label: {
                            TransactionRow(transaction: transaction)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(group.day, format: .dateTime.month().day().weekday())
                        .font(.sd.footnote)
                }
            }
        }
        .overlay {
            if store.transactions.isEmpty && !store.isLoading {
                SDEmptyState(
                    icon: .money,
                    title: "아직 거래 내역이 없어요",
                    message: "+ 버튼으로 첫 거래를 기록해보세요"
                )
            }
        }
        .scrollContentBackground(.hidden)
        .sdScreen()
        .navigationTitle("쏠쏠")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.addButtonTapped)
                } label: {
                    SDIcon.plus.image
                }
                .accessibilityLabel("거래 추가")
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}

private struct SummaryCard: View {
    let month: DateInterval
    let summary: TransactionSummary
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.m) {
            HStack {
                Button(action: onPrevious) { SDIcon.back.image }
                    .accessibilityLabel("이전 달")
                Text(month.start, format: .dateTime.year().month())
                    .font(.sd.displayHeadline)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Button(action: onNext) { SDIcon.chevronRight.image }
                    .accessibilityLabel("다음 달")
            }
            .buttonStyle(.borderless)
            .tint(DesignSystemAsset.primary.swiftUIColor)

            SDAmountText(summary.balance, style: .signed, font: .sd.displayTitle)

            HStack(spacing: SDSpacing.xl) {
                LabeledAmount(title: TransactionType.income.displayName, amount: summary.income, style: .income)
                LabeledAmount(title: TransactionType.expense.displayName, amount: summary.expense, style: .expense)
            }
        }
        .sdCard()
    }
}

private struct LabeledAmount: View {
    let title: String
    let amount: Int
    let style: SDAmountText.Style

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.xxs) {
            Text(title)
                .font(.sd.footnote)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            SDAmountText(amount, style: style)
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        SDTransactionRow(
            title: transaction.title,
            subtitle: transaction.memo.isEmpty ? transaction.category.name : transaction.memo,
            amount: transaction.signedAmount,
            color: SDCategoryColor(rawValue: transaction.category.colorKey)?.color
                ?? DesignSystemAsset.textSecondary.swiftUIColor,
            icon: SDIcon(key: transaction.category.iconKey)
        )
    }
}
