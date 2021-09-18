//
//  SceneDelegate.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 18.08.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Public variables
    
    var window: UIWindow?

    // MARK: - Private variables
    
    private var visualEffectView: UIVisualEffectView? = nil
    private let curtainViewTag: Int = 1
    
    // MARK: - Public methods

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        window.rootViewController = .login()
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let controller = self.window?.rootViewController {
            removeCurtainIfNeeded(from: controller)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        addCurtainIfNeeded()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func addCurtainIfNeeded() {
        
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            
            guard let lastController = navigationController.children.last else { return }
            
            removeCurtainIfNeeded(from: lastController)
            
            if visualEffectView == nil {
                visualEffectView = fetchBlurView(for: curtainViewTag, frame: UIScreen.main.bounds)
            }
            
            guard let curtainView = visualEffectView else { return }
            
            lastController.view.insertSubview(curtainView, at: lastController.view.subviews.count)
            
        } else if let controller = self.window?.rootViewController {
            
            removeCurtainIfNeeded(from: controller)
            
            if visualEffectView == nil {
                visualEffectView = fetchBlurView(for: curtainViewTag, frame: UIScreen.main.bounds)
            }
            
            guard let curtainView = visualEffectView else { return }
            
            controller.view.insertSubview(curtainView, at: controller.view.subviews.count)
        
        }
    }
    
    private func removeCurtainIfNeeded(from controller: UIViewController) {
       
        
        if let navigationController = controller as? UINavigationController {
            
            guard let lastController = navigationController.children.last else { return }
            
            if let curtainView = lastController.view.subviews.first(where: {$0.tag == curtainViewTag}){
                curtainView.removeFromSuperview()
                visualEffectView = nil
            }
            
        } else {
            
            if let curtainView = controller.view.subviews.first(where: {$0.tag == curtainViewTag}){
                curtainView.removeFromSuperview()
                visualEffectView = nil
            }
        
        }
    }
    
    private func fetchBlurView(for tag: Int, frame size: CGRect) -> UIVisualEffectView {
        let blurView = UIVisualEffectView(frame: size)
        blurView.effect = UIBlurEffect(style: .light)
        blurView.tag = tag
        return blurView
    }

}

