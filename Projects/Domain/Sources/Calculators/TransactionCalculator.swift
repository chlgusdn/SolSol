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
}
