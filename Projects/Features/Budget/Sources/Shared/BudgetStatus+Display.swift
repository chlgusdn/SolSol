import DesignSystem
import Domain
import SwiftUI

extension BudgetStatus {
    var message: String {
        switch self {
        case .safe: "아직 예산에 여유가 있어요 👍"
        case .warning: "경고 금액을 넘었어요. 지출에 주의해요"
        case .danger: "위험 금액에 도달했어요! 텅장 주의 🚨"
        case .exceeded: "남은 기간은 지출을 멈춰 보아요"
        }
    }

    /// 고채도 `danger`는 위험·초과 단계에만 쓴다 (DESIGN.md 텅장방지 단계)
    var color: Color {
        switch self {
        case .safe: DesignSystemAsset.primary.swiftUIColor
        case .warning: DesignSystemAsset.warning.swiftUIColor
        case .danger, .exceeded: DesignSystemAsset.danger.swiftUIColor
        }
    }

    var icon: SDIcon {
        switch self {
        case .safe: .budget
        case .warning: .info
        case .danger, .exceeded: .alert
        }
    }
}
