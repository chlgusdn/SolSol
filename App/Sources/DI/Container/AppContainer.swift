import Factory
import HomePresentation
import TransactionPresentation

public enum AppContainer {
    public static let shared = Container.shared
}

extension Container: @retroactive HomeDependencyProviding {
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

extension Container: @retroactive TransactionDependencyProviding {
    public func makeTransactionInputViewModel(initialType: TransactionInputType) -> TransactionInputViewModel {
        TransactionInputViewModel(initialType: initialType)
    }
}
