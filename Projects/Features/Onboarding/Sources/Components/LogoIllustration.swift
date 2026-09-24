import DesignSystem
import SwiftUI

struct LogoIllustration: View {
    var body: some View {
        Text("쏠쏠")
            .font(.sd.displayHero)
            .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
            .frame(width: IllustrationSize.square, height: IllustrationSize.square)
            .background(
                RoundedRectangle(cornerRadius: SDRadius.drawer)
                    .fill(DesignSystemAsset.surface.swiftUIColor)
                    .sdShadow(.floating)
            )
    }
}
