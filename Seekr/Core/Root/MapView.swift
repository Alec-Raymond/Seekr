//
//  MapView.swift
//  Seekr
//
//  Created by Taya Ambrose on 10/19/24.
//

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
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
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
    
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowPinPrompt"),
            object: nil,
            userInfo: ["coordinate": coordinate]
        )
    }
    
    private func centerMapOnPin(_ pin: PinAnnotation) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let region = MKCoordinateRegion(
                center: pin.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            self.mapView.setRegion(region, animated: true)
            
            if let annotation = self.mapView.annotations.first(where: {
                $0.coordinate.latitude == pin.coordinate.latitude &&
                $0.coordinate.longitude == pin.coordinate.longitude
            }) {
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    private func updateMapAnnotations(pins: [PinAnnotation]) {
        mapView.removeAnnotations(mapView.annotations)
        
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
        guard let name = notification.userInfo?["name"] as? String,
              let coordinate = notification.userInfo?["coordinate"] as? CLLocationCoordinate2D else { return }
        
        pinManager.addPin(name: name, coordinate: coordinate)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
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
    @State private var tappedCoordinate: CLLocationCoordinate2D?
    @StateObject private var pinManager = PinDataManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                ViewControllerWrapper(showingNamePrompt: $showingNamePrompt, pinName: $pinName)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        NotificationCenter.default.addObserver(
                            forName: NSNotification.Name("ShowPinPrompt"),
                            object: nil,
                            queue: .main
                        ) { notification in
                            if let coordinate = notification.userInfo?["coordinate"] as? CLLocationCoordinate2D {
                                tappedCoordinate = coordinate
                                showingNamePrompt = true
                            }
                        }
                    }
                
                VStack {
                    ProgressView(value: progress_percentage)
                        .background(.gray)
                        .tint(.init(red: 0, green: 0, blue: 255))
                        .frame(width: 300, height: 50)
                    
                    Spacer()
                }
            }
            .alert("Name Your Pin", isPresented: $showingNamePrompt) {
                TextField("Enter pin name", text: $pinName)
                Button("Cancel", role: .cancel) { }
                Button("Add Pin") {
                    if let coordinate = tappedCoordinate {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("AddPin"),
                            object: nil,
                            userInfo: [
                                "name": pinName,
                                "coordinate": coordinate
                            ]
                        )
                        pinName = ""
                        tappedCoordinate = nil
                    }
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
