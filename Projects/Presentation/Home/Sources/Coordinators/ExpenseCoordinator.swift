//
//  ExpenseCoordinator.swift
//  SolSol
//
//  Created by NUNU:D on 12/27/25.
//

import Foundation
import UIKit
import SolSolCore

final class ExpenseCoordinator: Coordinator {

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
        self.navigationController.isNavigationBarHidden = true
        self.navigationController.pushViewController(homeViewController, animated: true)
    }

    init(navigationController: UINavigationController, dependencies: HomeDependencyProviding) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
}
