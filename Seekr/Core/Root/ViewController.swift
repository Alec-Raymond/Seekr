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
import Combine


class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDataSource, UITableViewDelegate, LocationManagerDelegate {
    
    func didUpdateCompassBearing(_ bearing: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            print(bearing)
            self.compassImageView.transform = CGAffineTransform(rotationAngle: bearing)
        }
    }

    //Pins variables
    private let pinManager = PinDataManager.shared
    private var cancellables = Set<AnyCancellable>()

    
    var searchCompleter = MKLocalSearchCompleter()
    let compassImageView = CompassImageView()
    var searchResults = [MKLocalSearchCompletion]()
    var annotationList = [MKPointAnnotation]()
    var tableView = UITableView()
    var routeOverlay: MKPolyline?
    var oldRoute: MKPolyline?
    var currentRoute: MKRoute?
    var userCentered = false
    let geocoder = CLGeocoder()
    var currentLocation = CLLocation()
    var destinationLocation = CLLocation()
    var destinationDistance = CLLocationDistance()
    var routeTimer: Timer?
    var initialized = false
    var haveDestination = false
    let scale: CGFloat = 300
    
    private let locationManager = LocationManager.shared
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    //MARK: - Pin Management
    private func setupPinManagement() {
        // Observe pin manager changes
        pinManager.$pins
            .sink { [weak self] pins in
                self?.updateMapAnnotations(pins: pins)
            }
            .store(in: &cancellables)
        
        // Observe selected pin changes
        pinManager.$selectedPin
            .sink { [weak self] pin in
                if let pin = pin {
                    self?.centerMapOnPin(pin)
                }
            }
            .store(in: &cancellables)
            
        // Add tap gesture for pin creation
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        // Display existing pins
        displayExistingPins()
    }
    
    private func displayExistingPins() {
        for pin in pinManager.pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.name
            mapView.addAnnotation(annotation)
        }
    }
    
    private func updateMapAnnotations(pins: [PinAnnotation]) {
        // Remove existing annotations except user location
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        // Add new annotations
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.name
            mapView.addAnnotation(annotation)
        }
    }
    
    private func centerMapOnPin(_ pin: PinAnnotation) {
        let region = MKCoordinateRegion(
            center: pin.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        mapView.setRegion(region, animated: true)
        
        if let annotation = mapView.annotations.first(where: {
            $0.coordinate.latitude == pin.coordinate.latitude &&
            $0.coordinate.longitude == pin.coordinate.longitude
        }) {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        
        // Check if we tapped on an annotation
        let tappedAnnotations = mapView.annotations.filter { annotation in
            guard let annotationView = mapView.view(for: annotation) else { return false }
            let annotationPoint = annotationView.convert(annotationView.bounds.center, to: mapView)
            return abs(point.x - annotationPoint.x) < 22 && abs(point.y - annotationPoint.y) < 22
        }
        
        // Only proceed with pin creation if we didn't tap an annotation
        if tappedAnnotations.isEmpty {
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowPinPrompt"),
                object: nil,
                userInfo: ["coordinate": coordinate]
            )
        }
    }
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Skip user location annotation
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "PinAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let deleteButton = UIButton(type: .close)
            annotationView?.rightCalloutAccessoryView = deleteButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation {
            if let index = pinManager.pins.firstIndex(where: {
                $0.coordinate.latitude == annotation.coordinate.latitude &&
                $0.coordinate.longitude == annotation.coordinate.longitude
            }) {
                pinManager.removePin(at: index)
            }
        }
    }
    //MARK: Map Navigation Features
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
        setupPinManagement()
        
        // Add observer for pin addition
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAddPin(_:)),
            name: NSNotification.Name("AddPin"),
            object: nil
        )
        
        // Add observer for end route button
        NotificationCenter.default.addObserver(self, selector: #selector(endRoute), name: .endRouteNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .endRouteNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("AddPin"), object: nil)
    }
    
    @objc private func handleAddPin(_ notification: Notification) {
        guard let name = notification.userInfo?["name"] as? String,
              let coordinate = notification.userInfo?["coordinate"] as? CLLocationCoordinate2D else { return }
        
        pinManager.addPin(name: name, coordinate: coordinate)
    }
    
    func startRouteTimer() {
        routeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(recalculateRoute), userInfo: nil, repeats: true)
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
            goButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            goButton.widthAnchor.constraint(equalToConstant: 150),
            goButton.heightAnchor.constraint(equalToConstant: 40),
            progressView.widthAnchor.constraint(equalToConstant: 280),
            progressView.heightAnchor.constraint(equalToConstant: 10),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2)
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
    
    // Zander added: function to end route
    @objc func endRoute() {
        if haveDestination {
            hidePBar()
            clearPath()
            haveDestination = false
        } else {
            showNoDestinationAlert()
        }
    }
    
    // Zander added: function that makes pop up when
    // user hits end button with no destination
    func showNoDestinationAlert() {
            let alert = UIAlertController(title: "Unable to End Route", message: "You are not currently navigating.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    // Zander added: functions that makes pop up when you
    // have arrived to your destination
    func showArrivedAlert() {
        let alert = UIAlertController(title: "You've Arrived", message: "Thank you for using Seekr to navigate!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
  
    // LocationManagerDelegate methods
    func didUpdateLocation(_ location: CLLocation) {
        currentLocation = location // store this location somewhere
        if (!initialized) {
            centerViewOnUserLocation()
            initialized = true
        }
        // Zander added: calculate distance remaining if
        // we have a destination
        if haveDestination { //if started the route
            let distanceRemaining = currentLocation.distance(from: destinationLocation)
            print("d: ", distanceRemaining)
            if distanceRemaining < 50 { // need to fine tune
                // we have arrived
                // perhaps lisa can add a notification
                endRoute()
                showArrivedAlert()
            } else {
                // update the progress bar with the
                // current distance remaining
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
        createPath(from: currentLocation.coordinate, to: destinationLocation.coordinate ) { pathCreated in
            if self.oldRoute != nil && pathCreated {
                self.mapView.removeOverlay(self.oldRoute!)
            }
        }
        findBearings(userLocation: currentLocation.coordinate)
        oldRoute = routeOverlay
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
                self.clearPath()
                self.createPath(from: self.currentLocation.coordinate, to: coordinate) {_ in}
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

    func createPath(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
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
            guard let self = self else {
                completion(false)
                return
            }
            guard let response = response else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                completion(false)
                return
            }
            if let route = response.routes.first {
                self.currentRoute = route
                self.routeOverlay = self.currentRoute?.polyline
                self.mapView.addOverlay(self.routeOverlay!, level: .aboveRoads)
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    
    func clearPath() {
        if let routeOverlay = routeOverlay {
            mapView.removeOverlay(routeOverlay)
        }
        if let routeOverlay = oldRoute {
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

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
