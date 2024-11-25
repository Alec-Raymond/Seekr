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
    
    let bathrooms: [PinAnnotation] = [
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9634, longitude: -122.0216), name: "Pacific Avenue Public Restroom (Downtown)"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9641, longitude: -122.0251), name: "Locust Street Garage Restroom"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9627, longitude: -122.0251), name: "Cedar Street Parking Garage Restroom"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9509, longitude: -122.0486), name: "Cowell Beach Restroom"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9580, longitude: -122.0250), name: "Lighthouse Field State Beach Restroom"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9644, longitude: -122.0107), name: "San Lorenzo Park Restroom"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9622, longitude: -122.0248), name: "Abbott Square Market Restroom"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9647, longitude: -122.0214), name: "Santa Cruz Metro Station Restroom"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9621, longitude: -122.0273), name: "Wharf Public Restroom"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9571, longitude: -122.0258), name: "West Cliff Drive Public Restroom")
    ]
    
    let coffeeShops: [PinAnnotation] = [
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9728, longitude: -122.0250), name: "Santa Cruz Coffee Roasters"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9744, longitude: -122.0263), name: "Verve Coffee Roasters (Downtown)"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9680, longitude: -122.0233), name: "Verve Coffee Roasters"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9712, longitude: -122.0257), name: "11th Hour Coffee"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9719, longitude: -122.0261), name: "Shrine Coffee"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9725, longitude: -122.0255), name: "Mariposa Coffee Bar"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9736, longitude: -122.0244), name: "Cafe Delmarette"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9621, longitude: -122.0248), name: "Cat & Cloud Coffee"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9509, longitude: -122.0486), name: "Steamer Lane Supply"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9497, longitude: -122.0570), name: "11th Hour Coffee Westside"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9725, longitude: -122.0259), name: "The Abbey Coffee Lounge"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9716, longitude: -122.0241), name: "Hidden Fortress Coffee @ Cruzio"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9683, longitude: -122.0232), name: "Alta Organic Coffee Warehouse & Roasting Co."),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9717, longitude: -122.0252), name: "Firefly Coffee House"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9720, longitude: -122.0256), name: "Peoples Coffee"),
        PinAnnotation(coordinate: CLLocationCoordinate2D(latitude: 36.9713, longitude: -122.0248), name: "Lulu's On Mission")
    ]
    
    static let shared = PinDataManager()
    
    func addPin(name: String, coordinate: CLLocationCoordinate2D) {
        let pin = PinAnnotation(coordinate: coordinate, name: name)
        pins.append(pin)
    }
    
    func addPresetPin(_ pin: PinAnnotation) {
        pins.append(pin)
        selectedPin = pin
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

struct LocationTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(8)
        }
        .foregroundColor(.primary)
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
            if !pinManager.isPinAdded(pin) {
                pinManager.addPresetPin(pin)
                dismiss()
            }
        }
    }
}

// MARK: - Search Bar View
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search locations...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - Pins View
struct PinsView: View {
    @StateObject private var pinManager = PinDataManager.shared
    @State private var selectedSection = 0
    @State private var selectedLocationType = 0
    @State private var searchText = ""
    
        var filteredLocations: [PinAnnotation] {
            let locations: [PinAnnotation]
            switch selectedLocationType {
            case 0:
                locations = pinManager.ucscLocations + pinManager.coffeeShops + pinManager.bathrooms
            case 1:
                locations = pinManager.ucscLocations
            case 2:
                locations = pinManager.coffeeShops
            case 3:
                locations = pinManager.bathrooms
            default:
                locations = []
            }
            
            if searchText.isEmpty {
                return locations
            }
            return locations.filter { pin in
                pin.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        var body: some View {
            NavigationStack {
                VStack {
                    Picker("Pin Type", selection: $selectedSection) {
                        Text("My Pins").tag(0)
                        Text("Add Locations").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if selectedSection == 1 {
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    LocationTypeButton(title: "All", isSelected: selectedLocationType == 0) {
                                        selectedLocationType = 0
                                    }
                                    LocationTypeButton(title: "UCSC", isSelected: selectedLocationType == 1) {
                                        selectedLocationType = 1
                                    }
                                    LocationTypeButton(title: "Coffee", isSelected: selectedLocationType == 2) {
                                        selectedLocationType = 2
                                    }
                                    LocationTypeButton(title: "Bathrooms", isSelected: selectedLocationType == 3) {
                                        selectedLocationType = 3
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                            SearchBar(text: $searchText)
                        }
                    }
                                    
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
                        // Locations Section
                        LazyVStack(spacing: 16) {
                            ForEach(filteredLocations) { pin in
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
