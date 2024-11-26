//
//  MapView.swift
//  Seekr
//
//  Created by Taya Ambrose on 10/19/24.
//

// This is the entry point for the map feature, which runs through ViewController()

// Please comment any changes you make and your name.

import SwiftUI

struct MapView: View {
    var body: some View {
        ViewControllerWrapper()
            .edgesIgnoringSafeArea(.all)
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
