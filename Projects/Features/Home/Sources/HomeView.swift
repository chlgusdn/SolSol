import Clients
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

public struct HomeView: View {
    let store: StoreOf<HomeFeature>
    @State private var shortcutTapCount = 0

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 스크롤 영역이 화면 위 가장자리에 닿지 않아야 카드가 상태 표시줄 아래로 넘어가지 않는다
            MonthHeader(month: store.month.start, canMoveNext: store.canMoveToNextMonth) {
                store.send(.previousMonthButtonTapped)
            } onNext: {
                store.send(.nextMonthButtonTapped)
            }
            .padding(.horizontal, SDSpacing.page)

            ScrollView {
                VStack(spacing: SDSpacing.m) {
                    SpendingCard(
                        label: store.isTodaySelected ? "오늘 지출" : "\(store.selectedDay.monthDayFormatted) 지출",
                        amount: store.selectedDayExpense,
                        monthLabel: monthName,
                        monthExpense: store.summary.expense
                    )

                    SDCalendar(
                        month: store.month,
                        today: store.today,
                        selection: store.selectedDay,
                        amount: { calendarAmount(store.dailyAmounts[$0]) },
                        onSelect: { store.send(.dayTapped($0)) }
                    )
                    .sdCard(.floating, padding: SDSpacing.m)

                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Label {
                            Text("지출 추가")
                        } icon: {
                            SDIcon.plus.image.foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
                        }
                    }
                    .buttonStyle(.sdSecondary)

                    HStack(spacing: SDSpacing.cardGap) {
                        ShortcutCard(icon: .money, title: "0원의 기적", subtitle: "무소비 데이 · 텅장방지") { open(.budget) }
                        ShortcutCard(icon: .trendingUp, title: "통계", subtitle: "이번달은 얼마 썼을까요?") { open(.statistics) }
                        ShortcutCard(icon: .repeat, title: "고정 지출", subtitle: "매달 빠져나가는 돈") { open(.fixedExpense) }
                    }

                    InsightBanner(insight: insight)

                    if let message = store.errorMessage {
                        Text(message)
                            .font(.sd.footnote)
                            .foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
                    }

                    DayTransactionsCard(
                        title: store.isTodaySelected ? "오늘 거래" : "\(store.selectedDay.monthDayFormatted) 거래",
                        emptyTitle: store.isTodaySelected ? "아직 기록한 내역이 없어요" : "이 날은 기록된 내역이 없어요",
                        transactions: store.selectedTransactions,
                        onViewAll: { open(.transactionList) },
                        onAdd: { store.send(.addButtonTapped) },
                        onSelect: { store.send(.transactionTapped($0)) }
                    )
                }
                .padding(.horizontal, SDSpacing.page)
                .padding(.top, SDSpacing.xs)
                .padding(.bottom, SDSpacing.xxl)
            }
        }
        .sdScreen()
        .toolbar(.hidden, for: .navigationBar)
        .sensoryFeedback(.selection, trigger: store.selectedDay)
        .sensoryFeedback(.impact(weight: .light), trigger: store.month)
        .sensoryFeedback(.impact(weight: .light), trigger: shortcutTapCount)
        .onAppear { store.send(.onAppear) }
    }

    private var monthName: String {
        store.isCurrentMonth ? "이번달" : store.month.start.formatted(.dateTime.month(.wide).locale(Locale(identifier: "ko_KR")))
    }

    private var insight: InsightBanner.Insight {
        guard !store.transactions.isEmpty else {
            return .init(icon: .info, title: "이번 달 기록을 시작해보아요", message: "수익과 지출을 기록하면 인사이트를 알려드려요")
        }
        let current = "\(monthName) 지출 \(store.summary.expense.wonFormatted)"
        guard let rate = store.expenseChangeRate else {
            return .init(icon: .trendingUp, title: "꾸준히 기록하고 있어요", message: current)
        }
        let title = switch rate {
        case ..<0: "지난달보다 \(-rate)% 덜 썼어요 😆"
        case 0: "지난달과 똑같이 썼어요 🙂"
        default: "지난달보다 \(rate)% 더 썼어요 😞"
        }
        return .init(icon: .trendingUp, title: title, message: "\(current) · 지난달 \(store.previousSummary.expense.wonFormatted)")
    }

    private func calendarAmount(_ amount: DailyAmount?) -> SDCalendar.Amount? {
        switch amount {
        case let .expense(value):
            SDCalendar.Amount(text: value.compactFormatted, accessibilityText: "지출 \(value.wonFormatted)")
        case let .income(value):
            SDCalendar.Amount(text: "+\(value.compactFormatted)", accessibilityText: "수입 \(value.wonFormatted)")
        case nil:
            nil
        }
    }

    private func open(_ shortcut: HomeFeature.Shortcut) {
        shortcutTapCount += 1
        store.send(.shortcutTapped(shortcut))
    }
}

#Preview {
    NavigationStack {
        HomeView(
            store: Store(initialState: HomeFeature.State(today: .now)) {
                HomeFeature()
            }
        )
    }
}
