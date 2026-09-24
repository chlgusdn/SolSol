import Foundation

/// 키패드 금액 입력 — 원 단위 정수를 한 자리씩 쌓는다
public enum AmountInput {
    public enum Key: Hashable, Sendable {
        case digit(Int)
        case doubleZero
        case delete
    }

    public enum Result: Equatable, Sendable {
        case updated(Int)
        /// `Transaction.maxAmount`를 넘어 입력을 거부했다
        case overLimit
    }

    public static func apply(_ key: Key, to amount: Int) -> Result {
        let next: Int
        switch key {
        case let .digit(digit):
            next = amount * 10 + digit
        case .doubleZero:
            next = amount * 100
        case .delete:
            return .updated(amount / 10)
        }
        // 곱셈 전에 상한을 넘으면 오버플로 없이 거부된다 (maxAmount × 100 < Int.max)
        return next > Transaction.maxAmount ? .overLimit : .updated(next)
    }
}
