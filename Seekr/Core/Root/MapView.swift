//
//  MapView.swift
//  Seekr
//
//  Created by Taya Ambrose on 10/19/24.
//

// This is the entry point for the map feature, which runs through ViewController()

// Please comment any changes you make and your name.


import SwiftUI
import MapKit
import UIKit
import Combine

// MARK: - Custom ViewController
class MapViewController: UIViewController, MKMapViewDelegate {
    private var mapView: MKMapView!
    private let pinManager = PinDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup MapView
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.frame = view.bounds
        
        // Set initial region
        let initialLocation = CLLocationCoordinate2D(latitude: 36.9741, longitude: -122.0308)
        let region = MKCoordinateRegion(
            center: initialLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        mapView.setRegion(region, animated: true)
        
        // Observe for pin addition
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAddPin(_:)),
            name: NSNotification.Name("AddPin"),
            object: nil
        )
        
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
        
        // Display existing pins
        displayExistingPins()
    }
    
    private func centerMapOnPin(_ pin: PinAnnotation) {
        // Add a small delay to ensure the view is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // Create a slightly larger region to ensure the pin is visible
            let region = MKCoordinateRegion(
                center: pin.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            // Animate to the new region
            self.mapView.setRegion(region, animated: true)
            
            // Find and select the corresponding annotation
            if let annotation = self.mapView.annotations.first(where: {
                $0.coordinate.latitude == pin.coordinate.latitude &&
                $0.coordinate.longitude == pin.coordinate.longitude
            }) {
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    private func updateMapAnnotations(pins: [PinAnnotation]) {
        // Remove all existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Add new annotations for current pins
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.name
            mapView.addAnnotation(annotation)
        }
    }
    
    func displayExistingPins() {
        for pin in pinManager.pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.name
            mapView.addAnnotation(annotation)
        }
    }
    
    @objc func handleAddPin(_ notification: Notification) {
        guard let name = notification.userInfo?["name"] as? String else { return }
        
        // Get the center coordinate of the current map view
        let centerCoordinate = mapView.centerCoordinate
        
        // Add pin to shared manager instead of local array
        pinManager.addPin(name: name, coordinate: centerCoordinate)
        
        // Add annotation to map
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoordinate
        annotation.title = name
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "PinAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            // Add delete button
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
}

// MARK: - Model
struct PinAnnotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var name: String
}

// MARK: - ViewControllerWrapper
struct ViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MapViewController
    
    @Binding var showingNamePrompt: Bool
    @Binding var pinName: String
    
    func makeUIViewController(context: Context) -> MapViewController {
        let viewController = MapViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        // Update the view controller if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ViewControllerWrapper
        
        init(_ parent: ViewControllerWrapper) {
            self.parent = parent
        }
    }
}

// MARK: - MapView
struct MapView: View {
    @State private var progress_percentage = 0.2
    @State private var showingNamePrompt = false
    @State private var pinName = ""
    @StateObject private var pinManager = PinDataManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                ViewControllerWrapper(showingNamePrompt: $showingNamePrompt, pinName: $pinName)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Progress overlay
                    ProgressView(value: progress_percentage)
                        .background(.gray)
                        .tint(.init(red: 0, green: 0, blue: 255))
                        .frame(width: 300, height: 50)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        // Add Pin Button
                        Button(action: {
                            showingNamePrompt = true
                        }) {
                            Text("Add Pin")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        // View Pins Button
                        NavigationLink(destination: PinsView()) {
                            Text("View Pins")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .alert("Name Your Pin", isPresented: $showingNamePrompt) {
                TextField("Enter pin name", text: $pinName)
                Button("Cancel", role: .cancel) { }
                Button("Add Pin") {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("AddPin"),
                        object: nil,
                        userInfo: ["name": pinName]
                    )
                    pinName = ""
                }
            } message: {
                Text("Please enter a name for your pin")
            }
        }
    }
}

#Preview {
    MapView()
}
