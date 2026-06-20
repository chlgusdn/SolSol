//
//  AppCoordinator.swift
//  SolSol
//
//  Created by NUNU:D on 8/31/25.
//

import UIKit
import SolSolCore
import HomePresentation
import TransactionPresentation

/// 글로벌 코디네이터 { 글로벌한 화면이동이 필요한경우 }
public final class AppCoordinator: Coordinator {

    public var navigationController: UINavigationController

    public var childCoordinators: [any Coordinator] = []

    public var parentCoordinator: (any Coordinator)?

    public func start() {
        Log.d("\(self) Start")
        let homeCoordinator = HomeCoordinator(
            navigationController: self.navigationController,
            dependencies: AppContainer.shared
        )
        homeCoordinator.parentCoordinator = self
        homeCoordinator.delegate = self
        self.childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }

    public init(window: UIWindow) {
        self.navigationController = UINavigationController()
        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
    }
}

extension AppCoordinator: HomeCoordinatorDelegate {

    public func homeCoordinator(
        _ coordinator: HomeCoordinator,
        didRequestTransactionInput type: HomeTransactionInputType
    ) {
        let transactionType: TransactionInputType

        switch type {
        case .income:
            transactionType = .income
        case .expense:
            transactionType = .expense
        }

        let transactionCoordinator = TransactionCoordinator(
            navigationController: navigationController,
            dependencies: AppContainer.shared,
            initialType: transactionType
        )
        transactionCoordinator.parentCoordinator = self
        childCoordinators.append(transactionCoordinator)
        transactionCoordinator.start()
    }
}
