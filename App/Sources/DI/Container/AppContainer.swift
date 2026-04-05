import Factory
import HomePresentation

public enum AppContainer {
    public static let shared = Container.shared
}

extension Container: HomeDependencyProviding {
    public func makeHomeViewModel() -> HomeViewModel {
        self.homeViewModel()
    }

    public func makeHomeExpenseSummaryViewModel() -> HomeExpenseSummaryViewModel {
        self.homeExpenseSummaryViewModel()
    }

    public func makeHomeExpenseChartViewModel() -> HomeExpenseChartViewModel {
        self.homeExpenseChartViewModel()
    }
}
