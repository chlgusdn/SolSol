import SwiftUI

/// 디자인 아이콘(Lucide 스타일) → SF Symbol 매핑. `Image(systemName:)`을 직접 쓰지 않는다.
public enum SDIcon: String, CaseIterable, Sendable {
    case back = "chevron.left"
    case chevronRight = "chevron.right"
    case plus = "plus"
    case close = "xmark"
    case check = "checkmark"
    case calendar = "calendar"
    case barChart = "chart.bar"
    case trendingUp = "chart.line.uptrend.xyaxis"
    case pieChart = "chart.pie"
    case settings = "gearshape"
    case tag = "tag"
    case clock = "clock"
    case money = "wonsign"
    case info = "info.circle"
    case alert = "exclamationmark.triangle"
    case budget = "shield.lefthalf.filled"
    case `repeat` = "arrow.clockwise"
    case receipt = "list.bullet.rectangle"
    case deleteBackward = "delete.backward"
    // 카테고리
    case food = "fork.knife"
    case cafe = "cup.and.saucer"
    case transport = "bus"
    case shopping = "bag"
    case leisure = "figure.walk"

    /// Domain에 저장된 아이콘 키(case 이름)로 찾는다. 모르는 키는 `.tag`
    public init(key: String) {
        self = Self.allCases.first { "\($0)" == key } ?? .tag
    }

    public var systemName: String { rawValue }
    public var image: Image { Image(systemName: rawValue) }
}

#Preview {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: SDSpacing.l) {
        ForEach(SDIcon.allCases, id: \.self) { icon in
            icon.image
                .font(.system(size: SDSize.iconL))
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
        }
    }
    .padding()
}
