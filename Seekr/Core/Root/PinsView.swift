//
//  PinsView.swift
//  Seekr
//
//  Created by Taya Ambrose on 11/20/24.
//

import SwiftUI
import MapKit

// MARK: - Pin Data Manager
class PinDataManager: ObservableObject {
    @Published var pins: [PinAnnotation] = []
    @Published var selectedPin: PinAnnotation?
    
    // Predefined UCSC locations
    let ucscLocations: [PinAnnotation] = [
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9916, longitude: -122.0583), name: "McHenry Library"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9997, longitude: -122.0615), name: "Porter College"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9955, longitude: -122.0551), name: "Science Hill"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 37.0000, longitude: -122.0544), name: "Cowell College"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9921, longitude: -122.0637), name: "Oakes College"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9950, longitude: -122.0558), name: "Jack Baskin Engineering"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9977, longitude: -122.0517), name: "East Field"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9891, longitude: -122.0582), name: "Farm & Garden")
    ]
    
    static let shared = PinDataManager()
    
    func addPin(name: String, coordinate: CLLocationCoordinate2D) {
        let pin = PinAnnotation(coordinate: coordinate, name: name)
        pins.append(pin)
    }
    
    func addPresetPin(_ pin: PinAnnotation) {
        pins.append(pin)
        selectedPin = pin  // Select the newly added pin
    }
    
    func removePin(at index: Int) {
        pins.remove(at: index)
    }
    
    func removePin(withId id: UUID) {
        if let index = pins.firstIndex(where: { $0.id == id }) {
            pins.remove(at: index)
        }
    }
    
    func selectPin(_ pin: PinAnnotation) {
        selectedPin = pin
    }
    
    func isPinAdded(_ presetPin: PinAnnotation) -> Bool {
        pins.contains { pin in
            pin.name == presetPin.name &&
            abs(pin.coordinate.latitude - presetPin.coordinate.latitude) < 0.0001 &&
            abs(pin.coordinate.longitude - presetPin.coordinate.longitude) < 0.0001
        }
    }
}

// MARK: - Pin Card View
struct PinCard: View {
    let pin: PinAnnotation
    @ObservedObject private var pinManager = PinDataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(pin.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    pinManager.removePin(withId: pin.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                Text(String(format: "%.4f, %.4f",
                     pin.coordinate.latitude,
                     pin.coordinate.longitude))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .onTapGesture {
            pinManager.selectPin(pin)
            dismiss()
        }
    }
}

// MARK: - Preset Pin Card View
struct PresetPinCard: View {
    let pin: PinAnnotation
    @ObservedObject private var pinManager = PinDataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(pin.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if pinManager.isPinAdded(pin) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                Text("UCSC Location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .onTapGesture {
            if !pinManager.isPinAdded(pin) {
                pinManager.addPresetPin(pin)
                dismiss()
            }
        }
    }
}

// MARK: - Pins View
struct PinsView: View {
    @StateObject private var pinManager = PinDataManager.shared
    @State private var selectedSection = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Pin Type", selection: $selectedSection) {
                    Text("My Pins").tag(0)
                    Text("UCSC Locations").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    if selectedSection == 0 {
                        // My Pins Section
                        if pinManager.pins.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "mappin.slash.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No Pins Added Yet")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(pinManager.pins) { pin in
                                    PinCard(pin: pin)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    } else {
                        // UCSC Locations Section
                        LazyVStack(spacing: 16) {
                            ForEach(pinManager.ucscLocations) { pin in
                                PresetPinCard(pin: pin)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Pins")
        }
    }
}

#Preview {
    PinsView()
}
