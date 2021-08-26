//
//  LocationManager.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 25.08.2021.
//

import Foundation
import CoreLocation
import GoogleMaps

protocol LocationManager: AnyObject {
    
    func requestAuthorizationIfNeeded()
    func unbindDelegate()
    func configure()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()
    
}

final class LocationManagerImpl: LocationManager {
    
    typealias LocationManagerDelegate = (UIViewController & CLLocationManagerDelegate)
    
    // MARK: - Private variables
    
    #warning("TODO: Удалить, если не будет необходимости")
    private weak var delegate: LocationManagerDelegate?
    
    private var locationManager: CLLocationManager
    private let alertBuilder: AlertBuilder = AlertBuilderImpl()
    
    private var route: GMSPolyline
    private var routePath: GMSMutablePath
    
    private var markers: [GMSMarker] = [GMSMarker]()
    private var coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
    // MARK: - Init
    
    init(delegate: LocationManagerDelegate) {
        
        #warning("TODO: Удалить, если не будет необходимости")
        self.delegate = delegate
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = delegate
        self.route = GMSPolyline()
        self.routePath = GMSMutablePath()
    }

    // MARK: - Public methods
    
    public func requestAuthorizationIfNeeded() {
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
            delegate?.present(alertController, animated: true, completion: nil)
            
        @unknown default:
            break
            // TODO: Обработать правильно
        }
    }
    
    public func unbindDelegate() {
        self.delegate = nil
        self.locationManager.delegate = nil
    }
    
    public func configure() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    public func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    public func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
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
    
}
