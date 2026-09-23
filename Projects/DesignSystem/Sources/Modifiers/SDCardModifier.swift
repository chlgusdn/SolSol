import SwiftUI

struct SDCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(SDSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: SDRadius.l)
                    .fill(DesignSystemAsset.surface.swiftUIColor)
            )
    }
}

struct SDScreenModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignSystemAsset.background.swiftUIColor.ignoresSafeArea())
    }
}

extension View {
    /// 카드 형태 컨테이너
    public func sdCard() -> some View {
        modifier(SDCardModifier())
    }

    /// 화면 공통 배경
    public func sdScreen() -> some View {
        modifier(SDScreenModifier())
    }
}

#Preview {
    VStack {
        Text("카드").sdCard()
    }
    .padding()
    .sdScreen()
}
