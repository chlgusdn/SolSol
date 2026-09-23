import Foundation

/// 텅장방지 예산. 기간(`startDate`…`dueDate`) 동안의 지출을 경고·위험 금액과 비교한다
public struct Budget: Hashable, Sendable {
    public var amount: Int
    public var startDate: Date
    /// 만기일 (이 날까지 포함)
    public var dueDate: Date
    public var warnAmount: Int
    public var dangerAmount: Int

    public init(amount: Int, startDate: Date, dueDate: Date, warnAmount: Int, dangerAmount: Int) {
        self.amount = amount
        self.startDate = startDate
        self.dueDate = dueDate
        self.warnAmount = warnAmount
        self.dangerAmount = dangerAmount
    }

    /// 경고·위험 기본 비율 (기획서: 경고 70%, 위험 90%)
    public static let defaultWarnRatio = 0.7
    public static let defaultDangerRatio = 0.9

    /// 예산 금액에서 기본 비율로 경고·위험 금액을 정한 예산
    public static func suggested(amount: Int, startDate: Date, dueDate: Date) -> Budget {
        Budget(
            amount: amount,
            startDate: startDate,
            dueDate: dueDate,
            warnAmount: Int((Double(amount) * defaultWarnRatio).rounded()),
            dangerAmount: Int((Double(amount) * defaultDangerRatio).rounded())
        )
    }

    public enum ValidationError: Error, Equatable, Sendable {
        case nonPositiveAmount
        case dueDateBeforeStart
        /// 0 < 경고 < 위험 이어야 함
        case invalidWarnAmount
        /// 위험 ≤ 예산 이어야 함
        case dangerExceedsAmount
    }

    /// 기획서 제약: 0 < 경고 < 위험 ≤ 예산, 시작일 ≤ 만기일
    public var validationError: ValidationError? {
        if amount <= 0 { return .nonPositiveAmount }
        if dueDate < startDate { return .dueDateBeforeStart }
        if warnAmount <= 0 || warnAmount >= dangerAmount { return .invalidWarnAmount }
        if dangerAmount > amount { return .dangerExceedsAmount }
        return nil
    }

    public var isValid: Bool { validationError == nil }

    /// 지출 합계 조회 구간 [시작일 00:00, 만기일 다음날 00:00)
    public func period(calendar: Calendar = .current) -> DateInterval {
        let start = calendar.startOfDay(for: startDate)
        let dueDay = calendar.startOfDay(for: dueDate)
        let end = calendar.date(byAdding: .day, value: 1, to: dueDay) ?? dueDay
        return DateInterval(start: start, end: max(start, end))
    }

    public func status(spent: Int) -> BudgetStatus {
        if spent >= dangerAmount { return .danger }
        if spent >= warnAmount { return .warning }
        return .safe
    }

    /// 사용률 (0 이상, 초과 시 1보다 큼)
    public func usageRatio(spent: Int) -> Double {
        guard amount > 0 else { return 0 }
        return Double(spent) / Double(amount)
    }

    public func remaining(spent: Int) -> Int {
        amount - spent
    }

    /// 만기일까지 남은 일수 (만기일 당일 0, 지나면 0)
    public func daysRemaining(from now: Date, calendar: Calendar = .current) -> Int {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: dueDate)
        ).day ?? 0
        return max(0, days)
    }
}

/// 텅장방지 단계
public enum BudgetStatus: Hashable, Sendable {
    case safe
    case warning
    case danger
}
