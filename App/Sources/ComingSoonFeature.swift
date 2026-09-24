import ComposableArchitecture

/// 아직 만들지 않은 화면의 자리 — 해당 Feature를 만들면 `AppFeature.Path`에서 교체한다
@Reducer
struct ComingSoonFeature {
    @ObservableState
    struct State: Equatable {
        var title: String
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
