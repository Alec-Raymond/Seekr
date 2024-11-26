import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
    func didUpdateHeading(_ heading: CLHeading)
    func didFailWithError(_ error: Error)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private var delegates = [LocationManagerDelegate]()

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func addDelegate(_ delegate: LocationManagerDelegate) {
        delegates.append(delegate)
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            for delegate in delegates {
                delegate.didUpdateLocation(location)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        for delegate in delegates {
            delegate.didUpdateHeading(newHeading)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        for delegate in delegates {
            delegate.didFailWithError(error)
        }
    }
}
