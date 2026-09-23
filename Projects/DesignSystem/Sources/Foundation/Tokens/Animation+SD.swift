import SwiftUI

extension Animation {
    public static let sd = SDAnimation()
}

/// 애니메이션 토큰
public struct SDAnimation: Sendable {
    /// 눌림, 선택
    public let quick: Animation = .snappy(duration: 0.2)
    /// 시트·토스트 등장(fadeUp), 금액 변화
    public let standard: Animation = .easeOut(duration: 0.25)
    /// 금액 상한 초과 흔들림
    public let shake: Animation = .linear(duration: 0.5)
}

/// 시간 토큰
public enum SDDuration {
    /// 토스트 자동 소멸
    public static let toast: Duration = .milliseconds(2200)
    /// 저장 토스트 후 화면 이동 지연
    public static let saveToNavigate: Duration = .milliseconds(650)
}

/// 눌림 효과 배율
public enum SDScale {
    public static let pressed: CGFloat = 0.97
}
