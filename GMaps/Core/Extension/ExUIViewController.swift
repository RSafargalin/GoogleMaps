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
        let controller = MapViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabBarController.setViewControllers([navigationController], animated: false)
        return tabBarController
    }
    
    static func login() -> UINavigationController {
        let controller = LoginViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
    
}
