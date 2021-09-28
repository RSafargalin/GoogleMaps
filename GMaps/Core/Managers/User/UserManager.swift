//
//  UserManager.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit

protocol UserManager: AnyObject {
    
    func signIn(username: String, password: String) -> Result<User, UserManagerErrors>
    func signUp(username: String, password: String) -> Result<User, UserManagerErrors>
    
    func fetchAvatar() -> UIImage
    
    @discardableResult
    func saveAvatar(image: UIImage) -> Result<Bool, UserManagerErrors>
}

// MARK: - Enum

enum UserManagerErrors: Error {
    case wrongPassword,
         undefined(description: String),
         failedToSaveNewPassword,
         failedToSaveUserAvatar
}

final class UserManagerImpl: UserManager {
    
    // MARK: - Private variables
    
    private let dataBaseManager: DataBaseManager = CoreDataManager()
    private lazy var fileManager: FileManagerFacade = FileManagerImpl()
    
    private let userAvatarTitle: String = "avatar"
     
    // MARK: - Public methods
    
    func signIn(username: String, password: String) -> Result<User, UserManagerErrors> {
        
        switch dataBaseManager.fetchUser(on: username) {
        case .success(let user):
            if user.password != password { return .failure(.wrongPassword) }
            return .success(user)
            
        case .failure(let error):
            return .failure(.undefined(description: error.localizedDescription))
        }
        
    }
    
    func signUp(username: String, password: String) -> Result<User, UserManagerErrors> {
        
        switch dataBaseManager.fetchUser(on: username) {
        case .success(let user):
            guard dataBaseManager.edit(user, byChanging: .password(on: password))
            else { return .failure(.failedToSaveNewPassword) }
            return .success(user)
            
        case .failure(let error):
            switch error {
            case .userNotFound:
                switch dataBaseManager.createUser(with: username, and: password) {
                case .success(let user):
                    return .success(user)
                    
                case .failure(let error):
                    return .failure(.undefined(description: error.localizedDescription))
                }
                
            default:
                return .failure(.undefined(description: error.localizedDescription))
            }
        }
    }
    
    func fetchAvatar() -> UIImage {
        switch fileManager.fetch(image: userAvatarTitle, directory: .documents, folder: .images) {
        case .success(let image):
            return image
            
        case .failure:
            let placeholderImage = UIImage(systemName: "questionmark.square.dashed") ?? UIImage()
            switch fileManager.fetch(image: userAvatarTitle, directory: .documents, folder: .none) {
            case .success(let image):
                fileManager.replace(image: userAvatarTitle, image: image, directory: .documents, folder: .images)
                return image
                
            case .failure:
                return placeholderImage
            }
        }
    }
    
    @discardableResult
    func saveAvatar(image: UIImage) -> Result<Bool, UserManagerErrors> {
        switch fileManager.replace(image: userAvatarTitle, image: image, directory: .documents, folder: .images) {
        case .success(let result):
            return .success(result)
            
        case .failure:
            return .failure(.failedToSaveUserAvatar)
        }
    }
    
}
