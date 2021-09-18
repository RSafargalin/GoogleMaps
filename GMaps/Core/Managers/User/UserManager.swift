//
//  UserManager.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation

protocol UserManager: AnyObject {
    
    func signIn(username: String, password: String) -> Result<User, UserManagerErrors>
    func signUp(username: String, password: String) -> Result<User, UserManagerErrors>
}

// MARK: - Enum

enum UserManagerErrors: Error {
    case wrongPassword,
         undefined(description: String),
         failedToSaveNewPassword
}

final class UserManagerImpl: UserManager {
    
    // MARK: - Private variables
    
    private let dataBaseManager: DataBaseManager = CoreDataManager()
    
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
    
}
