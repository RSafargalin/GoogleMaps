//
//  NotificationCenterFacade.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 23.09.2021.
//

import Foundation
import UserNotifications

final class NotificationCenterFacade {
    
    static let shared: NotificationCenterFacade = NotificationCenterFacade()
    
    private init() {}
    
    // MARK: - Private variables
    
    private let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Public methods
    
    func requestAccessIfNeeded() {
        center.getNotificationSettings { [weak self] notificationSettings in
            let authorizationStatus = notificationSettings.authorizationStatus
            
            guard authorizationStatus != .authorized,
                  authorizationStatus != .ephemeral,
                  authorizationStatus != .provisional
            else { return }
            
            switch notificationSettings.authorizationStatus {
                case .authorized, .ephemeral, .provisional:
                    return
                    
                case .denied, .notDetermined:
                    self?.requestAccess(with: [.alert, .badge, .sound])
                    
                @unknown default:
                    return
            }
        }
    }
    
    func send(with title: String,
              subtitle: String,
              body: String,
              badge: NSNumber,
              trigger: UNNotificationTrigger,
              identifier: String) {
        
        let content = makeNotificationContent(with: title,
                                              subtitle: subtitle,
                                              message: body,
                                              badge: badge)
        
        let notificationRequest = UNNotificationRequest(identifier: identifier,
                                                        content: content,
                                                        trigger: trigger)
        
        center.add(notificationRequest) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func makeNotificatioTriggerFor30Minutes() -> UNNotificationTrigger {
        let oneMinuteInSeconds = 60
        let requiredIntervalInMinutes = 30
        let interval = TimeInterval(requiredIntervalInMinutes * oneMinuteInSeconds)
        return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
    }
    
    // MARK: - Private methods
    
    private func requestAccess(with options: UNAuthorizationOptions = [] ) {
        center.requestAuthorization(options: options) { isGranted, error in
            if let error = error {
                #warning("TODO: Error handler")
                print(error.localizedDescription)
            }
            print("Authorization status with options: \(options) is granted: \(isGranted)")
        }
    }
    
    private func makeNotificationContent(with title: String,
                                 subtitle: String,
                                 message: String,
                                 badge: NSNumber) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = message
        content.badge = badge
        return content
    }
    
}
