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
