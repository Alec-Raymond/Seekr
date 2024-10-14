//
//  ContentView.swift
//  Seekr
//
//  Created by Alec Raymond on 10/3/24.
//

import SwiftUI
import CoreData
import MapKit

extension CLLocationCoordinate2D {
    static let ucsc = CLLocationCoordinate2D(latitude: 36.9905, longitude: -122.0584)
}

struct ContentView: View {
    var body: some View {
        Map {
            Annotation("UCSC", coordinate: .ucsc) {
                ZStack{
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.secondary, lineWidth: 5)
                    Image(systemName: "car")
                        .padding(5)
                }
            }
            .annotationTitles(.hidden)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
