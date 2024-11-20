//
//  MapView.swift
//  Seekr
//
//  Created by Taya Ambrose on 10/19/24.
//

// This file I created as a landing page for the app.
// I thought we could put stats, history, or a map
// here. This page is not done. It is linked to the
// user profile.

// Please comment any changes you make and your name.

import SwiftUI
import MapKit
import UIKit
// MARK: - Custom ViewController
class MapViewController: UIViewController, MKMapViewDelegate {
    private var mapView: MKMapView!
    private var pins: [PinAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup MapView
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.frame = view.bounds
        
        // Set initial region
        let initialLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
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
    }
    
    @objc func handleAddPin(_ notification: Notification) {
        guard let name = notification.userInfo?["name"] as? String else { return }
        
        // Get the center coordinate of the current map view
        let centerCoordinate = mapView.centerCoordinate
        
        let pin = PinAnnotation(coordinate: centerCoordinate, name: name)
        pins.append(pin)
        
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
            mapView.removeAnnotation(annotation)
            if let index = pins.firstIndex(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
                pins.remove(at: index)
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
