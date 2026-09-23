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
}
