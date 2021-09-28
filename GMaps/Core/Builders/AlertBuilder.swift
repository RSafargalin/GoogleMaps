//
//  AlertBuilder.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 24.08.2021.
//

import Foundation
import UIKit

protocol AlertBuilder: AnyObject {
    
    func reset(preferred style: UIAlertController.Style)
    func addTitle(_ text: String)
    func addMessage(_ text: String)
    func addDefaultAction(_ title: String, isPreferredAction: Bool, handler: ((UIAlertAction) -> Void)?)
    func addCancelAction(_ title: String, isPreferredAction: Bool, handler: ((UIAlertAction) -> Void)?)
    func addDestructiveAction(_ title: String, isPreferredAction: Bool, handler: ((UIAlertAction) -> Void)?)
    func fetchAlert() -> UIAlertController
}

class AlertBuilderImpl: AlertBuilder {
    
    private var alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
    
    func reset(preferred style: UIAlertController.Style) {
        alert = UIAlertController(title: "", message: "", preferredStyle: style)
    }
    
    func addTitle(_ text: String) {
        alert.title = text
    }
    
    func addMessage(_ text: String) {
        alert.message = text
    }
    
    func addDefaultAction(_ title: String, isPreferredAction: Bool = false, handler: ((UIAlertAction) -> Void)?) {
        let action = addAction(title, style: .default, handler: handler)
        if isPreferredAction {
            alert.preferredAction = action
        }
    }
    
    func addCancelAction(_ title: String, isPreferredAction: Bool = false, handler: ((UIAlertAction) -> Void)?) {
        let action = addAction(title, style: .cancel, handler: handler)
        if isPreferredAction {
            alert.preferredAction = action
        }
    }
    
    func addDestructiveAction(_ title: String, isPreferredAction: Bool = false, handler: ((UIAlertAction) -> Void)?) {
        let action = addAction(title, style: .destructive, handler: handler)
        if isPreferredAction {
            alert.preferredAction = action
        }
    }
    
    func fetchAlert() -> UIAlertController {
        return alert
    }
    
    @discardableResult
    private func addAction(_ title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        alert.addAction(action)
        return action
    }
    
}

protocol AlertDirector: AnyObject {
    
    func update(builder: AlertBuilder)
    func buildAlertOfNeedGrantedAccess(for type: PermissionType) -> Result<UIAlertController, DirectorErrors>
    
}

enum DirectorErrors: Error {
    case builderNotFound
}

class AlertDirectorImpl: AlertDirector {
    
    private var builder: AlertBuilder?
    
    func update(builder: AlertBuilder) {
        self.builder = builder
    }
    
    init(builder: AlertBuilder) {
        self.builder = builder
    }
    
    
    
    func buildAlertController() {
        
    }
    
    func buildAlertOfNeedGrantedAccess(for type: PermissionType) -> Result<UIAlertController, DirectorErrors> {
        guard let builder = builder else { return .failure(.builderNotFound)}
        builder.reset(preferred: .actionSheet)
        var title = ""
        var message = ""
        switch type {
        case .camera:
            title = "Доступ к камере"
            message = "Чтобы включить доступ к камере, пожалуйста, перейдите в настройки."
            
        case .photoLibrary:
            title = "Доступ к фото"
            message = "Чтобы включить доступ к фотоальбому, пожалуйста, перейдите в настройки."
        }
        
        let settingsTitle = "Настройки"
        let cancelTitle = "Отмена"
        builder.addTitle(title)
        builder.addMessage(message)
        builder.addDefaultAction(settingsTitle, isPreferredAction: true) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        builder.addDestructiveAction(cancelTitle, isPreferredAction: false, handler: nil)
        
        return .success(builder.fetchAlert())
    }
    
}
