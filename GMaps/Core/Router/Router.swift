//
//  Router.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 28.08.2021.
//

import Foundation
import UIKit

protocol Router: NSObject {
    
    var delegate: UIViewController? { get set }
    
    func show(_ controller: UIViewController) 
    
    func popToPrevious()
    
    func popToRoot()
    
    func setAsRoot(_ controller: UIViewController)
        
    func present(_ controller: UIViewController)
    
}

final class RouterImpl: NSObject, Router {
    
    weak var delegate: UIViewController?
    
    required init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    func show(_ controller: UIViewController) {
        guard let delegate = delegate else { return }
        delegate.show(controller, sender: nil)
    }
    
    
    func popToPrevious() {
        guard let delegate = delegate else { return }
        delegate.navigationController?.popViewController(animated: true)
    }
    
    func popToRoot() {
        guard let delegate = delegate else { return }
        delegate.navigationController?.popToRootViewController(animated: true)
    }
    
    func setAsRoot(_ controller: UIViewController) {
        UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.rootViewController = controller
    }
        
    func present(_ controller: UIViewController) {
        guard let delegate = delegate else { return }
        delegate.present(controller, animated: true, completion: nil)
    }

}