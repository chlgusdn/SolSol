import CoreGraphics

/// 모서리 라운드 토큰
public enum SDRadius {
    /// 칩, 태그, 차트 막대
    public static let xs: CGFloat = 4
    /// CTA 버튼, 리스트 행, 입력 필드
    public static let s: CGFloat = 8
    /// 일반 카드, 토스트
    public static let m: CGFloat = 12
    /// 메인 카드 (요약, 캘린더)
    public static let l: CGFloat = 16
    /// 바텀시트 상단
    public static let sheet: CGFloat = 24
    /// 통계 화이트 시트 상단
    public static let drawer: CGFloat = 28
    public static let pill: CGFloat = 999
}
