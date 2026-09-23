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

    @Test func categoryColor_roundTripsRawValue() {
        for color in SDCategoryColor.allCases {
            #expect(SDCategoryColor(rawValue: color.rawValue) == color)
        }
    }

    @Test func designTokens_matchDesignDocument() {
        #expect(SDSize.ctaHeight == 54)
        #expect(SDSize.touchTarget == 44)
        #expect(SDRadius.sheet == 24)
        #expect(SDSpacing.page == 24)
        #expect(SDOpacity.disabled == 0.45)
    }

    @Test(arguments: [
        ("primary", 0x13AD5C),
        ("expense", 0xE5484D),
        ("danger", 0xDC1010),
        ("background", 0xF9F9F9),
        ("surfaceDark", 0x1C1C1E)
    ])
    func colorAssets_matchDesignDocument(name: String, hex: Int) throws {
        let color = try #require(UIColor(named: name, in: .module, compatibleWith: nil))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let actual = (Int((red * 255).rounded()) << 16) | (Int((green * 255).rounded()) << 8) | Int((blue * 255).rounded())
        #expect(actual == hex, "\(name): \(String(actual, radix: 16))")
    }

    @Test func icon_initByKey_fallsBackToTag() {
        #expect(SDIcon(key: "food") == .food)
        #expect(SDIcon(key: "repeat") == .repeat)
        #expect(SDIcon(key: "unknown") == .tag)
    }

    @Test func icons_resolveToSystemSymbols() {
        for icon in SDIcon.allCases {
            #expect(UIImage(systemName: icon.systemName) != nil, "\(icon.systemName) missing")
        }
    }
}
