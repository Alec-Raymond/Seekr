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
    var searchResults = [MKLocalSearchCompletion]()
    var annotationList = [MKPointAnnotation]()
    var tableView = UITableView()
    var routeOverlay: MKPolyline?
    var userCentered = false
    let geocoder = CLGeocoder()
    
    let locationManager = CLLocationManager()
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        // map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
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
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        
        searchTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.2).isActive = true
        searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 600).isActive = true
        searchTextField.returnKeyType = .go
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                
        tableView.dataSource = self
        
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 400).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

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
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let temp = completer.results.filter { !($0.subtitle.contains("Search Nearby")) && !($0.subtitle.contains("No Results Nearby")) && !$0.subtitle.isEmpty }
        searchResults = temp
        print(searchResults.last?.subtitle)
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
        let camera = MKMapCamera()
        
        let midLatitude = (2.4 * coord1.latitude + coord2.latitude) / 3.4
        let midLongitude = (2.4 * coord1.longitude + coord2.longitude) / 3.4
        let center = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)
        
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        let distance = location1.distance(from: location2)
        let bearing = calculateBearing(from: coord1, to: coord2)
        
        print(distance)
        //center.longitude = center.longitude + (abs(distance) / 50000)
        camera.centerCoordinate = center
        camera.centerCoordinateDistance = 5.0 * distance
        camera.heading = bearing
        
        mapView.setCamera(camera, animated: true)
    }
    
    func calculateBearing(from coordinate1: CLLocationCoordinate2D, to coordinate2: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaLongitude = coordinate2.longitude - coordinate1.longitude
        let y = sin(deltaLongitude) * cos(coordinate2.latitude)
        let x = cos(coordinate1.latitude) * sin(coordinate2.latitude) - sin(coordinate1.latitude) * cos(coordinate2.latitude) * cos(deltaLongitude)
        let initialBearing = atan2(y, x) * 180 / .pi
        let compassBearing = (initialBearing + 360).truncatingRemainder(dividingBy: 360) // Normalize to 0-360
        print(compassBearing)
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
    
