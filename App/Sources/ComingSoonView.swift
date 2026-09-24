import ComposableArchitecture
import DesignSystem
import SwiftUI

struct ComingSoonView: View {
    let store: StoreOf<ComingSoonFeature>

    var body: some View {
        SDEmptyState(icon: .info, title: "준비 중인 화면이에요", message: "곧 만나볼 수 있어요")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sdScreen()
            .navigationTitle(store.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ComingSoonView(store: Store(initialState: ComingSoonFeature.State(title: "통계")) {
            ComingSoonFeature()
        })
    }
}
