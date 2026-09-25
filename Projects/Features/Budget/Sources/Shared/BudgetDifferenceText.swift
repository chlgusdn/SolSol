import Foundation

/// 예산 대비 결과 문구 — 금액보다 비율이 예산 크기와 상관없이 비교하기 쉽다
enum BudgetDifferenceText {
    /// "예산보다 20% 더 썼어요" / "예산보다 15% 아꼈어요" / "예산을 딱 맞게 썼어요"
    static func phrase(_ percent: Int) -> String {
        switch percent {
        case 1...: "예산보다 \(percent)% 더 썼어요"
        case ..<0: "예산보다 \(-percent)% 아꼈어요"
        default: "예산을 딱 맞게 썼어요"
        }
    }

    static func emoji(_ percent: Int) -> String {
        switch percent {
        case 1...: "😞"
        case ..<0: "👏"
        default: "👍"
        }
    }
}
