//
//  SceneDelegate.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import UIKit
import Factory

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        self.appCoordinator = AppCoordinator(window: window!)
        
        Task {
            // 데이터 베이스 초기화
            await Container.initalizeSQLAccess()
            
            // 데이터 베이스 초기화가 끝나면 화면 이동
            await MainActor.run { [weak self] in
                self?.appCoordinator?.start()
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}

}

