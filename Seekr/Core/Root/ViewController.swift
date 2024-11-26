//
//  ViewController.swift
//  Seekr
//
//  Created by Zander Dumont on 10/29/24.
//

import UIKit
import CoreData
import MapKit
import SwiftUI
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDataSource, UITableViewDelegate, LocationManagerDelegate {
    
    func didUpdateCompassBearing(_ bearing: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            print(bearing)
            self.compassImageView.transform = CGAffineTransform(rotationAngle: bearing)
        }
    }
    
    
    var searchCompleter = MKLocalSearchCompleter()
    let compassImageView = CompassImageView()
    var searchResults = [MKLocalSearchCompletion]()
    var annotationList = [MKPointAnnotation]()
    var tableView = UITableView()
    var routeOverlay: MKPolyline?
    var currentRoute: MKRoute?
    var userCentered = false
    let geocoder = CLGeocoder()
    var currentLocation = CLLocation()
    var destinationLocation = CLLocation()
    var destinationDistance = CLLocationDistance()

    var isLiveRoute = false
    var routeTimer: Timer?
    var initialized = false
    // Zander added: haveDestination to keep track if the
    // user is currently navigating or has not yet started
    // their route
    var haveDestination = false
    // Zander: moved scale here
    let scale: CGFloat = 300
//    Lisa added instanse of notificationManager
    private let notificationManager = NotificationManager.shared
    
    private let locationManager = LocationManager.shared
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    

    // Go Button
    let goButton: UIButton = {
        let goButton = UIButton()
        goButton.setTitle("GO", for: .normal)
        goButton.backgroundColor = .blue
        goButton.layer.cornerRadius = 15
        goButton.translatesAutoresizingMaskIntoConstraints = false
        goButton.isHidden = true
        goButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return goButton
    }()
    
    // Zander added: Progress Bar
    let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        progressView.progressTintColor = .blue
        progressView.progressViewStyle = .bar
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 5
        progressView.clipsToBounds = true
        progressView.layer.sublayers?.forEach { $0.cornerRadius = 5 }
        progressView.subviews.forEach { $0.clipsToBounds = true }
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        return progressView
    }()

    lazy var searchTextField: UISearchBar = {
        let searchTextField = UISearchBar()
        searchTextField.layer.cornerRadius = 15
        searchTextField.clipsToBounds = true
        searchTextField.backgroundColor = UIColor.lightGray
        searchTextField.placeholder = "Search"
        searchTextField.delegate = self
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        return searchTextField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.addDelegate(self)
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        searchCompleter.delegate = self
        mapView.delegate = self
        
        tableView.delegate = self // Set the delegate
        tableView.dataSource = self
        setupUI()
        centerViewOnUserLocation()
//      Lisa added checking for permission of notifications
        notificationManager.checkForPermission()
    }
    
    func startRouteTimer() {
        routeTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(recalculateRoute), userInfo: nil, repeats: true)
    }
    
    private var searchTextFieldBottomConstraint: NSLayoutConstraint!
    private var tableViewTopConstraint: NSLayoutConstraint!
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        view.addSubview(compassImageView)
        view.addSubview(goButton)
        view.addSubview(progressView)
        
        // Zander added: Center Go Button and Progress Bar
        NSLayoutConstraint.activate([
            goButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            goButton.widthAnchor.constraint(equalToConstant: 150),
            goButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Center Progress Bar
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 300),
            progressView.heightAnchor.constraint(equalToConstant: 10),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        searchTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchTextFieldBottomConstraint = searchTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        searchTextFieldBottomConstraint.isActive = true
        searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.2).isActive = true
        searchTextField.returnKeyType = .go
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: view.bottomAnchor)
        tableViewTopConstraint.isActive = true
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0.0)
        tableViewHeightConstraint.isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.dataSource = self
        
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 400).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        compassImageView.translatesAutoresizingMaskIntoConstraints = false
        compassImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        compassImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        compassImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        compassImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showSearch()
    }
    
    // Zander added: show Go Button
    func showGoButton() {
        goButton.isHidden = false
    }
    
    // Zander added: hide Go Button
    func hideGoButton() {
        goButton.isHidden = true
    }
    
    // Zander added: show Progress Bar
    func showPBar() {
        progressView.isHidden = false
    }
    
    // Zander added: hide Progress Bar
    func hidePBar() {
        progressView.isHidden = true
    }
    
    // Zander added: go Button pressed
    @objc func buttonPressed() {
        // go button is pressed so we are now navigating
        // and have a destination
        haveDestination = true
        // after button is pressed hide button
        hideGoButton()
        // center view -- we may want to change the way the
        // view is centered such that the path is always
        // facing the top of the screen
        centerViewOnUserLocation()
        // show progress bar
        showPBar()
        startRouteTimer()
    }
    
    // Zander added: function that updates the progress
    // bar by taking the distance remaining and using
    // the destination distance to calculate
    // progress as a percentage
    func updateProgressBar(distanceRemaining: CLLocationDistance) {
        let p = Float(destinationDistance - distanceRemaining) / Float(destinationDistance)
        if (p > 0) {
            progressView.progress = p
//            notificationManager.dispatchNotification()
        }
        else if (p > 1 && distanceRemaining > 0) {
            progressView.progress = 0.0
        }
        else if (p >= 1 && distanceRemaining < 0) {
            progressView.progress = 1.0
        }
    }
    
    func showSearch() {
        // Deactivate constraints
        UIView.animate(withDuration: 0.3, animations: {
            NSLayoutConstraint.deactivate([self.searchTextFieldBottomConstraint, self.tableViewTopConstraint, self.tableViewHeightConstraint])
            self.searchTextFieldBottomConstraint = self.searchTextField.bottomAnchor.constraint(equalTo: self.view.centerYAnchor)
            self.tableViewTopConstraint = self.tableView.topAnchor.constraint(equalTo: self.searchTextField.bottomAnchor)
            NSLayoutConstraint.activate([self.searchTextFieldBottomConstraint, self.tableViewTopConstraint])
            self.view.layoutIfNeeded()
        })
    }

    func hideSearch() {
        UIView.animate(withDuration: 0.3, animations: {
            NSLayoutConstraint.deactivate([self.searchTextFieldBottomConstraint, self.tableViewTopConstraint])
            self.searchTextFieldBottomConstraint = self.searchTextField.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            self.tableViewTopConstraint = self.tableView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
            NSLayoutConstraint.activate([self.searchTextFieldBottomConstraint, self.tableViewTopConstraint, self.tableViewHeightConstraint])
            self.view.layoutIfNeeded()
        })
    }

    //implement below function for cleaner code
//    func checkForWrongDirection(currentDistance: CLLocationDistance, previousDistance: CLLocationDistance) {
//        let progress = Float(destinationDistance - currentDistance) / Float(destinationDistance)
//        //percentage of (previous distance - current distance) / destination distance
//        //how to calculate per
//        print(progress)
//        if progress > 0 {
//            // Moving closer to the destination
//            notificationManager.ableToSchedule = true
//            }
//        else if currentDistance > previousDistance {
//            // Moving farther from the destination (wrong direction)
//            notificationManager.dispatchNotification()
//            print("Notification: You are going in the wrong direction.")
//            notificationManager.ableToSchedule = false // Prevent multiple notifications until going the right way
//        }
//            
//                
//            
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        lastLocation = currentLocation
//        Lisa:
//        compare previousDistance to DistanceRemaining to determine if we are
//        going the right direction
//        let distanceRemaining = currentLocation.distance(from: destinationLocation)
        let previousDistance = destinationDistance  //location during 1st time period
  
    // LocationManagerDelegate methods
    func didUpdateLocation(_ location: CLLocation) {
        currentLocation = location // store this location somewhere
        if (!initialized) {
            centerViewOnUserLocation()
            initialized = true
        }
        let distanceRemaining = currentLocation.distance(from: destinationLocation)
        // print("distance remaining: ", distanceRemaining)
        // need to give distanceRemaining to progress bar
        updateProgressBar(distanceRemaining: distanceRemaining)

        // Zander added: calculate distance remaining if
        // we have a destination

        if haveDestination {//if started the route
            let distanceRemaining = currentLocation.distance(from: destinationLocation)//location during 2nd time period
            destinationDistance = distanceRemaining
            print("progress", previousDistance-distanceRemaining)
            let progress = Float(previousDistance - distanceRemaining) / Float(previousDistance)*100.0//should be positive for right direction, negative for wrong direction
//            checkForWrongDirection(currentDistance: distanceRemaining, previousDistance: previousDistance)
            print(progress)
            if (progress < 0) {//if going wrong direction
                notificationManager.dispatchNotification()
                self.createPath(from: lastLocation.coordinate, to: destinationLocation.coordinate)
                print("Warning: You're going in the wrong direction!")
            }
//            checkForWrongDirection(currentDistance: distanceRemaining, previousDistance: destinationDistance)
//            if arrived
            else if distanceRemaining < 50 { // need to fine tune
                haveDestination = false
                hidePBar()
                // we have arrived, do something here
                // perhaps lisa can add a notification
                print("you have arrived")
                
                
            } else {//going right direction
                // Zander added: update the progress bar with the
                // current distance remaining
                notificationManager.ableToSchedule = true
                updateProgressBar(distanceRemaining: distanceRemaining)
            }
        }
    }

    func didFailWithError(_ error: Error) {
        print("Failed to update location: \(error)")
    }
    
    func didUpdateHeading(_ heading: CLHeading) {
        return
    }

    private func centerViewOnUserLocation() {
        let coordinate = currentLocation.coordinate
        let region = MKCoordinateRegion.init(center: coordinate,
                                             latitudinalMeters: scale,
                                             longitudinalMeters: scale)
        print("view centered")
        print(currentLocation.coordinate)
        mapView.setRegion(region, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let temp = completer.results.filter { !($0.subtitle.contains("Search Nearby")) && !($0.subtitle.contains("No Results Nearby")) && !$0.subtitle.isEmpty }
        searchResults = temp
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let searchResult = searchResults[indexPath.row]
        print(currentLocation.coordinate)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }

    @objc func recalculateRoute() {
        clearPath()
        createPath(from: currentLocation.coordinate, to: destinationLocation.coordinate)
        findBearings(userLocation: currentLocation.coordinate)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideSearch()
        //remove the selection after the row is tapped
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedResult = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: selectedResult)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] (response, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let response = response, let mapItem = response.mapItems.first else {
                print("No matching location found")
                return
            }

            let coordinate = mapItem.placemark.coordinate
            self.destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            compassImageView.compass.destinationCoordinates = destinationLocation.coordinate
            let name = mapItem.name ?? selectedResult.title
            
            
            
            self.mapView.removeAnnotations(self.annotationList)
            self.annotationList.removeAll()
            

            let annotation = MKPointAnnotation()//use mkpoint to display possible locations
            annotation.coordinate = coordinate
            annotation.title = name
            self.mapView.addAnnotation(annotation)
            self.annotationList.append(annotation)
            
            // center the map -> call centermap on coordinates
            recalculateRoute()
            self.centerMapOnCoordinates(coord1: currentLocation.coordinate, coord2: destinationLocation.coordinate)

            self.searchTextField.resignFirstResponder()
            showGoButton()
        }
    }

    
    func convertAddressToAnnotation(name: String, address: String, camera: Bool = false, path: Bool = false) {
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("No location found")
                return
            }
            // Use the location (latitude, longitude)
            let coordinate = location.coordinate
            print("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //you can add whatever info you want to your pin
            annotation.title = name
            for a in self.annotationList {
                self.mapView.removeAnnotation(a)
            }
            self.mapView.addAnnotation(annotation)
            self.annotationList.append(annotation)
            if (camera) {
                self.centerMapOnCoordinates(coord1: self.currentLocation.coordinate, coord2: coordinate)
            }
            if (path) {
                //self.clearPath()
                self.createPath(from: self.currentLocation.coordinate, to: coordinate)
            }
        }
    }
    
    func findBearings(userLocation: CLLocationCoordinate2D) {
        if let currentRoute {
            let route_points = currentRoute.steps[0].polyline.points()
            let next_step = route_points[1]
            compassImageView.compass.currentNextStepCoordinates = next_step.coordinate
        }
    }
    
    func centerMapOnCoordinates(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) {
        // Zander added: hide the Progress Bar and Go
        // Button
        hidePBar()
        hideGoButton()
        
        let camera = MKMapCamera()
        
        let midLatitude = (coord1.latitude + coord2.latitude) / 2
        let midLongitude = (coord1.longitude + coord2.longitude) / 2
        let center = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)
        
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        let distance = location1.distance(from: location2)
        let bearing = compassImageView.compass.calculateBearing(from: coord1, to: coord2)
        print("bearing: " ,bearing)
        destinationDistance = distance
        camera.centerCoordinate = center
        camera.centerCoordinateDistance = 4.0 * distance
        camera.heading = (bearing * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
        mapView.setCamera(camera, animated: true)
        
        // Zander added: show Go button after map path is
        // centered
        //Alec: TODO change this
        showGoButton()
    }
    


    func createPath(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .walking

        let directions = MKDirections(request: directionsRequest)

        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            guard let response = response else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }

            if let routeOverlay = self.routeOverlay {
                self.mapView.removeOverlay(routeOverlay)
            }

            self.currentRoute = response.routes[0]
            self.routeOverlay = self.currentRoute?.polyline
            self.mapView.addOverlay(routeOverlay!, level: .aboveRoads)
        }
    }

    func clearPath() {
        if let routeOverlay = routeOverlay {
            mapView.removeOverlay(routeOverlay)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 6.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

