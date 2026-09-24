import Clients
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

public struct StatisticsView: View {
    @Bindable var store: StoreOf<StatisticsFeature>
    @State private var selectedPoint: Int?

    public init(store: StoreOf<StatisticsFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            StatisticsHeader()

            ScrollView {
                VStack(spacing: SDSpacing.xl) {
                    VStack(spacing: SDSpacing.m) {
                        PeriodButton(period: store.period) { store.send(.periodButtonTapped) }
                        StatisticsTabBar(selection: store.tab) { store.send(.tabSelected($0)) }
                    }

                    if let message = store.errorMessage {
                        Text(message)
                            .font(.sd.footnote)
                            .foregroundStyle(DesignSystemAsset.expense.swiftUIColor)
                    }

                    if store.isEmpty {
                        if !store.isLoading {
                            SDEmptyState(
                                icon: .barChart,
                                title: "아직 보여드릴 통계가 없어요",
                                message: "수입과 지출을 기록하면\n여기에서 소비 패턴을 알려드려요"
                            )
                            .padding(.top, SDSpacing.huge)
                        }
                    } else {
                        Text(insight)
                            .font(.sd.displayHeadline)
                            .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .accessibilityAddTraits(.isHeader)

                        chart

                        HighlightsSection(
                            largestIncome: store.largestIncome,
                            largestExpense: store.largestExpense,
                            frequentCategory: store.frequentCategory
                        )
                    }
                }
                .padding(SDSpacing.page)
            }
            .background(
                UnevenRoundedRectangle(topLeadingRadius: SDRadius.drawer, topTrailingRadius: SDRadius.drawer)
                    .fill(DesignSystemAsset.surface.swiftUIColor)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .background(DesignSystemAsset.surfaceDark.swiftUIColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DesignSystemAsset.surfaceDark.swiftUIColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: $store.scope(state: \.periodPicker, action: \.periodPicker)) { store in
            PeriodPickerView(store: store).sdSheetStyle()
        }
        .onChange(of: store.tab) { selectedPoint = nil }
        .onChange(of: store.period) { selectedPoint = nil }
        .sensoryFeedback(.selection, trigger: store.tab)
        // 드래그 중 칸이 바뀔 때만 햅틱을 낸다
        .sensoryFeedback(.selection, trigger: selectedPoint) { _, new in new != nil }
        .onAppear { store.send(.onAppear) }
    }

    @ViewBuilder
    private var chart: some View {
        switch store.tab {
        case .average:
            VStack(spacing: SDSpacing.l) {
                AverageSummary(unit: store.unit, average: store.average)
                SDBarChart(
                    points: chartPoints,
                    averageIncome: store.average.income,
                    averageExpense: store.average.expense,
                    selection: $selectedPoint
                )
            }
        case .trend:
            SDLineChart(points: chartPoints, selection: $selectedPoint)
        case .report:
            SDDonutChart(slices: store.expenseShares.enumerated().map { index, share in
                SDDonutChart.Slice(
                    id: index,
                    label: share.category?.name ?? "기타",
                    amount: share.amount,
                    ratio: share.ratio,
                    color: share.category.flatMap { SDCategoryColor(rawValue: $0.colorKey) }
                )
            })
        }
    }

    private var chartPoints: [SDChartPoint] {
        store.buckets.enumerated().map { index, bucket in
            SDChartPoint(
                id: index,
                label: bucketLabel(bucket.start),
                title: store.unit == .day ? bucket.start.monthDayFormatted : bucket.start.yearMonthFormatted,
                income: bucket.income,
                expense: bucket.expense
            )
        }
    }

    private func bucketLabel(_ date: Date) -> String {
        let component: Calendar.Component = store.unit == .day ? .day : .month
        let value = Calendar.current.component(component, from: date)
        return store.unit == .day ? "\(value)" : "\(value)월"
    }

    private var insight: String {
        switch store.tab {
        case .average:
            guard let peak = store.peakExpenseBucket else { return "이 기간엔 지출이 없어요 😆" }
            let when = store.unit == .day ? peak.start.monthDayFormatted : "\(bucketLabel(peak.start))"
            return "\(when)에 가장 많이 지출했어요 😞"
        case .trend:
            guard let rate = store.expenseTrendRate else { return "소비 추세를 알아보아요 😆" }
            switch rate {
            case ..<0: return "최근 지출이 \(-rate)% 줄었어요 😆"
            case 0: return "지출이 꾸준해요 🙂"
            default: return "최근 지출이 \(rate)% 늘었어요 😞"
            }
        case .report:
            guard let top = store.expenseShares.first else { return "이 기간엔 지출이 없어요 😆" }
            return "\"\(top.category?.name ?? "기타")\"에 가장 많이 지출했어요 😞"
        }
    }
}

#Preview {
    NavigationStack {
        StatisticsView(
            store: Store(initialState: StatisticsFeature.State(today: .now)) {
                StatisticsFeature()
            }
        )
    }
}
