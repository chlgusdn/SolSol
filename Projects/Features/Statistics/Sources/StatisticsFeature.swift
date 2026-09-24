import Clients
import ComposableArchitecture
import Domain
import Foundation

/// 통계 — 기간별 평균·추세·지출 보고와 대표 거래
@Reducer
public struct StatisticsFeature {
    public enum Tab: Equatable, Sendable, CaseIterable {
        case average
        case trend
        case report
    }

    @ObservableState
    public struct State: Equatable {
        /// [시작일 00:00, 종료일 다음날 00:00)
        public var period: DateInterval
        public var today: Date
        public var tab: Tab = .average
        /// DB가 집계한 결과. 화면 계산은 이 작은 값들로만 한다
        public var buckets: [StatisticsCalculator.Bucket] = []
        public var categoryTotals: [CategoryTotal] = []
        public var largestIncome: Transaction?
        public var largestExpense: Transaction?
        public var transactionCount = 0
        public var isLoading = false
        public var errorMessage: String?
        @Presents public var periodPicker: PeriodPickerFeature.State?

        /// 기본 기간은 이번 달 1일 ~ 오늘
        public init(today: Date) {
            let calendar = Calendar.current
            let day = calendar.startOfDay(for: today)
            self.today = day
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            self.period = DateInterval(start: DateInterval.month(containing: day).start, end: tomorrow)
        }

        public var unit: StatisticsCalculator.Unit { StatisticsCalculator.unit(for: period) }

        public var bucketIntervals: [DateInterval] {
            StatisticsCalculator.bucketIntervals(for: period, unit: unit)
        }

        public var isEmpty: Bool { transactionCount == 0 }
        public var average: TransactionSummary { StatisticsCalculator.average(of: buckets) }
        public var expenseTrendRate: Int? { StatisticsCalculator.expenseTrendRate(buckets) }
        public var expenseShares: [StatisticsCalculator.CategoryShare] { StatisticsCalculator.expenseShares(categoryTotals) }
        public var frequentCategory: CategoryTotal? { StatisticsCalculator.mostFrequent(categoryTotals) }

        /// 지출이 가장 큰 칸 (지출이 없으면 nil)
        public var peakExpenseBucket: StatisticsCalculator.Bucket? {
            buckets.filter { $0.expense > 0 }.max { $0.expense < $1.expense }
        }
    }

    public enum Action: Equatable {
        case onAppear
        case tabSelected(Tab)
        case periodButtonTapped
        case snapshotUpdated(StatisticsSnapshot)
        case loadFailed(String)
        case periodPicker(PresentationAction<PeriodPickerFeature.Action>)
    }

    enum CancelID { case observation }

    @Dependency(\.statisticsClient) var statisticsClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return observe(&state)

            case let .tabSelected(tab):
                state.tab = tab
                return .none

            case .periodButtonTapped:
                state.periodPicker = PeriodPickerFeature.State(period: state.period, today: state.today)
                return .none

            case let .snapshotUpdated(snapshot):
                state.isLoading = false
                state.errorMessage = nil
                apply(snapshot, to: &state)
                return .none

            case let .loadFailed(message):
                state.isLoading = false
                state.errorMessage = message
                return .none

            case let .periodPicker(.presented(.delegate(.selected(period)))):
                state.period = period
                state.periodPicker = nil
                // 새 기간 결과가 오기 전까지 이전 기간 통계가 남아 보이지 않게 비운다
                apply(.empty, to: &state)
                return observe(&state)

            case .periodPicker:
                return .none
            }
        }
        .ifLet(\.$periodPicker, action: \.periodPicker) {
            PeriodPickerFeature()
        }
    }

    private func apply(_ snapshot: StatisticsSnapshot, to state: inout State) {
        state.buckets = StatisticsCalculator.buckets(intervals: state.bucketIntervals, totals: snapshot.bucketTotals)
        state.categoryTotals = snapshot.categoryTotals
        state.largestIncome = snapshot.largestIncome
        state.largestExpense = snapshot.largestExpense
        state.transactionCount = snapshot.transactionCount
    }

    private func observe(_ state: inout State) -> Effect<Action> {
        state.isLoading = true
        let period = state.period
        let buckets = state.bucketIntervals
        return .run { [statisticsClient] send in
            for try await snapshot in statisticsClient.observe(period: period, buckets: buckets) {
                await send(.snapshotUpdated(snapshot))
            }
        } catch: { error, send in
            await send(.loadFailed(error.localizedDescription))
        }
        .cancellable(id: CancelID.observation, cancelInFlight: true)
    }
}
