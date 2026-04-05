//
//  Coordinator.swift
//  SolSol
//
//  Created by NUNU:D on 8/31/25.
//

import UIKit

/// 베이스 코디네이터 프로토콜
public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    var parentCoordinator: Coordinator? { get set }
    
    func start()
}

public extension Coordinator {
    
    func finish() {
        self.childCoordinators.removeAll()
        self.childCoordinatorDidFinish(with: self)
    }
    
    func childCoordinatorDidFinish(with coordinator: Coordinator) {
        self.childCoordinators.removeAll { $0 === coordinator }
    }
}
