import Testing
@testable import Domain

struct AmountInputTests {
    @Test func digits_accumulate_andDeleteRemovesLastDigit() {
        #expect(AmountInput.apply(.digit(1), to: 0) == .updated(1))
        #expect(AmountInput.apply(.digit(2), to: 1) == .updated(12))
        #expect(AmountInput.apply(.doubleZero, to: 12) == .updated(1_200))
        #expect(AmountInput.apply(.delete, to: 1_200) == .updated(120))
        #expect(AmountInput.apply(.delete, to: 0) == .updated(0))
    }

    @Test func leadingZeros_stayZero() {
        #expect(AmountInput.apply(.digit(0), to: 0) == .updated(0))
        #expect(AmountInput.apply(.doubleZero, to: 0) == .updated(0))
    }

    @Test func overMaxAmount_isRejected() {
        #expect(AmountInput.apply(.digit(0), to: 100_000_000) == .updated(Transaction.maxAmount))
        #expect(AmountInput.apply(.digit(1), to: 100_000_000) == .overLimit)
        #expect(AmountInput.apply(.doubleZero, to: 100_000_000) == .overLimit)
        #expect(AmountInput.apply(.digit(0), to: Transaction.maxAmount) == .overLimit)
    }
}
