import Testing
@testable import Core

struct CurrencyFormatTests {
    @Test func signedWonFormatted_addsSign() {
        #expect(0.signedWonFormatted == "0원")
        #expect(1_000.signedWonFormatted.hasPrefix("+"))
        #expect((-1_000).signedWonFormatted.hasPrefix("-"))
    }
}
