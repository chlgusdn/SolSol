import ComposableArchitecture
import DesignSystem
import HomeFeature
import SwiftUI
import TransactionEditorFeature

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            HomeView(store: store.scope(state: \.home, action: \.home))
        } destination: { store in
            switch store.case {
            case let .transactionEditor(store):
                TransactionEditorView(store: store)
            }
        }
        .sheet(item: $store.scope(state: \.destination?.transactionEditor, action: \.destination.transactionEditor)) { store in
            NavigationStack {
                TransactionEditorView(store: store)
            }
            .presentationDetents([.large])
        }
        .tint(DesignSystemAsset.primary.swiftUIColor)
        .onAppear { store.send(.onAppear) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { store.send(.scenePhaseBecameActive) }
        }
    }
}
