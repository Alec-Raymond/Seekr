//
//  WrongDirectionDetector.swift
//  Seekr
//
//  Created by Lisa Systaliuk on 12/09/24.
//

import Foundation
import CoreLocation
import MapKit

/// `WrongDirectionDetector` is responsible for determining if a user is moving away from their intended destination.
/// It tracks cumulative deviation, detects wrong direction movements, and triggers notifications when thresholds are exceeded.
///
/// - Note: This class uses the user's current and destination locations to calculate deviations and requires a `NotificationManager` instance to dispatch notifications.
class WrongDirectionDetector {
    
    /// Tracks the cumulative deviation from the route, measured in meters.
    /// This value increases when the user moves further away from the destination.
    private var cumulativeDeviation: Double = 0.0
    
    /// The deviation threshold, in meters, at which a notification is triggered.
    private let notificationThreshold: Double = 50.0
    
    /// Stores the previous distance to the destination to track changes in the user's movement.
    private var previousDistanceToDestination: Double?
    
    /// The number of consecutive correct movements required to reset the cumulative deviation.
    private let resetThreshold = 3
    
    /// Tracks consecutive movements in the correct direction. Resets when the user moves the wrong way.
    private var consecutiveRightDirections = 0
    
    
    /// Updates the location tracking and checks if the user is moving in the wrong direction.
    ///
    /// This function calculates the change in distance to the destination and updates the cumulative deviation if the user is moving away from the destination. If the deviation exceeds the threshold, a notification is triggered.
    /// 
    /// - Parameters:
    ///   - currentLocation: The user's current location as a `CLLocation` object.
    ///   - destinationLocation: The target destination as a `CLLocation` object.
    ///   - notificationManager: An instance of `NotificationManager` that handles notification dispatch.
    ///
    /// - Returns: A `Bool` value indicating whether a notification should be triggered.
    ///   - `true`: The user is moving in the wrong direction, and a notification is warranted.
    ///   - `false`: The user is either stationary, moving in the correct direction, or deviation is within the threshold.
    ///
    /// - Note: Notifications will only be triggered if the `NotificationManager` permits scheduling.
    func updateLocation(currentLocation: CLLocation, destinationLocation: CLLocation, notificationManager: NotificationManager) -> Bool {
        let currentDistance = currentLocation.distance(from: destinationLocation)
        
        // Initialize previous distance on the first update.
        if previousDistanceToDestination == nil {
            previousDistanceToDestination = currentDistance
            return false
        }
        
        // Calculate the change in distance to the destination.
        let distanceChange = currentDistance - (previousDistanceToDestination ?? currentDistance)
        
        // Check if the user is moving away from the destination.
        if currentLocation.speed > 0 && distanceChange > 0 {
            // Increment cumulative deviation.
            cumulativeDeviation += distanceChange
            consecutiveRightDirections = 0
            
            // Trigger notification if deviation exceeds the threshold.
            if cumulativeDeviation >= notificationThreshold && notificationManager.ableToSchedule {
                previousDistanceToDestination = currentDistance
                return true
            }
        } else {
            // User is moving in the correct direction.
            consecutiveRightDirections += 1
            
            // Reset deviation if moving in the correct direction consistently.
            if consecutiveRightDirections >= resetThreshold {
                cumulativeDeviation = 0
                consecutiveRightDirections = 0
                notificationManager.ableToSchedule = true
            }
        }
        
        // Update the previous distance for the next iteration.
        previousDistanceToDestination = currentDistance
        return false
    }
    
    /// Resets the state of the detector, clearing all deviation and direction tracking.
    ///
    /// This method should be called when the destination changes or a fresh start is required.
    ///
    /// - Note: After calling this method, all internal counters and deviation values are reset to their initial states.
    func reset() {
        cumulativeDeviation = 0
        previousDistanceToDestination = nil
        consecutiveRightDirections = 0
    }
}
