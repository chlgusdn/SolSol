import Testing
import UIKit
@testable import DesignSystem

struct DesignSystemTests {
    @Test func customFonts_areRegistered() {
        _ = SDFont.shared
        for font in DesignSystemFontFamily.allCustomFonts {
            #expect(UIFont(name: font.name, size: 12) != nil, "\(font.name) not registered")
        }
    }

    @Test func colorAssets_existInBundle() {
        let names = [
            "primary", "cta", "income", "expense", "danger", "warning",
            "background", "surface", "surfaceDark", "textPrimary", "textSecondary", "textTertiary", "border", "onPrimary",
            "chartIncome", "chartExpense", "calendarSunday", "calendarSaturday",
            "categoryRed", "categoryAmber", "categoryGreen", "categoryBlue", "categoryPurple", "categoryBrand"
        ]
        for name in names {
            #expect(UIColor(named: name, in: .module, compatibleWith: nil) != nil, "\(name) missing")
        }
    }
}
