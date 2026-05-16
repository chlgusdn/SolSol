//
//  SceneDelegate.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import UIKit
import SolSolCore
import Kronos

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        self.appCoordinator = AppCoordinator(window: window)

        Task {
            await Clock.synchronize()

            await DependencyBootstrapper.bootstrap()

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
