//
//  LocationManager.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 25.08.2021.
//

import Foundation
import CoreLocation
import GoogleMaps
import RxCocoa

final class LocationManager: NSObject {
    
    static let instance = LocationManager()
    
    // MARK: - Init
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    // MARK: - Private variables
    
    private let alertBuilder: AlertBuilder = AlertBuilderImpl()
    
    // MARK: - Public variables
    
    let locationManager = CLLocationManager()
    let location: BehaviorRelay<CLLocation?> = .init(value: nil)
    
    // MARK: - Public methods
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func requestAuthorizationIfNeeded(for controller: UIViewController) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            
        case .authorizedAlways:
            break
            
        case .denied, .restricted:
            let alertController = buildWarningAboutNoAccessToGeolocationServices()
            controller.present(alertController, animated: true, completion: nil)
            
        @unknown default:
            break
            // TODO: Обработать правильно
        }
    }
    
    // MARK: - Private methods
    
    private func buildWarningAboutNoAccessToGeolocationServices() -> UIAlertController {
        alertBuilder.reset(preferred: .actionSheet)
        alertBuilder.addTitle("Geolocation service warning")
        alertBuilder.addMessage("The app does not have access to geolocation services. Without them, you will not be able to take full advantage of the application. Go to settings to allow access to geolocation services.")
        alertBuilder.addDefaultAction("Settings",
                                      isPreferredAction: true) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertBuilder.addDestructiveAction("Cancel", isPreferredAction: false, handler: nil)
        
        let alertController = alertBuilder.fetchAlert()
        return alertController
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location.accept(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - Refactoring
// TODO: Переписать методы
/*
 #warning("TODO: Вынести в LocationManager")
 private func setCameraPosition(coordinate: CLLocationCoordinate2D, zoom: Float = 17.0, animated: Bool = false) {
     let camera = GMSCameraPosition(latitude: coordinate.latitude,
                                    longitude: coordinate.longitude,
                                    zoom: zoom)
     guard animated else {
         contentView.mapView.camera = camera
         return
     }
     contentView.mapView.animate(to: camera)
 }
 
 #warning("TODO: Вынести в LocationManager")
 private func setMarkerOnMap(for coordinate: CLLocationCoordinate2D) {
     let newMarker = GMSMarker(position: coordinate)
     newMarker.map = contentView.mapView
     
     markers.append(newMarker)
 }
 
 #warning("TODO: Вынести в LocationManager")
 private func clearMap() {
     removeMarkers()
 }
 
 #warning("TODO: Вынести в LocationManager")
 private func removeMarkers() {
     markers.forEach { marker in
         marker.map = nil
     }
 }
 */
