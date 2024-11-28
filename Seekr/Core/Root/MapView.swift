//
//  MapView.swift
//  Seekr
//
//  Created by Taya Ambrose on 10/19/24.
//

import SwiftUI
import MapKit

// MARK: - ViewControllerRepresentable
struct ViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Update the view controller if needed
    }
}

// MARK: - MapView
struct MapView: View {
    @State private var showingNamePrompt = false
    @State private var pinName = ""
    @State private var tappedCoordinate: CLLocationCoordinate2D?
    @StateObject private var pinManager = PinDataManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                ViewControllerRepresentable()
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
