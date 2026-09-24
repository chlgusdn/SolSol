import ComposableArchitecture
import Domain
import Foundation

/// 통계 기간 선택 시트 — 빠른 선택(최근 7·14·30일) + 범위 캘린더(첫 탭 시작일, 둘째 탭 종료일)
@Reducer
public struct PeriodPickerFeature {
    @ObservableState
    public struct State: Equatable {
        public var today: Date
        public var displayedMonth: DateInterval
        /// 선택 구간의 첫날 00:00
        public var start: Date
        /// 선택 구간의 마지막 날 00:00 (포함). nil이면 종료일을 고르는 중
        public var end: Date?

        /// `period`는 [시작일 00:00, 종료일 다음날 00:00)
        public init(period: DateInterval, today: Date) {
            let calendar = Calendar.current
            self.today = calendar.startOfDay(for: today)
            let start = calendar.startOfDay(for: period.start)
            let lastDay = calendar.date(byAdding: .day, value: -1, to: period.end) ?? period.start
            let end = calendar.startOfDay(for: max(lastDay, period.start))
            self.start = start
            self.end = end
            self.displayedMonth = .month(containing: end)
        }

        public var canConfirm: Bool { end != nil }
        public var canMoveToNextMonth: Bool { displayedMonth.end <= DateInterval.month(containing: today).start }

        public var range: ClosedRange<Date> {
            start...(end ?? start)
        }

        /// 선택 결과 [시작일, 종료일 다음날)
        public var period: DateInterval? {
            guard let end, let dayAfter = Calendar.current.date(byAdding: .day, value: 1, to: end) else { return nil }
            return DateInterval(start: start, end: dayAfter)
        }
    }

    public enum Action: Equatable {
        case dayTapped(Date)
        case quickRangeTapped(days: Int)
        case previousMonthButtonTapped
        case nextMonthButtonTapped
        case confirmButtonTapped
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case selected(DateInterval)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .dayTapped(date):
                let day = Calendar.current.startOfDay(for: date)
                if state.end == nil {
                    // 종료일이 시작일보다 앞이면 서로 바꾼다
                    state.end = max(day, state.start)
                    state.start = min(day, state.start)
                } else {
                    state.start = day
                    state.end = nil
                }
                return .none

            case let .quickRangeTapped(days):
                state.end = state.today
                state.start = Calendar.current.date(byAdding: .day, value: -(days - 1), to: state.today) ?? state.today
                state.displayedMonth = .month(containing: state.today)
                return .none

            case .previousMonthButtonTapped:
                state.displayedMonth = state.displayedMonth.shiftedMonth(by: -1)
                return .none

            case .nextMonthButtonTapped:
                guard state.canMoveToNextMonth else { return .none }
                state.displayedMonth = state.displayedMonth.shiftedMonth(by: 1)
                return .none

            case .confirmButtonTapped:
                guard let period = state.period else { return .none }
                return .send(.delegate(.selected(period)))

            case .delegate:
                return .none
            }
        }
    }
}
