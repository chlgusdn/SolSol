import SwiftUI

/// 그림자 토큰
public struct SDShadow: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    /// 일반 카드
    public static let card = SDShadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 2)
    /// 캘린더 카드, 떠 있는 요소
    public static let floating = SDShadow(color: .black.opacity(0.09), radius: 19, x: 2, y: 16)

    /// 차트 선·막대 글로우
    public static func glow(_ color: Color) -> SDShadow {
        SDShadow(color: color.opacity(0.4), radius: 18, x: 0, y: 9)
    }
}

extension View {
    public func sdShadow(_ shadow: SDShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius / 2, x: shadow.x, y: shadow.y)
    }
}
