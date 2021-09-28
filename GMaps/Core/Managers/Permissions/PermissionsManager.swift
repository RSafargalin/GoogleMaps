//
//  PermissionsManager.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 28.09.2021.
//

import Foundation
import UIKit
import AVFoundation
import Photos

protocol PermissionsManager: AnyObject {
    func checkPermission(for type: PermissionType) -> Bool
    func requestPermission(for type: PermissionType, completion handler: @escaping ((Bool) -> Void))
    func showAlertOfNeedGrantedAccess(for type: PermissionType, presentFrom viewController: UIViewController)
    func fetchAccess(for type: PermissionType, completion handler: @escaping (Result<Bool, PermissionErrors>) -> Void)
}

enum PermissionType {
    case camera,
         photoLibrary
}

enum PermissionErrors: Error {
    case userDidNotGrantAccess(alertController: UIAlertController),
         undefinedError
}

class PermissionsManagerImpl: PermissionsManager {
    
    private let alertDirector: AlertDirector

    init() {
        let builder: AlertBuilder = AlertBuilderImpl()
        alertDirector = AlertDirectorImpl(builder: builder)
    }
    
    func checkPermission(for type: PermissionType) -> Bool {
        
        switch type {
        case .camera:
            return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        case .photoLibrary:
            let photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
            return photoLibraryStatus == .authorized || photoLibraryStatus == .limited
        }
        
    }
    
    func requestPermission(for type: PermissionType, completion handler: @escaping ((Bool) -> Void)) {
        switch type {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { isAccessGranted in
                handler(isAccessGranted)
            }
            
        case .photoLibrary:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized, .limited:
                    handler(true)
                    
                case .denied, .notDetermined, .restricted:
                    handler(false)
                    
                
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    func showAlertOfNeedGrantedAccess(for type: PermissionType, presentFrom viewController: UIViewController) {
        let result = alertDirector.buildAlertOfNeedGrantedAccess(for: type)
        
        switch result {
        case .success(let alertController):
            DispatchQueue.main.async {
                viewController.present(alertController, animated: true, completion: nil)
            }
        
        default:
            break
        }
    }
    
    func fetchAccess(for type: PermissionType, completion handler: @escaping (Result<Bool, PermissionErrors>) -> Void) {
        
        guard !checkPermission(for: type) else {
            return handler(.success(true))
        }
        
        requestPermission(for: type) { isGranted in
            guard !isGranted else {
                return handler(.success(true))
            }
           
            DispatchQueue.main.async {
                guard let alert = try? self.alertDirector.buildAlertOfNeedGrantedAccess(for: type)
                                                         .get()
                else {
                    return handler(.failure(.undefinedError))
                }
                return handler(.failure(.userDidNotGrantAccess(alertController: alert)))
            }
        }
    }
    
    
}
