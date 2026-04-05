public protocol HomeDependencyProviding: AnyObject {
    func makeHomeViewModel() -> HomeViewModel
    func makeHomeExpenseSummaryViewModel() -> HomeExpenseSummaryViewModel
    func makeHomeExpenseChartViewModel() -> HomeExpenseChartViewModel
}
