import Core
import DesignSystem
import SwiftUI

struct IncomeLine: View {
    let income: Int

    var body: some View {
        Text("수입 \(Text(income.signedWonFormatted).foregroundStyle(DesignSystemAsset.income.swiftUIColor))")
            .font(.sd.caption)
            .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
    }
}
