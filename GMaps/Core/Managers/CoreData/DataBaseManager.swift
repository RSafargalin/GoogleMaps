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
    
}

final class CoreDataManager: DataBaseManager {
    
    // MARK: - Private variables
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Route")
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
