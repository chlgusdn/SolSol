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
                    .font(.sd.caption)
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
                        .font(.sd.caption)
                }
            }
        }
        .overlay {
            if store.transactions.isEmpty && !store.isLoading {
                ContentUnavailableView("거래 내역이 없어요", systemImage: "wonsign.circle", description: Text("+ 버튼으로 첫 거래를 기록해보세요"))
            }
        }
        .scrollContentBackground(.hidden)
        .sdScreen()
        .navigationTitle("솔솔")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.addButtonTapped)
                } label: {
                    Image(systemName: "plus")
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
                Button(action: onPrevious) { Image(systemName: "chevron.left") }
                    .accessibilityLabel("이전 달")
                Text(month.start, format: .dateTime.year().month())
                    .font(.sd.bodyBold)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                Button(action: onNext) { Image(systemName: "chevron.right") }
                    .accessibilityLabel("다음 달")
            }
            .buttonStyle(.borderless)
            .tint(DesignSystemAsset.primary.swiftUIColor)

            SDAmountText(summary.balance, style: .signed, font: .sd.largeTitle)

            HStack(spacing: SDSpacing.xl) {
                LabeledAmount(title: TransactionType.income.displayName, amount: summary.income, color: DesignSystemAsset.income.swiftUIColor)
                LabeledAmount(title: TransactionType.expense.displayName, amount: summary.expense, color: DesignSystemAsset.expense.swiftUIColor)
            }
        }
        .sdCard()
    }
}

private struct LabeledAmount: View {
    let title: String
    let amount: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: SDSpacing.xxs) {
            Text(title)
                .font(.sd.caption)
                .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
            Text(amount.wonFormatted)
                .font(.sd.bodyBold)
                .monospacedDigit()
                .foregroundStyle(color)
                .contentTransition(.numericText(value: Double(amount)))
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: SDSpacing.m) {
            VStack(alignment: .leading, spacing: SDSpacing.xxs) {
                Text(transaction.category.displayName)
                    .font(.sd.body)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                if !transaction.memo.isEmpty {
                    Text(transaction.memo)
                        .font(.sd.caption)
                        .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                }
            }
            Spacer()
            SDAmountText(transaction.signedAmount, style: .signed)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        HomeView(
            store: Store(initialState: HomeFeature.State(month: .month(containing: .now))) {
                HomeFeature()
            }
        )
    }
}
