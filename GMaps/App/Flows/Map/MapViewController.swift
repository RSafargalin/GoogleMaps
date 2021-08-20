//
//  MapViewController.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 18.08.2021.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation

final class MapViewController: UIViewController {
    
    // MARK: - Private variables
    
    private lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private var locationManager: CLLocationManager?
    private var markers = [GMSMarker]()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopFetchingUserLocationUpdate()
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        self.title = "Map"
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setup() {
        configureUI()
        configureLocationManager()
        requestAuthorizationIfNeeded()
        startFetchingUserLocationUpdate()
    }
    
    private func setCameraPosition(coordinate: CLLocationCoordinate2D, zoom: Float = 17.0) {
        let camera = GMSCameraPosition(latitude: coordinate.latitude,
                                       longitude: coordinate.longitude,
                                       zoom: zoom)
        mapView.camera = camera
    }
    
    private func setMarkerOnMap(for coordinate: CLLocationCoordinate2D) {
        let newMarker = GMSMarker(position: coordinate)
        newMarker.map = mapView
        
        markers.append(newMarker)
    }
    
    private func clearMap() {
        removeMarkers()
    }
    
    private func removeMarkers() {
        markers.forEach { marker in
            marker.map = nil
        }
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    private func requestAuthorizationIfNeeded() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func startFetchingUserLocationUpdate() {
        locationManager?.startUpdatingLocation()
    }
    
    private func stopFetchingUserLocationUpdate() {
        locationManager?.stopUpdatingLocation()
    }
}

// MARK: - MapViewController + CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentCoordinate = locations.first?.coordinate else { return }
        setCameraPosition(coordinate: currentCoordinate)
        setMarkerOnMap(for: currentCoordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
