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
import CoreData

final class MapViewController: UIViewController {
    
    // MARK: - Private variables
    
    private lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    #warning("TODO: Рефакторинг")
    private var markers = [GMSMarker]()
    private var coordinates = [CLLocationCoordinate2D]()
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    
    private var isTrackingUpdatingLocation: Bool = false {
        willSet {
            setTrackingButtonState(for: newValue)
        }
    }
    
    private lazy var locationManager: LocationManager = LocationManagerImpl(delegate: self)
    private let dataBaseManager: DataBaseManager = CoreDataManager()
    private let alertBuilder: AlertBuilder = AlertBuilderImpl()
    
    private var previousRouteCoordinates: [CLLocationCoordinate2D] = [] {
        willSet {
            previousRouteButton.isEnabled = !newValue.isEmpty
        }
    }
    
    private lazy var trackingButton = UIBarButtonItem(title: "Start tracking",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(onStartTrackingButtonDidTap(_:)))
    
    private lazy var previousRouteButton = UIBarButtonItem(title: "Show last route",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(onShowPreviousRouteButtonDidTap(_:)))

    
    @objc private func onStartTrackingButtonDidTap(_ sender: UIBarButtonItem) {
        startFetchingUserLocationUpdate()
    }
    
    @objc private func onStopTrackingButtonDidTap(_ sender: UIBarButtonItem) {
        stopFetchingUserLocationUpdate()
    }
    
    @objc private func onShowPreviousRouteButtonDidTap(_ sender: UIBarButtonItem) {
        if isTrackingUpdatingLocation {
            let alertController = buildActiveTrackingAlert()
            present(alertController, animated: true, completion: nil)
        } else {
            showPreviousRouteIfTrackingIsOff()
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopFetchingUserLocationUpdate()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.unbindDelegate()
        
    }
    
    // MARK: - Private methods
    
    #warning("TODO: Вынести в отдельную View")
    private func configureUI() {
        self.title = "Map"
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)

        trackingButton.tintColor = .systemBlue
        self.navigationItem.leftBarButtonItem = trackingButton
        self.navigationItem.rightBarButtonItem = previousRouteButton
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setup() {
        configureUI()
        locationManager.configure()
        locationManager.requestAuthorizationIfNeeded()
        locationManager.startMonitoringSignificantLocationChanges()
        
        previousRouteCoordinates = dataBaseManager.fetchLastRouteCoordinate()
    }
    
    #warning("TODO: Вынести в LocationManager")
    private func setCameraPosition(coordinate: CLLocationCoordinate2D, zoom: Float = 17.0, animated: Bool = false) {
        let camera = GMSCameraPosition(latitude: coordinate.latitude,
                                       longitude: coordinate.longitude,
                                       zoom: zoom)
        guard animated else {
            mapView.camera = camera
            return
        }
        mapView.animate(to: camera)
    }
    
    #warning("TODO: Вынести в LocationManager")
    private func setMarkerOnMap(for coordinate: CLLocationCoordinate2D) {
        let newMarker = GMSMarker(position: coordinate)
        newMarker.map = mapView
        
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
    
    #warning("TODO: Рефакторинг")
    private func startFetchingUserLocationUpdate() {
        isTrackingUpdatingLocation = true
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager.startUpdatingLocation()
    }
    
    private func stopFetchingUserLocationUpdate() {
        isTrackingUpdatingLocation = false
        locationManager.stopUpdatingLocation()
        coordinates = fetchCoordinates(from: routePath)
        
        do {
            try dataBaseManager.saveRoute(with: coordinates)
        } catch {
            print(error)
        }
    }
    
    #warning("TODO: Вынести в LocationManager")
    private func fetchCoordinates(from routePath: GMSMutablePath?) -> [CLLocationCoordinate2D] {
        guard let routePath = routePath else { return [] }
        
        let routesCount = routePath.count()
        var coordinates: [CLLocationCoordinate2D] = []
        
        for index in 0...routesCount {
            let coordinate = routePath.coordinate(at: index)
            guard CLLocationCoordinate2DIsValid(coordinate) else { continue }
            coordinates.append(coordinate)
        }
        return coordinates
    }
    
    #warning("TODO: Вынести в LocationManager")
    #warning("TODO: Рефакторинг")
    private func showPreviousRouteIfTrackingIsOff() {
        guard !isTrackingUpdatingLocation else { return }
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        previousRouteCoordinates.forEach { routePath?.add($0) }
        route?.path = routePath
        let firstCoord = previousRouteCoordinates.first ?? CLLocationCoordinate2D()
        let lastCoord = previousRouteCoordinates.last ?? CLLocationCoordinate2D()
        let bounds = GMSCoordinateBounds(coordinate: firstCoord, coordinate: lastCoord)
        let camera = mapView.camera(for: bounds,
                                    insets: UIEdgeInsets(top: 50,
                                                         left: 50,
                                                         bottom: 50,
                                                         right: 50)) ?? GMSCameraPosition()
        mapView.camera = camera
    }
    
    #warning("TODO: Вынести в AlertDirector")
    private func buildActiveTrackingAlert() -> UIAlertController {
        let title = "Warning!"
        let message = "You are tracking location updates.\nWhen you click \"Ok\", the current route will be discarded"
        alertBuilder.reset(preferred: .alert)
        alertBuilder.addTitle(title)
        alertBuilder.addMessage(message)
        alertBuilder.addDestructiveAction("Ok", isPreferredAction: false) { [weak self] _ in
            self?.isTrackingUpdatingLocation = false
            self?.locationManager.stopUpdatingLocation()
            self?.showPreviousRouteIfTrackingIsOff()
        }
        alertBuilder.addCancelAction("Cancel", isPreferredAction: true, handler: nil)
        let alertController = alertBuilder.fetchAlert()
        return alertController
    }
    
    private func setTrackingButtonState(for state: Bool) {
        switch state {
        case true:
            trackingButton.tintColor = .systemRed
            trackingButton.title = "Stop tracking"
            trackingButton.action = #selector(onStopTrackingButtonDidTap(_:))
            
        case false:
            trackingButton.tintColor = .systemBlue
            trackingButton.title = "Start tracking"
            trackingButton.action = #selector(onStartTrackingButtonDidTap(_:))
        }
    }
}

// MARK: - MapViewController + CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard isTrackingUpdatingLocation,
              let currentCoordinate = locations.first?.coordinate
        else { return }
        setCameraPosition(coordinate: currentCoordinate, animated: true)
        routePath?.add(currentCoordinate)
        route?.path = routePath
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
