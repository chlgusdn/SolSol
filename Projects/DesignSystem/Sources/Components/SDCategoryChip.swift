import SwiftUI

/// 카테고리 칩 — 색 점 + 라벨. 선택 시 색 테두리와 연한 배경
public struct SDCategoryChip: View {
    private let title: String
    private let color: SDCategoryColor
    private let isSelected: Bool
    private let action: () -> Void

    public init(_ title: String, color: SDCategoryColor, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: SDSpacing.xs) {
                Circle()
                    .fill(color.color)
                    .frame(width: SDSpacing.s, height: SDSpacing.s)
                Text(title)
                    .font(.sd.callout)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            }
            .padding(.horizontal, SDSpacing.m)
            .padding(.vertical, SDSpacing.s)
            .background(
                Capsule().fill(isSelected ? color.color.opacity(SDOpacity.tint) : DesignSystemAsset.surface.swiftUIColor)
            )
            .overlay(
                Capsule().stroke(
                    isSelected ? color.color : DesignSystemAsset.border.swiftUIColor,
                    lineWidth: isSelected ? SDSize.borderThick : SDSize.borderThin
                )
            )
            .frame(minHeight: SDSize.touchTarget)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack(spacing: SDSpacing.s) {
        SDCategoryChip("식비", color: .red, isSelected: true) {}
        SDCategoryChip("카페", color: .amber, isSelected: false) {}
        SDCategoryChip("교통", color: .blue, isSelected: false) {}
    }
    .padding()
    .sdScreen()
}
