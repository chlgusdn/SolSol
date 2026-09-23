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
        for name in ["primary", "onPrimary", "income", "expense", "background", "surface", "textPrimary", "textSecondary", "separator"] {
            #expect(UIColor(named: name, in: .module, compatibleWith: nil) != nil, "\(name) missing")
        }
    }
}
