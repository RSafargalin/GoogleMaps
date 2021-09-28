//
//  ExUIViewController.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit

extension UIViewController {
    
    func transformView<ViewType: UIView>(to type: ViewType.Type) -> ViewType {
        guard let view = self.view as? ViewType else {
            fatalError("It was not possible to bring the view type to the required one. Initializer called.")
        }
        
        return view
    }
    
    static func map() -> UITabBarController {
        let mapViewController = MapViewController()
        mapViewController.title = "Map"
        mapViewController.tabBarItem.image = UIImage(systemName: "map")
        let mapNavigationController = UINavigationController(rootViewController: mapViewController)
        
        let profileViewController = ProfileViewController()
        profileViewController.title = "Profile"
        profileViewController.tabBarItem.image = UIImage(systemName: "person")
        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
        
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabBarController.setViewControllers([mapNavigationController, profileNavigationController], animated: false)
        return tabBarController
    }
    
    static func login() -> UINavigationController {
        let controller = LoginViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
    
}
