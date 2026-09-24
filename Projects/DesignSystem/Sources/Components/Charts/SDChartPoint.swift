import Foundation

/// 수익·지출 차트의 한 칸 (날 또는 달)
public struct SDChartPoint: Equatable, Identifiable, Sendable {
    /// x축 짧은 라벨 ("15", "1월")
    public let label: String
    /// 툴팁·VoiceOver 제목 ("9월 15일", "2026년 1월")
    public let title: String
    public let income: Int
    public let expense: Int
    public let id: Int

    /// 차트 x축 범주 키 — 정수 x축에서는 묶음 막대의 폭이 계산되지 않아 문자열 범주로 그린다
    var key: String { String(id) }

    public init(id: Int, label: String, title: String, income: Int, expense: Int) {
        self.id = id
        self.label = label
        self.title = title
        self.income = income
        self.expense = expense
    }
}
