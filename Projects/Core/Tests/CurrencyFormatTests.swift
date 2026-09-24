import Testing
@testable import Core

struct CurrencyFormatTests {
    @Test func signedWonFormatted_addsSign() {
        #expect(0.signedWonFormatted == "0원")
        #expect(1_000.signedWonFormatted.hasPrefix("+"))
        #expect((-1_000).signedWonFormatted.hasPrefix("-"))
    }

    @Test func compactFormatted_usesKoreanUnits() {
        #expect(800.compactFormatted == "800")
        #expect(5_000.compactFormatted == "5천")
        #expect(12_000.compactFormatted == "1.2만")
        #expect(1_250_000.compactFormatted == "125만")
    }
}
