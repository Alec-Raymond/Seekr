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
    
    static let shared = PinDataManager()
    
    func addPin(name: String, coordinate: CLLocationCoordinate2D) {
        let pin = PinAnnotation(coordinate: coordinate, name: name)
        pins.append(pin)
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

// MARK: - Pins View
struct PinsView: View {
    @StateObject private var pinManager = PinDataManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
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
            }
            .navigationTitle("My Pins")
        }
    }
}

#Preview {
    PinsView()
}
