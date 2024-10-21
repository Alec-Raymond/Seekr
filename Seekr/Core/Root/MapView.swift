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
    var body: some View {
        // Text("Map here? Landing page?")
        
        NavigationStack {
            Text("Map here? Landing page?")
            NavigationLink{
                ProfileView()
                    //.navigationBarBackButtonHidden()
            } label: {
                HStack(spacing: 3){
                    Text("Go to user profile")
                        .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    MapView()
}
