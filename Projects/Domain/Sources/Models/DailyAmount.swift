import Foundation

/// 캘린더 하루 칸에 표시할 금액
public enum DailyAmount: Hashable, Sendable {
    /// 그날 지출 합계
    case expense(Int)
    /// 지출 없이 수입만 있는 날의 수입 합계
    case income(Int)
}
