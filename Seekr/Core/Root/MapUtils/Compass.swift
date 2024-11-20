//
//  compass.swift
//  Seekr
//
//  Created by Alec Raymond on 11/19/24.
//
import Foundation
import CoreLocation

import Foundation

protocol CompassDelegate: AnyObject {
    func didUpdateCompassBearing(_ bearing: CGFloat)
}

class Compass: NSObject, CLLocationManagerDelegate, LocationManagerDelegate {
    weak var delegate: CompassDelegate?
    
    var currentHeading = CGFloat()
    var destinationCoordinates = CLLocationCoordinate2D()
    var currentNextStepCoordinates = CLLocationCoordinate2D()
    var currentLocationCoordinates = CLLocationCoordinate2D()
    
    override init() {
        super.init()
        let locationManager = LocationManager.shared
        locationManager.addDelegate(self)
    }

    func didUpdateLocation(_ location: CLLocation) {
        currentLocationCoordinates = location.coordinate
    }
    
    func didUpdateHeading(_ heading: CLHeading) {
        print("dest: ", destinationCoordinates.latitude)
        self.currentHeading = CGFloat(heading.trueHeading) * .pi / 180
        var destinationBearing = calculateBearing(from: currentLocationCoordinates, to: destinationCoordinates)
        
        if (destinationCoordinates.latitude == 0.0) {
            updateBearing(newBearing: currentHeading)
            return
        } else if (currentNextStepCoordinates.latitude == 0.0) {
            updateBearing(newBearing: ((destinationBearing - currentHeading) + (2 * .pi)).truncatingRemainder(dividingBy: 2 * .pi))
        }
        var nextStepBearing = calculateBearing(from: currentLocationCoordinates, to: currentNextStepCoordinates)
        if abs(destinationBearing - nextStepBearing) > .pi {
            if destinationBearing < nextStepBearing {
                destinationBearing += 2 * .pi
            } else {
                nextStepBearing += 2 * .pi
            }
        }
        // Calculate the weighted average
        let weightedAngle = (0.8 * destinationBearing + 0.2 * nextStepBearing).truncatingRemainder(dividingBy: 2 * .pi)
        let compassBearing = ((weightedAngle - currentHeading) + (2 * .pi)).truncatingRemainder(dividingBy: 2 * .pi) // Normalize to 0-360
        updateBearing(newBearing: compassBearing)
    }
        
    func calculateBearing(from coordinate1: CLLocationCoordinate2D, to coordinate2: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaLongitude = coordinate2.longitude - coordinate1.longitude
        let y = sin(deltaLongitude) * cos(coordinate2.latitude)
        let x = cos(coordinate1.latitude) * sin(coordinate2.latitude) - sin(coordinate1.latitude) * cos(coordinate2.latitude) * cos(deltaLongitude)
        let bearing = atan2(y, x)
        return bearing
    }
    
    func updateBearing(newBearing: CGFloat) {
        // Notify the delegate about the new heading
        delegate?.didUpdateCompassBearing(newBearing)
    }
    
    func didFailWithError(_ error: any Error) {
        return
    }
}
