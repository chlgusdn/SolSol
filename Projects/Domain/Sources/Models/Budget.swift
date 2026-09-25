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
        if spent > amount { return .exceeded }
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

    /// 예산 대비 더 쓴(+) / 아낀(-) 비율 %
    public func differencePercent(spent: Int) -> Int {
        Self.differencePercent(spent: spent, amount: amount)
    }

    /// 반올림하되, 조금이라도 넘거나 남았으면 0%가 되지 않게 한다 ("딱 맞게"와 구분)
    static func differencePercent(spent: Int, amount: Int) -> Int {
        guard amount > 0, spent != amount else { return 0 }
        let percent = Int((Double(spent - amount) / Double(amount) * 100).rounded())
        if percent == 0 { return spent > amount ? 1 : -1 }
        return percent
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

    /// 만기일이 지났는지 (만기일 당일까지는 진행 중)
    public func isExpired(at now: Date, calendar: Calendar = .current) -> Bool {
        calendar.startOfDay(for: now) > calendar.startOfDay(for: dueDate)
    }

    /// 끝난 예산의 결과 기록
    public func result(spent: Int, id: UUID) -> BudgetResult {
        BudgetResult(id: id, amount: amount, startDate: startDate, dueDate: dueDate, spent: spent)
    }

    /// 전체 기간(시작일~만기일) 중 남은 날의 비율 0…1 — 텅장방지 다이얼
    public func remainingPeriodRatio(from now: Date, calendar: Calendar = .current) -> Double {
        let total = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: startDate),
            to: calendar.startOfDay(for: dueDate)
        ).day ?? 0
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(daysRemaining(from: now, calendar: calendar)) / Double(total)))
    }

    /// 예산 금액을 바꾼다. 경고·위험 금액을 손대지 않았으면(기본 70·90%) 새 금액에 맞춰 다시 정한다
    public func withAmount(_ newAmount: Int) -> Budget {
        let untouched = self == .suggested(amount: amount, startDate: startDate, dueDate: dueDate)
            || (warnAmount == 0 && dangerAmount == 0)
        guard untouched else {
            var budget = self
            budget.amount = newAmount
            return budget
        }
        return .suggested(amount: newAmount, startDate: startDate, dueDate: dueDate)
    }
}

/// 텅장방지 단계 — 뒤로 갈수록 심각하다
public enum BudgetStatus: String, Hashable, Sendable, Comparable, CaseIterable {
    case safe
    case warning
    case danger
    /// 예산 금액을 넘음
    case exceeded

    public static func < (lhs: Self, rhs: Self) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }

    public var displayName: String {
        switch self {
        case .safe: "안전"
        case .warning: "경고"
        case .danger: "위험"
        case .exceeded: "초과"
        }
    }

    /// 선을 넘는 순간 한 번 띄우는 알림 문구
    public var alertMessage: String? {
        switch self {
        case .safe: nil
        case .warning: "경고 금액을 넘었어요. 지출에 주의해요"
        case .danger: "위험 금액에 도달했어요! 텅장 주의 🚨"
        case .exceeded: "예산을 넘었어요. 남은 기간은 아껴 써요"
        }
    }

    /// 이미 알린 단계보다 심각해졌을 때만 새로 알릴 단계를 돌려준다
    public func newAlert(since notified: BudgetStatus?) -> BudgetStatus? {
        guard self != .safe else { return nil }
        guard let notified else { return self }
        return self > notified ? self : nil
    }
}
