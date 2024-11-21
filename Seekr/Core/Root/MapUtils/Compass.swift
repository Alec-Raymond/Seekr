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

import UIKit

class CompassImageView: UIView, CompassDelegate {
    let compass = Compass()
    
    private let greenCompass = UIImageView(image: UIImage(named: "compass_green.png"))
    private let yellowCompass = UIImageView(image: UIImage(named: "compass_yellow.png"))
    private let redCompass = UIImageView(image: UIImage(named: "compass_red.png"))
    
    init() {
        super.init(frame: .zero)
        setupImageViews()
        compass.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageViews()
        compass.delegate = self
    }
    
    func didUpdateLocation(_ location: CLLocation) {
        return
    }
    
    func didUpdateCompassBearing(_ bearing: CGFloat) {
        let currentHeading = abs(bearing / .pi * 180 - 180.0)
        print("heading: ", currentHeading)
        if (currentHeading > 160) {
            greenCompass.alpha = 1.0
            yellowCompass.alpha = 0.0
            redCompass.alpha = 0.0
        } else if (currentHeading > 140) {
            greenCompass.alpha = 1.0
            yellowCompass.alpha = (160 - currentHeading) / 20.0
            redCompass.alpha = 0.0
        } else if (currentHeading > 120) {
            greenCompass.alpha = (currentHeading - 120) / 20.0
            yellowCompass.alpha = 1.0
            redCompass.alpha = 0.0
        } else if (currentHeading > 80) {
            greenCompass.alpha = 0.0
            yellowCompass.alpha = 1.0
            redCompass.alpha = 0.0
        } else if (currentHeading > 60) {
            greenCompass.alpha = 0.0
            yellowCompass.alpha = 1.0
            redCompass.alpha = (80 - currentHeading) / 20.0
        } else if (currentHeading > 40) {
            greenCompass.alpha = 0.0
            yellowCompass.alpha = (currentHeading - 40) / 20.0
            redCompass.alpha = 1.0
        } else {
            greenCompass.alpha = 0.0
            yellowCompass.alpha = 0.0
            redCompass.alpha = 1.0
        }
        UIView.animate(withDuration: 0.5) {
            print(bearing)
            self.greenCompass.transform = CGAffineTransform(rotationAngle: bearing)
            self.yellowCompass.transform = CGAffineTransform(rotationAngle: bearing)
            self.redCompass.transform = CGAffineTransform(rotationAngle: bearing)
        }
    }
    
    func didFailWithError(_ error: any Error) {
        return
    }
    
    private func setupImageViews() {
        // Set up the images
        
        greenCompass.translatesAutoresizingMaskIntoConstraints = false
        yellowCompass.translatesAutoresizingMaskIntoConstraints = false
        redCompass.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(redCompass)
        addSubview(yellowCompass)
        addSubview(greenCompass)
        
        NSLayoutConstraint.activate([
            greenCompass.topAnchor.constraint(equalTo: topAnchor),
            greenCompass.leadingAnchor.constraint(equalTo: leadingAnchor),
            greenCompass.trailingAnchor.constraint(equalTo: trailingAnchor),
            greenCompass.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            yellowCompass.topAnchor.constraint(equalTo: topAnchor),
            yellowCompass.leadingAnchor.constraint(equalTo: leadingAnchor),
            yellowCompass.trailingAnchor.constraint(equalTo: trailingAnchor),
            yellowCompass.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            redCompass.topAnchor.constraint(equalTo: topAnchor),
            redCompass.leadingAnchor.constraint(equalTo: leadingAnchor),
            redCompass.trailingAnchor.constraint(equalTo: trailingAnchor),
            redCompass.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        greenCompass.alpha = 1.0
        yellowCompass.alpha = 0.0
        redCompass.alpha = 0.0
    }
}

