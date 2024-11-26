//
//  NotificationManager.swift
//  Seekr
//
//  Created by Lisa Systaliuk on 11/19/24.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    var ableToSchedule = true //it checks if there is the need to send a notification
//    if you are going wrong direction, only send 1 notification
//    only send notification if you were going the right direction and you are suddenly going the wrong direction
    let notificationCenter = UNUserNotificationCenter.current()
    override init() {
        super.init()
        self.notificationCenter.delegate = self
    }
    
    func checkForPermission() {
        
        self.notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                return
//                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options : [.badge, .alert, .sound]) { didAllow, error in
                    if didAllow {
                        return
//                        self.dispatchNotification()
                    }
                }
            default:
                return
            }
        }
    }
    func dispatchNotification() {
        if !ableToSchedule {
            return
        }
        ableToSchedule = false
        let identifier = "wrong-direction-notification"
        let title = "Wrong direction"
        let body = "You are currently heading in the wrong direction!"
//        let hour = 0
//        let minute = 11
//        let isDaily = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
//        let calendar = Calendar.current
//        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
//        dateComponents.hour = hour
//        dateComponents.minute = minute
        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request) { error in
            print(error)
        }
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

