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


class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var searchCompleter = MKLocalSearchCompleter()
    let compassImageView = UIImageView(image: UIImage(named: "compass.png"))
    var searchResults = [MKLocalSearchCompletion]()
    var annotationList = [MKPointAnnotation]()
    var tableView = UITableView()
    var routeOverlay: MKPolyline?
    var userCentered = false
    let geocoder = CLGeocoder()
    var lastLocation = CLLocation()
    var lastHeading = CGFloat()
    var lastBearing = CGFloat()
    var destinationLocation = CLLocation()
    var destinationDistance = CLLocationDistance()
    // Zander added: haveDestination to keep track if the
    // user is currently navigating or has not yet started
    // their route
    var haveDestination = false
    
    let locationManager = CLLocationManager()
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        // map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    // Zander added: Go Button
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("GO", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(ViewController.self, action: #selector(buttonPressed), for: .touchUpInside)
        // ^ Don't listen to the warning
        return button
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
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        searchCompleter.delegate = self
        mapView.delegate = self
        
        tableView.delegate = self // Set the delegate
        tableView.dataSource = self
        setupUI()
        centerViewOnUserLocation()
    }
//    override func viewDidAppear(_ animated: Bool) {
//        centerViewOnUserLocation()
//    }
    
    private var searchTextFieldBottomConstraint: NSLayoutConstraint!
    private var tableViewTopConstraint: NSLayoutConstraint!
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        view.addSubview(compassImageView)
        view.addSubview(button)
        view.addSubview(progressView)
        
        // Zander added: Center Go Button
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Zander added: Center Progress Bar
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
        button.isHidden = false
    }
    
    // Zander added: hide Go Button
    func hideGoButton() {
        button.isHidden = true
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        lastLocation = currentLocation

        // Zander added: calculate distance remaining if
        // we have a destination
        if haveDestination {
            let distanceRemaining = currentLocation.distance(from: destinationLocation)
            if distanceRemaining < 50 { // need to fine tune
                haveDestination = false
                hidePBar()
                // we have arrived, do something here
                print("you have arrived")
                
            } else {
                // Zander added: update the progress bar with the
                // current distance remaining
                updateProgressBar(distanceRemaining: distanceRemaining)
            }
        }
    }
    
    // Why do we have two location manager functions
    // with the same name?
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.lastHeading = CGFloat(newHeading.magneticHeading) * .pi / 180
        UIView.animate(withDuration: 0.5) {
            self.compassImageView.transform = CGAffineTransform(rotationAngle: self.lastBearing - self.lastHeading)
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
        //Lisa: changed the centerview on user location
        centerViewOnUserLocation()
    }

    let scale: CGFloat = 300

    private func centerViewOnUserLocation() {
        if let coordinate = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: coordinate,
                                                 latitudinalMeters: scale,
                                                 longitudinalMeters: scale)
            mapView.setRegion(region, animated: true)
        }
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
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    // Zander: if we don't need this section can we delete
    // it rather than having a huge comment in the middle
    // of our code?
    
    //Lisa: Commented out
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedResult = searchResults[indexPath.row]
//        print("Selected: \(selectedResult.title), \(selectedResult.subtitle)")
//        
//        // Handle the selected result (e.g., perform a search, update UI, etc.)
//        convertAddressToAnnotation(name: selectedResult.title, address: selectedResult.subtitle, camera: true, path: true)
//        //centerMapOnCoordinates(coord1: annotationList.last?.coordinate, coord2: <#T##CLLocationCoordinate2D#>)
//    }
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
            let name = mapItem.name ?? selectedResult.title
            
            
            
            self.mapView.removeAnnotations(self.annotationList)
            self.annotationList.removeAll()
            

            let annotation = MKPointAnnotation()//use mkpoint to display possible locations
            annotation.coordinate = coordinate
            annotation.title = name
            self.mapView.addAnnotation(annotation)
            self.annotationList.append(annotation)
            
            // center the map -> call centermap on coordinates
            if let userLocation = self.locationManager.location?.coordinate {
                self.centerMapOnCoordinates(coord1: userLocation, coord2: coordinate)
                self.clearPath()
                self.createPath(from: userLocation, to: coordinate)
            }
            
            // clear search results
            self.searchResults = []
            self.tableView.reloadData()
            // hide keyboard when not in uses
            self.searchTextField.resignFirstResponder()
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
                if let userLocation = self.locationManager.location?.coordinate {
                    self.centerMapOnCoordinates(coord1: userLocation, coord2: coordinate)
                }
            }
            if (path) {
                if let userLocation = self.locationManager.location?.coordinate {
                    self.clearPath()
                    self.createPath(from: userLocation, to: coordinate)
                }
            }
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
        let bearing = calculateBearing(from: coord1, to: coord2)
        destinationLocation = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        destinationDistance = distance
        //center.longitude = center.longitude + (abs(distance) / 50000)
        camera.centerCoordinate = center
        camera.centerCoordinateDistance = 4.0 * distance
        camera.heading = bearing
        
        mapView.setCamera(camera, animated: true)
        
        // Zander added: show Go button after map path is
        // centered
        showGoButton()
    }
    
    func calculateBearing(from coordinate1: CLLocationCoordinate2D, to coordinate2: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaLongitude = coordinate2.longitude - coordinate1.longitude
        let y = sin(deltaLongitude) * cos(coordinate2.latitude)
        let x = cos(coordinate1.latitude) * sin(coordinate2.latitude) - sin(coordinate1.latitude) * cos(coordinate2.latitude) * cos(deltaLongitude)
        lastBearing = atan2(y, x)
        let compassBearing = (lastBearing * 180 / .pi + 360).truncatingRemainder(dividingBy: 360) // Normalize to 0-360
        // print(compassBearing)
        return compassBearing
    }

    func createPath(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .automobile

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

            let route = response.routes[0]
            self.routeOverlay = route.polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)

            var regionRect = route.polyline.boundingMapRect
            let wPadding = regionRect.size.width * 0.25
            let hPadding = regionRect.size.height * 0.25

            regionRect.size.width += wPadding
            regionRect.size.height += hPadding

            // self.mapView.setRegion(MKCoordinateRegion(regionRect), animated: true)
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

