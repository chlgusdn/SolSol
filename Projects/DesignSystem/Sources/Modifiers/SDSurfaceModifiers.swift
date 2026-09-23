import SwiftUI

struct SDCardModifier: ViewModifier {
    let shadow: SDShadow
    let radius: CGFloat
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(DesignSystemAsset.surface.swiftUIColor)
                    .sdShadow(shadow)
            )
    }
}

extension View {
    /// 카드 컨테이너 — `surface` 배경 + 그림자
    public func sdCard(
        _ shadow: SDShadow = .card,
        radius: CGFloat = SDRadius.l,
        padding: CGFloat = SDSpacing.l
    ) -> some View {
        modifier(SDCardModifier(shadow: shadow, radius: radius, padding: padding))
    }

    /// 화면 공통 배경
    public func sdScreen() -> some View {
        background(DesignSystemAsset.background.swiftUIColor.ignoresSafeArea())
    }
}

#Preview {
    VStack(spacing: SDSpacing.cardGap) {
        Text("일반 카드").font(.sd.body).sdCard()
        Text("떠 있는 카드").font(.sd.body).sdCard(.floating)
    }
    .padding(SDSpacing.page)
    .frame(maxHeight: .infinity)
    .sdScreen()
}
