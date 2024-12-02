//
//  LandmarkController.swift
//  Seekr
//
//  Created by Zander Dumont on 12/2/24.
//

import Foundation
import CoreLocation

struct Landmark {
    let name: String
    let details: String
    let coordinate: CLLocationCoordinate2D
    let radius: Double // Proximity radius in meters
    var isFound: Bool = false // Track if the landmark has been found
}

protocol LandmarkManagerDelegate: AnyObject {
    func didEnterLandmark(_ landmark: Landmark)
}

class LandmarkManager: NSObject, LocationManagerDelegate {
    func didUpdateHeading(_ heading: CLHeading) {
        return
    }
    
    func didFailWithError(_ error: any Error) {
        return
    }
    
    private var landmarks: [Landmark] = []
    weak var delegate: LandmarkManagerDelegate?

    override init() {
        super.init()
        LocationManager.shared.addDelegate(self)  // Register this manager as a delegate to get location updates
    }

    func addLandmarks(_ newLandmarks: [Landmark]) {
        landmarks.append(contentsOf: newLandmarks)
    }

    // LocationManagerDelegate method to receive location updates
    func didUpdateLocation(_ location: CLLocation) {
        for (index, landmark) in landmarks.enumerated() {
            let landmarkLocation = CLLocation(latitude: landmark.coordinate.latitude, longitude: landmark.coordinate.longitude)
            let distance = location.distance(from: landmarkLocation)
            print("distance to landmark:", distance)
            
            // If within proximity, notify the delegate and mark as found
            if distance <= landmark.radius && !landmark.isFound {
                var updatedLandmark = landmark
                updatedLandmark.isFound = true
                landmarks[index] = updatedLandmark
                delegate?.didEnterLandmark(updatedLandmark)
            }
        }
    }
}
