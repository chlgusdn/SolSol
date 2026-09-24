import SwiftUI

/// 카테고리 팔레트 6색. DB에는 `rawValue` 키로 저장한다
public enum SDCategoryColor: String, CaseIterable, Sendable {
    case red, amber, green, blue, purple, brand

    /// VoiceOver용 이름
    public var displayName: String {
        switch self {
        case .red: "빨강"
        case .amber: "노랑"
        case .green: "초록"
        case .blue: "파랑"
        case .purple: "보라"
        case .brand: "쏠쏠 초록"
        }
    }

    public var color: Color {
        switch self {
        case .red: DesignSystemAsset.categoryRed.swiftUIColor
        case .amber: DesignSystemAsset.categoryAmber.swiftUIColor
        case .green: DesignSystemAsset.categoryGreen.swiftUIColor
        case .blue: DesignSystemAsset.categoryBlue.swiftUIColor
        case .purple: DesignSystemAsset.categoryPurple.swiftUIColor
        case .brand: DesignSystemAsset.categoryBrand.swiftUIColor
        }
    }
}
