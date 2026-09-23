import SwiftUI

extension Font {
    public static var sd: SDFont { SDFont.shared }
}

/// 폰트 토큰 — Dynamic Type에 맞춰 크기가 조정된다
public struct SDFont: Sendable {
    static let shared: SDFont = {
        DesignSystemFontFamily.registerAllCustomFonts()
        return SDFont()
    }()

    private static let rounded = DesignSystemFontFamily.머니그라피Ttf.rounded.name

    public let largeTitle = Font.custom(rounded, size: 32, relativeTo: .largeTitle)
    public let title = Font.custom(rounded, size: 24, relativeTo: .title)
    public let bodyBold = Font.custom(rounded, size: 17, relativeTo: .body).weight(.bold)
    public let body = Font.custom(rounded, size: 17, relativeTo: .body)
    public let caption = Font.custom(rounded, size: 13, relativeTo: .caption)
}

#Preview {
    VStack(alignment: .leading, spacing: SDSpacing.s) {
        Text("Large Title 12,000원").font(.sd.largeTitle)
        Text("Title 12,000원").font(.sd.title)
        Text("Body Bold 12,000원").font(.sd.bodyBold)
        Text("Body 12,000원").font(.sd.body)
        Text("Caption 12,000원").font(.sd.caption)
    }
    .padding()
}
