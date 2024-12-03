//
//  NotificationManager.swift
//  Seekr
//
//  Created by Lisa Systaliuk on 11/19/24.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    var ableToSchedule = true // Checks if there's a need to send a notification
    let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        self.notificationCenter.delegate = self
    }
    
    func checkForPermission(completion: @escaping (Bool) -> Void) {
        self.notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            case .denied:
                completion(false)
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.badge, .alert, .sound]) { didAllow, _ in
                    completion(didAllow)
                }
            default:
                completion(false)
            }
        }
    }
    
    func dispatchNotification() {
        if !ableToSchedule {
            return
        }
        ableToSchedule = false
        
        let identifier = "wrong-direction-notification"
        let title = "Wrong Direction"
        let body = "You are currently heading in the wrong direction!"
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
    
    func openAppNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
