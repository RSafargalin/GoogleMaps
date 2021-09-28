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
import RxSwift

final class MapViewController: UIViewController {
    
    // MARK: - Private variables
    
    private var markers = [GMSMarker]()
    private var coordinates = [CLLocationCoordinate2D]()
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private let disposeBag = DisposeBag()
    private var userLastMarker: GMSMarker? = nil
    
    private var isTrackingUpdatingLocation: Bool = false {
        willSet {
            setTrackingButtonState(for: newValue)
        }
    }
    
    private var contentView: MapView {
        return transformView(to: MapView.self)
    }
    
    private let userManager: UserManager = UserManagerImpl()
    private let locationManager: LocationManager = LocationManager.instance
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
    
    override func loadView() {
        view = MapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    deinit {
        stopFetchingUserLocationUpdate()
    }
    
    // MARK: - Private methods
    
    private func setup() {
        
        self.title = "Map"
        
        trackingButton.tintColor = .systemBlue
        self.navigationItem.leftBarButtonItem = trackingButton
        self.navigationItem.rightBarButtonItem = previousRouteButton
        locationManager.requestAuthorizationIfNeeded(for: self)
        
        previousRouteCoordinates = dataBaseManager.fetchLastRouteCoordinate()
     
        locationManager.location
                       .asObservable()
                       .bind { [weak self] location in
                            guard let location = location else { return }
                            self?.routePath?.add(location.coordinate)
                            self?.route?.path = self?.routePath
                            self?.updateUserMarkerOnMap(for: location.coordinate)
                            self?.setCameraPosition(coordinate: location.coordinate)
                       }
                       .disposed(by: disposeBag)
    }
    
    private func startFetchingUserLocationUpdate() {
        isTrackingUpdatingLocation = true
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = contentView.mapView
        locationManager.startUpdatingLocation()
    }
    
    private func stopFetchingUserLocationUpdate() {
        isTrackingUpdatingLocation = false
        locationManager.stopUpdatingLocation()
        coordinates = fetchCoordinates(from: routePath)
        
        do {
            try dataBaseManager.saveRoute(with: coordinates)
            previousRouteCoordinates = coordinates
        } catch {
            print(error)
        }
    }
    
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
    
    private func showPreviousRouteIfTrackingIsOff() {
        guard !isTrackingUpdatingLocation else { return }
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = contentView.mapView
        previousRouteCoordinates.forEach { routePath?.add($0) }
        route?.path = routePath
        let firstCoord = previousRouteCoordinates.first ?? CLLocationCoordinate2D()
        let lastCoord = previousRouteCoordinates.last ?? CLLocationCoordinate2D()
        let bounds = GMSCoordinateBounds(coordinate: firstCoord, coordinate: lastCoord)
        let camera = contentView.mapView.camera(for: bounds,
                                    insets: UIEdgeInsets(top: 50,
                                                         left: 50,
                                                         bottom: 50,
                                                         right: 50)) ?? GMSCameraPosition()
        contentView.mapView.camera = camera
    }
    
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
    
    private func updateUserMarkerOnMap(for coordinate: CLLocationCoordinate2D) {
        userLastMarker?.map = nil
        let newMarker = GMSMarker(position: coordinate)
        newMarker.map = contentView.mapView
        let userAvatar = userManager.fetchAvatar()
        let markerView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        markerView.layer.masksToBounds = true
        markerView.layer.cornerRadius = 25
        
        
        markerView.image = userAvatar
        markerView.tintColor = .blue
        newMarker.iconView = markerView
        userLastMarker = newMarker
    }
}
