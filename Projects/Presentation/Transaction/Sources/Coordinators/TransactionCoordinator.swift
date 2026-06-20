//
//  TransactionCoordinator.swift
//  TransactionPresentation
//
//  Created by Codex on 6/20/26.
//

import UIKit
import SolSolCore

public final class TransactionCoordinator: Coordinator {

    public var navigationController: UINavigationController
    public var childCoordinators: [any Coordinator] = []
    public weak var parentCoordinator: (any Coordinator)?

    private let dependencies: TransactionDependencyProviding
    private let initialType: TransactionInputType

    public init(
        navigationController: UINavigationController,
        dependencies: TransactionDependencyProviding,
        initialType: TransactionInputType
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.initialType = initialType
    }

    public func start() {
        let viewController = TransactionInputVC(
            viewModel: dependencies.makeTransactionInputViewModel(initialType: initialType)
        )
        viewController.coordinator = self
        navigationController.isNavigationBarHidden = true
        navigationController.pushViewController(viewController, animated: true)
        enableSwipeBack()
    }

    func closeInput(animated: Bool = true) {
        navigationController.isNavigationBarHidden = true
        navigationController.popToRootViewController(animated: animated)
        finish()
    }

    private func enableSwipeBack() {
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
}
