//
//  ImageManager.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.09.2021.
//


import UIKit

protocol ImageManager: AnyObject {
    
    typealias ImageManagerDelegate = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    var delegate: ImageManagerDelegate? { get set }
    
    func showDialogForWorkingWithImages(title: String)
}

final class ImageManagerImpl: ImageManager {
    
    // MARK: - Typealias
    
    typealias ImageManagerDelegate = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    // MARK: - Public Variables
    
    weak var delegate: ImageManagerDelegate?
    
    // MARK: - Private Variables
    
    private lazy var alertBuilder: AlertBuilder = AlertBuilderImpl()
    private lazy var permissionManager: PermissionsManager = PermissionsManagerImpl()
    private lazy var router: Router = RouterImpl(delegate: delegate)
    private lazy var fileManager: FileManagerFacade = FileManagerImpl()
    
    // MARK: - Init
    
    init(delegate: ImageManagerDelegate?) {
        self.delegate = delegate
        router.delegate = delegate
    }
    
    // MARK: - Public Methods
    
    func showDialogForWorkingWithImages(title: String) {
        let controller = buildDialogForWorkingWithImages(title: title)
        router.present(controller)
    }
    
    // MARK: - Private Methods
    
    private func buildDialogForWorkingWithImages(title: String) -> UIAlertController {
        
        alertBuilder.reset(preferred: .actionSheet)
        alertBuilder.addTitle(title)
        alertBuilder.addMessage("Выберите источник для фото")
        alertBuilder.addDefaultAction("Сделать фото", isPreferredAction: false) { [weak self] _ in
            guard let self = self else { return }
            
            self.permissionManager.fetchAccess(for: .camera) { result in
                switch result {
                case .success(_):
                    self.router.showImagePicker(from: .camera)
                    
                case .failure(let error):
                    switch error {
                    case .userDidNotGrantAccess(alertController: let alert):
                        self.router.present(alert)
                        
                    default:
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
        
        alertBuilder.addDefaultAction("Выбрать из библиотеки", isPreferredAction: false) { [weak self] _ in
            guard let self = self else { return }
            
            self.permissionManager.fetchAccess(for: .photoLibrary) { result in
                switch result {
                case .success(_):
                    self.router.showImagePicker(from: .photoLibrary)
                    
                case .failure(let error):
                    switch error {
                    case .userDidNotGrantAccess(alertController: let alert):
                        self.router.present(alert)
                        
                    default:
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
        
        #warning("TODO: Реализовать пункт меню для удаления фото")
//        switch fileManager.isExistAvatarImage() {
//        case .success(_):
//            alertBuilder.addDestructiveAction("Удалить фото", isPreferredAction: false) { [weak self] _ in
//
//            }
//
//        case .failure(_):
//            break
//        }
        
        alertBuilder.addCancelAction("Отмена", isPreferredAction: false, handler: nil)
        
        return alertBuilder.fetchAlert()
        
    }
    
}
