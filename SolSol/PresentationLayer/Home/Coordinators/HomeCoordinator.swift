//
//  HomeCoordinator.swift
//  SolSol
//
//  Created by NUNU:D on 9/1/25.
//

import UIKit

/// 홈 화면 코디네이터
public final class HomeCoordinator: Coordinator {
    
    public var navigationController: UINavigationController
    
    public var childCoordinators: [any Coordinator] = []
    
    public weak var parentCoordinator: (any Coordinator)?
    
    public func start() {
        Log.d("\(self) Start")
        // main 화면 이동
        let homeViewController = HomeViewController()
        self.navigationController.isNavigationBarHidden = true
        self.navigationController.pushViewController(homeViewController, animated: true)
    }
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
