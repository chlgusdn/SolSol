import ComposableArchitecture
import DesignSystem
import HomeFeature
import OnboardingFeature
import SwiftUI
import TransactionEditorFeature

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        // Group은 수정자를 조건부 자식마다 붙여 화면이 바뀔 때마다 onAppear가 다시 실행된다 — 안정적인 컨테이너에 붙인다
        ZStack {
            if store.isCheckingOnboarding {
                DesignSystemAsset.background.swiftUIColor.ignoresSafeArea()
            } else if let onboardingStore = store.scope(state: \.onboarding, action: \.onboarding) {
                OnboardingView(store: onboardingStore)
                    .transition(.opacity)
            } else {
                main
                    .transition(.opacity)
            }
        }
        .animation(.sd.standard, value: store.onboarding == nil)
        .tint(DesignSystemAsset.primary.swiftUIColor)
        .onAppear { store.send(.onAppear) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { store.send(.scenePhaseBecameActive) }
        }
    }

    private var main: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            HomeView(store: store.scope(state: \.home, action: \.home))
        } destination: { store in
            switch store.case {
            case let .transactionEditor(store):
                TransactionEditorView(store: store)
            case let .comingSoon(store):
                ComingSoonView(store: store)
            }
        }
        .sheet(item: $store.scope(state: \.destination?.transactionEditor, action: \.destination.transactionEditor)) { store in
            NavigationStack {
                TransactionEditorView(store: store)
            }
            .presentationDetents([.large])
        }
    }
}
