import SwiftUI

extension Animation {
    public static let sd = SDAnimation()
}

/// 애니메이션 토큰
public struct SDAnimation: Sendable {
    public let quick: Animation = .snappy(duration: 0.2)
    public let standard: Animation = .smooth(duration: 0.3)
    public let bouncy: Animation = .bouncy(duration: 0.4)
}

/// 눌림 효과 배율 토큰
public enum SDScale {
    public static let pressed: CGFloat = 0.97
}
