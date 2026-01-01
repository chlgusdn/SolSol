//
//  ExpenseCoordinator.swift
//  SolSol
//
//  Created by NUNU:D on 12/27/25.
//

import Foundation
import UIKit

final class ExpenseCoordinator: Coordinator {
    
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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
