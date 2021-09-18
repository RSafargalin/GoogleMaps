//
//  DataBaseManager.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 24.08.2021.
//

import Foundation
import CoreData
import CoreLocation

protocol DataBaseManager: AnyObject {
 
    func fetchLastRouteCoordinate() -> [CLLocationCoordinate2D]
    func saveRoute(with coordinate: [CLLocationCoordinate2D]) throws
    
    func createUser(with username: String, and password: String) -> Result<User, DataBaseManagerErrors>
    func fetchUser(on username: String) -> Result<User, DataBaseManagerErrors>
    func edit(_ user: User, byChanging: UserAttributes) -> Bool
    
}

enum DataBaseManagerErrors: Error {
    case userNotFound,
         userExists,
         undefined(description: String)
}

enum UserAttributes {
    case login(on: String),
         password(on: String)
}

final class CoreDataManager: DataBaseManager {
    
    // MARK: - Private variables
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GMapsModels")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    // MARK: - Public methods
    
    func fetchLastRouteCoordinate() -> [CLLocationCoordinate2D] {
        let lastRoutePathsRequest: NSFetchRequest<RoutePath> = RoutePath.fetchRequest()
        guard let lastRoutePath = try? context.fetch(lastRoutePathsRequest).first,
              let coordinates = lastRoutePath.coordinates else { return [] }
        
        return coordinates
    }
    
    func saveRoute(with coordinate: [CLLocationCoordinate2D]) throws {
        try clear()
        
        let routePath: RoutePath = RoutePath(context: context)
        routePath.coordinates = coordinate
        
        try saveIfNeededOrRollbackOnException()
    }
    
    func createUser(with username: String, and password: String) -> Result<User, DataBaseManagerErrors> {
        switch fetchUser(on: username) {
        case .success:
            return .failure(.userExists)
            
        case .failure(let error):
            switch error {
            case .userNotFound:
                let newUser = User(context: context)
                newUser.login = username
                newUser.password = password
                do {
                    try saveIfNeededOrRollbackOnException()
                    return .success(newUser)
                } catch {
                    return .failure(.undefined(description: error.localizedDescription))
                }
                
            default:
                return .failure(.undefined(description: error.localizedDescription))
            }
        }
    }
    
    func fetchUser(on username: String) -> Result<User, DataBaseManagerErrors> {
        let requestForConcreteUser: NSFetchRequest<User> = User.fetchRequest()
        requestForConcreteUser.predicate = .for(username: username)
        do {
            guard let user = try context.fetch(requestForConcreteUser).first else { return .failure(.userNotFound) }
            return .success(user)
        } catch {
            print(error)
            return .failure(.undefined(description: error.localizedDescription))
        }
    }
    
    func edit(_ user: User, byChanging: UserAttributes) -> Bool {
        
        switch byChanging {
        case .login(on: let newLogin):
            user.login = newLogin
            
        case .password(on: let newPassword):
            user.password = newPassword
        }
        
        guard let _ = try? saveIfNeededOrRollbackOnException() else { return false }
        return true
    }
    
    // MARK: - Private methods
    
    private func saveIfNeededOrRollbackOnException() throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    private func clear() throws {
        let lastRouteRequest: NSFetchRequest<RoutePath> = RoutePath.fetchRequest()
        guard let routePaths = try? context.fetch(lastRouteRequest) else { return }
        routePaths.forEach { routePath in
            context.delete(routePath)
        }
    
        try saveIfNeededOrRollbackOnException()
    }
    
}
