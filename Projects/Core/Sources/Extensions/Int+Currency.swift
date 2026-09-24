import Foundation

extension Int {
    /// "12,000원" 형식
    public var wonFormatted: String {
        "\(formatted(.number.grouping(.automatic)))원"
    }

    /// "+12,000원" / "-12,000원" 형식
    public var signedWonFormatted: String {
        let sign = self > 0 ? "+" : (self < 0 ? "-" : "")
        return "\(sign)\(Swift.abs(self).wonFormatted)"
    }

    /// "5천" / "1.2만" / "125만" — 캘린더 칸처럼 좁은 곳
    public var compactFormatted: String {
        formatted(.number.notation(.compactName).locale(Locale(identifier: "ko_KR")))
    }
}
