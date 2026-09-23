import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !store.isLastPage {
                    Button("건너뛰기") { store.send(.skipButtonTapped) }
                        .buttonStyle(.sdText)
                        .transition(.opacity)
                }
            }
            .frame(height: SDSize.touchTarget)
            .padding(.horizontal, SDSpacing.l)

            TabView(selection: $store.page) {
                ForEach(OnboardingPage.allCases, id: \.self) { page in
                    OnboardingPageView(page: page)
                        .tag(page)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: SDSpacing.xl) {
                SDPageIndicator(
                    count: OnboardingPage.allCases.count,
                    current: Binding(
                        get: { store.page.rawValue },
                        set: { store.page = OnboardingPage(rawValue: $0) ?? store.page }
                    )
                )
                Button(store.isLastPage ? "이제부터 시작!" : "다음") {
                    store.send(store.isLastPage ? .startButtonTapped : .nextButtonTapped)
                }
                .buttonStyle(.sdPrimary)
                .disabled(store.isCompleting)
                .sensoryFeedback(.impact(weight: .medium), trigger: store.isCompleting) { _, new in new }
            }
            .padding(.horizontal, SDSpacing.page)
            .padding(.bottom, SDSpacing.xxl)
        }
        .animation(.sd.standard, value: store.page)
        .sensoryFeedback(.selection, trigger: store.page)
        .sdScreen()
    }
}

// MARK: - 슬라이드

private struct OnboardingPageView: View {
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

/// 일러스트 크기 (프로토타입 기준)
private enum IllustrationSize {
    static let square: CGFloat = 150
    static let card: CGFloat = 190
}

private struct LogoIllustration: View {
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

private struct CalendarIllustration: View {
    /// 0: 수입, 1: 지출, 2: 기록 없음 (프로토타입의 21칸 패턴)
    private let pattern = [2, 0, 2, 2, 1, 2, 0, 2, 1, 2, 0, 2, 2, 1, 0, 2, 1, 2, 2, 0, 2]

    var body: some View {
        VStack(spacing: SDSpacing.s) {
            Text("2025년 1월")
                .font(.sd.displayCaption)
                .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: SDSpacing.xs), count: 7), spacing: SDSpacing.xs) {
                ForEach(Array(pattern.enumerated()), id: \.offset) { _, kind in
                    Circle()
                        .fill(color(for: kind))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .sdCard(.floating, radius: SDRadius.l)
        .frame(width: IllustrationSize.card)
    }

    private func color(for kind: Int) -> Color {
        switch kind {
        case 0: DesignSystemAsset.income.swiftUIColor
        case 1: DesignSystemAsset.expense.swiftUIColor
        default: DesignSystemAsset.border.swiftUIColor
        }
    }
}

private struct ChartIllustration: View {
    /// (막대 높이, 수입 여부)
    private let bars: [(height: CGFloat, isIncome: Bool)] = [(38, true), (72, false), (52, true), (90, false)]

    var body: some View {
        HStack(alignment: .bottom, spacing: SDSpacing.s) {
            ForEach(Array(bars.enumerated()), id: \.offset) { _, bar in
                let color = bar.isIncome
                    ? DesignSystemAsset.chartIncome.swiftUIColor
                    : DesignSystemAsset.chartExpense.swiftUIColor
                RoundedRectangle(cornerRadius: SDRadius.xs)
                    .fill(color)
                    .frame(width: SDSize.iconS, height: bar.height)
                    .sdShadow(.glow(color))
            }
        }
        .frame(width: IllustrationSize.card, height: IllustrationSize.square, alignment: .bottom)
        .padding(.bottom, SDSpacing.xxl)
        .frame(width: IllustrationSize.card, height: IllustrationSize.square)
        .background(
            RoundedRectangle(cornerRadius: SDRadius.l)
                .fill(DesignSystemAsset.surface.swiftUIColor)
                .sdShadow(.floating)
        )
    }
}

private struct BudgetIllustration: View {
    var body: some View {
        SDProgressRing(progress: 0.7) {
            VStack(spacing: SDSpacing.xxs) {
                Text("만기까지")
                    .font(.sd.caption)
                    .foregroundStyle(DesignSystemAsset.textTertiary.swiftUIColor)
                Text("67일")
                    .font(.sd.displayHeadline)
                    .foregroundStyle(DesignSystemAsset.textPrimary.swiftUIColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Circle().fill(DesignSystemAsset.surface.swiftUIColor))
        }
        .frame(width: IllustrationSize.square, height: IllustrationSize.square)
    }
}

#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }
    )
}

#Preview("마지막 장") {
    var state = OnboardingFeature.State()
    state.page = .budget
    return OnboardingView(store: Store(initialState: state) { OnboardingFeature() })
}
