import Foundation

/// 거래 카테고리. 기본 카테고리는 마이그레이션에서 고정 id로 생성되고, 사용자는 지출 카테고리를 추가할 수 있다
public struct TransactionCategory: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var type: TransactionType
    public var name: String
    /// DesignSystem `SDCategoryColor`의 rawValue (`red`, `amber`, `green`, `blue`, `purple`, `brand`)
    public var colorKey: String
    /// DesignSystem `SDIcon`의 case 이름 (`food`, `cafe`, `tag` …)
    public var iconKey: String
    public var isDefault: Bool
    public var sortOrder: Int

    public init(
        id: UUID,
        type: TransactionType,
        name: String,
        colorKey: String,
        iconKey: String = TransactionCategory.customIconKey,
        isDefault: Bool = false,
        sortOrder: Int
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.colorKey = colorKey
        self.iconKey = iconKey
        self.isDefault = isDefault
        self.sortOrder = sortOrder
    }

    /// 카테고리 이름 최대 글자 수
    public static let nameLimit = 8
    /// 사용자 카테고리 아이콘
    public static let customIconKey = "tag"

    /// 앞뒤 공백을 제거하고 1…`nameLimit`자면 이름을, 아니면 nil을 돌려준다.
    /// 글자 수는 DB `length()`와 같게 유니코드 스칼라 개수로 센다 (이모지 조합·조합형 한글은 여러 개로 셈)
    public static func validatedName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...nameLimit).contains(trimmed.unicodeScalars.count) else { return nil }
        return trimmed
    }
}

// MARK: - 기본 카테고리

extension TransactionCategory {
    /// 마이그레이션 `v2`가 생성하는 기본 카테고리 (id 고정)
    public enum Default {
        public static let income = TransactionCategory(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!,
            type: .income, name: "수입", colorKey: "brand", iconKey: "money", isDefault: true, sortOrder: 0
        )
        public static let food = expense(1, "식비", color: "red", icon: "food")
        public static let cafe = expense(2, "카페", color: "amber", icon: "cafe")
        public static let transport = expense(3, "교통", color: "green", icon: "transport")
        public static let shopping = expense(4, "쇼핑", color: "purple", icon: "shopping")
        public static let leisure = expense(5, "레저", color: "blue", icon: "leisure")
        public static let subscription = expense(6, "구독", color: "blue", icon: "repeat")

        public static let expenses: [TransactionCategory] = [food, cafe, transport, shopping, leisure, subscription]
        public static let all: [TransactionCategory] = [income] + expenses

        private static func expense(_ order: Int, _ name: String, color: String, icon: String) -> TransactionCategory {
            TransactionCategory(
                id: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", 200 + order))!,
                type: .expense, name: name, colorKey: color, iconKey: icon, isDefault: true, sortOrder: order
            )
        }
    }
}
