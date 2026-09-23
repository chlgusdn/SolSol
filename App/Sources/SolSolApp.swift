import ComposableArchitecture
import Data
import Domain
import SwiftUI

@main
struct SolSolApp: App {
    @MainActor static let store = Store(
        initialState: {
            @Dependency(\.date.now) var now
            return AppFeature.State(month: .month(containing: now))
        }()
    ) {
        AppFeature()
    }

    init() {
        if !isTesting {
            prepareDependencies {
                $0.bootstrapLive(database: try! appDatabase())
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if !isTesting {
                AppView(store: Self.store)
            }
        }
    }
}
