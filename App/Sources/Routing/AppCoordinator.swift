//
//  AppCoordinator.swift
//  SolSol
//
//  Created by NUNU:D on 8/31/25.
//

import UIKit
import SolSolCore
import HomePresentation

/// 글로벌 코디네이터 { 글로벌한 화면이동이 필요한경우 }
public final class AppCoordinator: Coordinator {
    
    public var navigationController: UINavigationController
    
    public var childCoordinators: [any Coordinator] = []
    
    public var parentCoordinator: (any Coordinator)? = nil
    
    public func start() {
        Log.d("\(self) Start")
        let homeCoordinator = HomeCoordinator(
            navigationController: self.navigationController,
            dependencies: AppContainer.shared
        )
        homeCoordinator.parentCoordinator = self
        self.childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
    
    public init(window: UIWindow) {
        self.navigationController = UINavigationController()
        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
    }
}
