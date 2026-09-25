import Foundation
import Testing
@testable import Domain

struct CategoryTests {
    @Test func validatedName_trimsAndLimitsLength() {
        #expect(TransactionCategory.validatedName("  배달  ") == "배달")
        #expect(TransactionCategory.validatedName("12345678") == "12345678")
        #expect(TransactionCategory.validatedName("123456789") == nil)
        #expect(TransactionCategory.validatedName("   ") == nil)
    }

    @Test func validatedName_countsUnicodeScalarsLikeSQLite() {
        // 그래핌 3개지만 스칼라 9개 — SQLite length() 기준 8자 초과
        #expect(TransactionCategory.validatedName("👨‍👩‍👧‍👦배달") == nil)
        // 조합형(NFD) 한글 "배달"은 스칼라 5개
        #expect(TransactionCategory.validatedName("배달".decomposedStringWithCanonicalMapping) != nil)
        #expect(TransactionCategory.validatedName("🇰🇷🇰🇷🇰🇷🇰🇷") == "🇰🇷🇰🇷🇰🇷🇰🇷")
    }

    @Test func defaults_haveUniqueIdsAndOneIncomeCategory() {
        let all = TransactionCategory.Default.all
        #expect(Set(all.map(\.id)).count == all.count)
        #expect(all.filter { $0.type == .income } == [TransactionCategory.Default.income])
        #expect(TransactionCategory.Default.expenses.map(\.name) == ["식비", "카페", "교통", "쇼핑", "레저", "구독"])
    }
}

struct TransactionRuleTests {
    @Test func defaultTitle_dependsOnType() {
        #expect(Transaction.defaultTitle(for: .income) == "수익")
        #expect(Transaction.defaultTitle(for: .expense) == "지출")
    }
}

struct BudgetTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }()

    private func date(_ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2025, month: month, day: day, hour: hour))!
    }

    @Test func suggested_usesSeventyAndNinetyPercent() {
        let budget = Budget.suggested(amount: 1_000_000, startDate: date(1, 1), dueDate: date(1, 31))
        #expect(budget.warnAmount == 700_000)
        #expect(budget.dangerAmount == 900_000)
        #expect(budget.isValid)
    }

    @Test(arguments: [
        (0, 700_000, 900_000, Budget.ValidationError.nonPositiveAmount),
        (1_000_000, 900_000, 900_000, .invalidWarnAmount),
        (1_000_000, 0, 900_000, .invalidWarnAmount),
        (1_000_000, 700_000, 1_000_001, .dangerExceedsAmount)
    ])
    func validation_enforcesWarnBelowDangerWithinAmount(amount: Int, warn: Int, danger: Int, expected: Budget.ValidationError) {
        let budget = Budget(amount: amount, startDate: date(1, 1), dueDate: date(1, 31), warnAmount: warn, dangerAmount: danger)
        #expect(budget.validationError == expected)
    }

    @Test func validation_rejectsDueDateBeforeStart() {
        let budget = Budget.suggested(amount: 1_000, startDate: date(2, 1), dueDate: date(1, 1))
        #expect(budget.validationError == .dueDateBeforeStart)
    }

    @Test func status_changesAtWarnAndDangerAmounts() {
        let budget = Budget.suggested(amount: 1_000_000, startDate: date(1, 1), dueDate: date(1, 31))
        #expect(budget.status(spent: 699_999) == .safe)
        #expect(budget.status(spent: 700_000) == .warning)
        #expect(budget.status(spent: 899_999) == .warning)
        #expect(budget.status(spent: 900_000) == .danger)
        #expect(budget.status(spent: 1_000_000) == .danger)
        #expect(budget.status(spent: 1_000_001) == .exceeded)
        #expect(budget.usageRatio(spent: 500_000) == 0.5)
        #expect(budget.remaining(spent: 1_200_000) == -200_000)
    }

    @Test func period_includesWholeDueDate() {
        let budget = Budget.suggested(amount: 1_000, startDate: date(1, 10, hour: 15), dueDate: date(1, 31, hour: 9))
        let period = budget.period(calendar: calendar)
        #expect(period.start == calendar.date(from: DateComponents(year: 2025, month: 1, day: 10)))
        #expect(period.end == calendar.date(from: DateComponents(year: 2025, month: 2, day: 1)))
    }

    @Test func daysRemaining_countsCalendarDaysAndNeverNegative() {
        let budget = Budget.suggested(amount: 1_000, startDate: date(1, 1), dueDate: date(1, 31, hour: 1))
        #expect(budget.daysRemaining(from: date(1, 30, hour: 23), calendar: calendar) == 1)
        #expect(budget.daysRemaining(from: date(1, 31, hour: 23), calendar: calendar) == 0)
        #expect(budget.daysRemaining(from: date(2, 5), calendar: calendar) == 0)
    }

    @Test func isExpired_afterDueDateOnly() {
        let budget = Budget.suggested(amount: 1_000, startDate: date(1, 1), dueDate: date(1, 31, hour: 9))
        #expect(!budget.isExpired(at: date(1, 31, hour: 23), calendar: calendar))
        #expect(budget.isExpired(at: date(2, 1, hour: 0), calendar: calendar))
    }

    @Test func result_recordsSpentAndOverAmount() {
        let budget = Budget.suggested(amount: 1_000_000, startDate: date(1, 1), dueDate: date(1, 31))
        let over = budget.result(spent: 1_200_000, id: UUID())
        #expect(over.isExceeded)
        #expect(over.overAmount == 200_000)
        #expect(over.usageRatio == 1.2)
        let kept = budget.result(spent: 800_000, id: UUID())
        #expect(!kept.isExceeded)
        #expect(kept.overAmount == 0)
    }

    @Test func differencePercent_signedAndNeverZeroUnlessExact() {
        let budget = Budget.suggested(amount: 1_000_000, startDate: date(1, 1), dueDate: date(1, 31))
        #expect(budget.differencePercent(spent: 1_200_000) == 20)
        #expect(budget.differencePercent(spent: 850_000) == -15)
        #expect(budget.differencePercent(spent: 1_000_000) == 0)
        #expect(budget.differencePercent(spent: 1_001_000) == 1)
        #expect(budget.differencePercent(spent: 999_000) == -1)
        #expect(budget.result(spent: 1_200_000, id: UUID()).differencePercent == 20)
    }

    @Test func newAlert_onlyWhenMoreSevereThanNotified() {
        #expect(BudgetStatus.safe.newAlert(since: nil) == nil)
        #expect(BudgetStatus.warning.newAlert(since: nil) == .warning)
        #expect(BudgetStatus.warning.newAlert(since: .warning) == nil)
        #expect(BudgetStatus.danger.newAlert(since: .warning) == .danger)
        #expect(BudgetStatus.warning.newAlert(since: .danger) == nil)
        #expect(BudgetStatus.exceeded.newAlert(since: .danger) == .exceeded)
    }

    @Test func remainingPeriodRatio_fullAtStart_emptyAtDue() {
        let budget = Budget.suggested(amount: 1_000, startDate: date(1, 1), dueDate: date(1, 11))
        #expect(budget.remainingPeriodRatio(from: date(1, 1), calendar: calendar) == 1)
        #expect(budget.remainingPeriodRatio(from: date(1, 6), calendar: calendar) == 0.5)
        #expect(budget.remainingPeriodRatio(from: date(1, 11), calendar: calendar) == 0)
        #expect(budget.remainingPeriodRatio(from: date(2, 1), calendar: calendar) == 0)
        let sameDay = Budget.suggested(amount: 1_000, startDate: date(1, 1), dueDate: date(1, 1))
        #expect(sameDay.remainingPeriodRatio(from: date(1, 1), calendar: calendar) == 0)
    }

    @Test func withAmount_rescalesUntouchedThresholds_keepsCustomOnes() {
        let suggested = Budget.suggested(amount: 1_000_000, startDate: date(1, 1), dueDate: date(1, 31))
        let rescaled = suggested.withAmount(500_000)
        #expect(rescaled.warnAmount == 350_000)
        #expect(rescaled.dangerAmount == 450_000)

        var custom = suggested
        custom.warnAmount = 600_000
        let kept = custom.withAmount(2_000_000)
        #expect(kept.amount == 2_000_000)
        #expect(kept.warnAmount == 600_000)
        #expect(kept.dangerAmount == 900_000)
    }
}

struct FixedExpenseTests {
    @Test func enabledTotal_sumsOnlyCheckedItems() {
        let items = [
            FixedExpense(id: UUID(), name: "넷플릭스", amount: 13_500, isEnabled: true, sortOrder: 0),
            FixedExpense(id: UUID(), name: "유튜브 프리미엄", amount: 14_900, isEnabled: false, sortOrder: 1),
            FixedExpense(id: UUID(), name: "월세", amount: 500_000, isEnabled: true, sortOrder: 2)
        ]
        #expect(items.enabledTotal == 513_500)
        #expect(items.enabledCount == 2)
    }
}
