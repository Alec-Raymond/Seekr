//
//  NotificationManager.swift
//  Seekr
//
//  Created by Lisa Systaliuk on 11/19/24.
//

import Foundation
import UserNotifications
import UIKit

/// `NotificationManager` is responsible for managing and dispatching user notifications.
/// It ensures proper handling of permissions and schedules notifications for specific events.
///
/// - Note: This class is a singleton, accessed through `NotificationManager.shared`.
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    /// Shared instance of `NotificationManager` to ensure a single point of access.
    static let shared = NotificationManager()
    
    /// Flag to determine if notifications can be scheduled.
    /// Prevents duplicate notifications when one is already active.
    var ableToSchedule = true

    /// The notification center used to schedule and manage notifications.
    private let notificationCenter = UNUserNotificationCenter.current()
    
    /// Initializes the `NotificationManager` and sets its delegate to handle notifications.
    override init() {
        super.init()
        self.notificationCenter.delegate = self
    }
    
    /// Requests permission to send notifications and returns the authorization status.
    ///
    /// - Parameter completion: A closure that takes a `Bool` indicating whether permission was granted.
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
    
    /// Dispatches a "wrong direction" notification to the user.
    ///
    /// - Note: This method checks `ableToSchedule` before sending a notification to avoid duplicates.
    /// - Notification details:
    ///   - Title: "Wrong Direction"
    ///   - Body: "You are currently heading in the wrong direction!"
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
        
        // Remove any pending notifications with the same identifier before scheduling a new one.
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
    
    /// Handles the presentation of notifications while the app is in the foreground.
    ///
    /// - Parameters:
    ///   - center: The `UNUserNotificationCenter` instance handling the notification.
    ///   - notification: The notification being presented.
    ///   - completionHandler: A closure specifying how the notification should be presented.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.badge, .banner, .list, .sound])
    }
    
    /// Opens the app's notification settings in the system settings.
    ///
    /// - Note: This method only works if the device supports opening the settings URL.
    func openAppNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}

