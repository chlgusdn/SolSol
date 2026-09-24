import Foundation

/// 거래 목록에 대한 순수 계산 로직
public enum TransactionCalculator {
    /// 메모리에 있는 거래 목록의 합계 (DB 집계가 불가능한 경우에만 사용)
    public static func summary(of transactions: [Transaction]) -> TransactionSummary {
        transactions.reduce(into: .zero) { result, transaction in
            switch transaction.type {
            case .income: result.income += transaction.amount
            case .expense: result.expense += transaction.amount
            }
        }
    }

    /// 날짜(일) 단위 그룹핑 — 최신 날짜 순
    public static func groupedByDay(
        _ transactions: [Transaction],
        calendar: Calendar = .current
    ) -> [(day: Date, transactions: [Transaction])] {
        Dictionary(grouping: transactions) { calendar.startOfDay(for: $0.date) }
            .map { (day: $0.key, transactions: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.day > $1.day }
    }

    /// 날짜(일)별 캘린더 금액 — 지출이 있으면 지출 합계, 수입만 있으면 수입 합계
    public static func dailyAmounts(
        _ transactions: [Transaction],
        calendar: Calendar = .current
    ) -> [Date: DailyAmount] {
        Dictionary(grouping: transactions) { calendar.startOfDay(for: $0.date) }
            .compactMapValues { items in
                let total = summary(of: items)
                if total.expense > 0 { return .expense(total.expense) }
                if total.income > 0 { return .income(total.income) }
                return nil
            }
    }

    /// 지난달 대비 지출 증감률(%, 반올림). 지난달 지출이 0이면 비교할 수 없어 nil
    public static func expenseChangeRate(current: TransactionSummary, previous: TransactionSummary) -> Int? {
        guard previous.expense > 0 else { return nil }
        let rate = Double(current.expense - previous.expense) / Double(previous.expense) * 100
        return Int(rate.rounded())
    }
}
