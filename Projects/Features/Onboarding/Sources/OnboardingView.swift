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
