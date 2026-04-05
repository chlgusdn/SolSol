//
//  HomeCoordinator.swift
//  SolSol
//
//  Created by NUNU:D on 9/1/25.
//

import UIKit
import SolSolCore

/// 홈 화면 코디네이터
public final class HomeCoordinator: Coordinator {
    
    public var navigationController: UINavigationController
    
    public var childCoordinators: [any Coordinator] = []
    
    public weak var parentCoordinator: (any Coordinator)?

    private let dependencies: HomeDependencyProviding
    
    public func start() {
        Log.d("\(self) Start")
        // main 화면 이동
        let homeViewController = HomeViewController(
            viewModel: self.dependencies.makeHomeViewModel(),
            summaryViewModel: self.dependencies.makeHomeExpenseSummaryViewModel(),
            chartViewModel: self.dependencies.makeHomeExpenseChartViewModel()
        )
        homeViewController.coordinator = self
        self.navigationController.isNavigationBarHidden = true
        self.navigationController.pushViewController(homeViewController, animated: true)
    }
    
    public func showExpenseScreen() {
        let expenseCoordinator = ExpenseCoordinator(
            navigationController: self.navigationController,
            dependencies: self.dependencies
        )
        expenseCoordinator.parentCoordinator = self
        self.childCoordinators.append(expenseCoordinator)
        expenseCoordinator.start()
    }

    public init(navigationController: UINavigationController, dependencies: HomeDependencyProviding) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
}
