import DesignSystem
import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: SDSpacing.xxl) {
            illustration
                .accessibilityHidden(true)
            VStack(spacing: SDSpacing.s) {
                Text(page.title)
                    .font(.sd.displayHeadline)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
                    .accessibilityAddTraits(.isHeader)
                Text(page.message)
                    .font(.sd.body)
                    .foregroundStyle(DesignSystemAsset.textSecondary.swiftUIColor)
                    .lineSpacing(SDSpacing.xs)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, SDSpacing.huge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var illustration: some View {
        switch page {
        case .welcome: LogoIllustration()
        case .calendar: CalendarIllustration()
        case .statistics: ChartIllustration()
        case .budget: BudgetIllustration()
        }
    }
}
