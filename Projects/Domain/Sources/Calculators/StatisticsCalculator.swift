import Foundation

/// 통계 계산 — 칸 경계 나누기와 DB 집계 결과의 가벼운 후처리 (합계·그룹화는 DB가 한다)
public enum StatisticsCalculator {
    public enum Unit: Equatable, Sendable {
        case day
        case month
    }

    /// 차트 막대·점 하나
    public struct Bucket: Equatable, Sendable {
        public var start: Date
        public var income: Int
        public var expense: Int

        public init(start: Date, income: Int, expense: Int) {
            self.start = start
            self.income = income
            self.expense = expense
        }
    }

    /// 지출 보고 도넛 조각. `category`가 nil이면 "기타"
    public struct CategoryShare: Equatable, Sendable {
        public var category: TransactionCategory?
        public var amount: Int
        public var ratio: Double

        public init(category: TransactionCategory?, amount: Int, ratio: Double) {
            self.category = category
            self.amount = amount
            self.ratio = ratio
        }
    }

    /// 31일 이하는 하루, 넘으면 월 단위
    public static let dailyUnitLimit = 31

    public static func unit(for period: DateInterval, calendar: Calendar = .current) -> Unit {
        let days = calendar.dateComponents([.day], from: period.start, to: period.end).day ?? 0
        return days <= dailyUnitLimit ? .day : .month
    }

    /// 기간을 빈틈없이 나눈 칸. 첫·마지막 칸은 기간 밖으로 나가지 않게 자른다
    public static func bucketIntervals(
        for period: DateInterval,
        unit: Unit,
        calendar: Calendar = .current
    ) -> [DateInterval] {
        let component: Calendar.Component = unit == .day ? .day : .month
        var cursor = unit == .day
            ? calendar.startOfDay(for: period.start)
            : DateInterval.month(containing: period.start, calendar: calendar).start
        var result: [DateInterval] = []
        while cursor < period.end {
            guard let next = calendar.date(byAdding: component, value: 1, to: cursor) else { break }
            let start = max(cursor, period.start)
            let end = min(next, period.end)
            if start < end { result.append(DateInterval(start: start, end: end)) }
            cursor = next
        }
        return result
    }

    /// 칸 경계와 DB 합계를 차트 칸으로 묶는다
    public static func buckets(intervals: [DateInterval], totals: [TransactionSummary]) -> [Bucket] {
        zip(intervals, totals).map { Bucket(start: $0.start, income: $1.income, expense: $1.expense) }
    }

    /// 단위당 평균 (거래가 없는 칸도 0으로 포함, 반올림)
    public static func average(of buckets: [Bucket]) -> TransactionSummary {
        guard !buckets.isEmpty else { return .zero }
        let count = Double(buckets.count)
        return TransactionSummary(
            income: Int((Double(buckets.reduce(0) { $0 + $1.income }) / count).rounded()),
            expense: Int((Double(buckets.reduce(0) { $0 + $1.expense }) / count).rounded())
        )
    }

    /// 뒤쪽 절반의 평균 지출이 앞쪽 절반보다 몇 % 늘었는지. 칸이 2개 미만이거나 앞쪽 지출이 0이면 nil
    public static func expenseTrendRate(_ buckets: [Bucket]) -> Int? {
        guard buckets.count >= 2 else { return nil }
        let half = buckets.count / 2
        let earlier = average(of: Array(buckets[..<half])).expense
        let later = average(of: Array(buckets[(buckets.count - half)...])).expense
        guard earlier > 0 else { return nil }
        return Int((Double(later - earlier) / Double(earlier) * 100).rounded())
    }

    /// 카테고리별 지출 비중 — 큰 순서로 `limit`개, 나머지는 "기타"(category nil) 하나로 묶는다
    public static func expenseShares(_ totals: [CategoryTotal], limit: Int = 4) -> [CategoryShare] {
        let total = totals.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        let sorted = totals
            .filter { $0.amount > 0 }
            .sorted { $0.amount != $1.amount ? $0.amount > $1.amount : $0.category.sortOrder < $1.category.sortOrder }

        var shares = sorted.prefix(limit).map {
            CategoryShare(category: $0.category, amount: $0.amount, ratio: Double($0.amount) / Double(total))
        }
        let rest = sorted.dropFirst(limit).reduce(0) { $0 + $1.amount }
        if rest > 0 {
            shares.append(CategoryShare(category: nil, amount: rest, ratio: Double(rest) / Double(total)))
        }
        return shares
    }

    /// 가장 자주 쓴 지출 카테고리 (횟수가 같으면 금액이 큰 쪽)
    public static func mostFrequent(_ totals: [CategoryTotal]) -> CategoryTotal? {
        totals.filter { $0.count > 0 }.max { $0.count != $1.count ? $0.count < $1.count : $0.amount < $1.amount }
    }
}
