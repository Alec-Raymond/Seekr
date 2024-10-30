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

struct MapView: View {
    // need to get the size in miles from the map
    // and calulate the percentage that the user is away
    // from the destination based on how much they
    // have moved
    
    @State private var progress_percentage = 0.2
    @State private var size = 10.0
    
    var body: some View {
        ViewControllerWrapper()
            .edgesIgnoringSafeArea(.all)
            .overlay {
                VStack {
                    ProgressView(value: progress_percentage)
                        .background(.gray)
                        .tint(.init(red: 0, green: 0, blue: 255))
                        .frame(width: 300, height: 50)
                    Spacer()
                }
            }
    }
}

struct ViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

#Preview {
    MapView()
}
