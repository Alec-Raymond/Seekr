//
//  NotificationTests.swift
//  SeekrTests
//
//  Created by Lisa Systaliuk on 12/3/24.
//

import XCTest
import UserNotifications
@testable import Seekr 

class NotificationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        super.tearDown()
        
    }

///     Test to verify that a notification is scheduled successfully.
///
///     `Steps:`
///     - Dispatch a notification.
///     - Check the list of pending notifications to ensure one with the specified identifier exists.
///     - Assert that the notification is found.

    func testNotificationIsScheduled() {
        let expectation = XCTestExpectation(description: "Notification scheduled")
        let notificationCenter = UNUserNotificationCenter.current()

        NotificationManager.shared.dispatchNotification()

        notificationCenter.getPendingNotificationRequests { requests in
            let notificationExists = requests.contains { $0.identifier == "wrong-direction-notification" }
            XCTAssertTrue(notificationExists, "Notification should be scheduled")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

///     Test to verify the notification timing is correct.
///
///     `Steps:`
///     - Dispatch a notification.
///     - Retrieve the trigger for the pending notification.
///     - Assert that the trigger time matches the expected interval.

    func testNotificationTiming() {
        let triggerTime: TimeInterval = 5
        let notificationCenter = UNUserNotificationCenter.current()
        let expectation = XCTestExpectation(description: "Notification sent at correct time")

        NotificationManager.shared.dispatchNotification()

        notificationCenter.getPendingNotificationRequests { requests in
            let trigger = requests.first(where: { $0.identifier == "wrong-direction-notification" })?.trigger as? UNTimeIntervalNotificationTrigger
            XCTAssertEqual(trigger?.timeInterval, triggerTime, "Notification should be triggered after \(triggerTime) seconds")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 6.0)
    }

///     Test to ensure that only one notification is scheduled even if the dispatch method is called multiple times.
///
///     `Steps:`
///     - Dispatch the same notification twice.
///     - Retrieve the pending notifications.
///     - Assert that only one notification exists for the given identifier.

    func testNotificationDebouncing() {
        let notificationCenter = UNUserNotificationCenter.current()
        let expectation = XCTestExpectation(description: "Only one notification scheduled")

        NotificationManager.shared.dispatchNotification()
        NotificationManager.shared.dispatchNotification()

        notificationCenter.getPendingNotificationRequests { requests in
            let notifications = requests.filter { $0.identifier == "wrong-direction-notification" }
            XCTAssertEqual(notifications.count, 1, "Only one notification should be scheduled")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
    
///     Test to verify that the app correctly handles notification permissions.
///
///     `Steps:`
///     - Simulate checking for notification permissions.
///     - Assert that permissions are granted.
  
    func testNotificationPermissionHandling() {
        let permissionExpectation = XCTestExpectation(description: "Notification permission checked")

        NotificationManager.shared.checkForPermission { allowed in
            XCTAssertTrue(allowed, "Permissions should be granted for notifications")
            permissionExpectation.fulfill()
        }

        wait(for: [permissionExpectation], timeout: 2.0)
    }
}
