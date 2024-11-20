//
//  MainView.swift
//  Seekr
//
//  Created by Ryan Trimble on 11/20/24.
//
// This file contains the home page for the map service
// This includes the map component, search bar, and nav
// bar to access the rest of the app's functionalities

import SwiftUI
import MapKit

struct MainView: View {
    @State private var isSideMenuVisible: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // Map View as the background
                MapView()
                    .ignoresSafeArea()
                
                // Overlay with toggle button and side menu
                HStack(spacing: 0) {
                    // Side Menu
                    SideMenu(isVisible: $isSideMenuVisible)
                        .offset(x: isSideMenuVisible ? 0 : -250) // Adjust based on side menu width
                        .animation(.easeInOut(duration: 0.3), value: isSideMenuVisible)
                    
                    // Spacer to cover the rest of the screen when menu is visible
                    if isSideMenuVisible {
                        Color.black.opacity(0.3)
                            .onTapGesture {
                                withAnimation {
                                    isSideMenuVisible = false
                                }
                            }
                            .transition(.opacity)
                    }
                }
                
                // Toggle Button for side menu
                Button(action: {
                    withAnimation {
                        isSideMenuVisible.toggle()
                    }
                }) {
                    // Styling for button icon and animation for moving with the fadein/out of the navigation bar
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("DarkBlue").opacity(0.7))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding()
                .offset(x: isSideMenuVisible ? 220 : 0) // Adjust based on side menu width
                .animation(.easeInOut(duration: 0.3), value: isSideMenuVisible)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthViewModel())
    }
}

