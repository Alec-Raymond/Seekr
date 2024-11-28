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
    @State private var isEndRouteMenuVisible: Bool = false
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
                
                VStack(alignment: .leading, spacing: 16) {
                    // Toggle Button for side menu
                    Button(action: {
                        withAnimation {
                            isSideMenuVisible.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 60, height: 60)
                            .background(Color("DarkBlue").opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .animation(.easeInOut(duration: 0.3), value: isSideMenuVisible)
                    
                    // Zander added: Button to open End Route Menu
                    Button(action: {
                        withAnimation {
                            // Button only works if side menu is closed
                            if (isSideMenuVisible == false) {
                                isEndRouteMenuVisible.toggle()
                            }
                        }
                    }) {
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 60, height: 60)
                            .background(isSideMenuVisible ? Color("DarkBlue").opacity(0.7) : Color.red.opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .animation(.easeInOut(duration: 0.3), value: isEndRouteMenuVisible)
                }
                .padding()
                .offset(x: isSideMenuVisible ? 220 : 0)
                
                // Zander added: End Route Menu
                if isEndRouteMenuVisible {
                    EndRouteMenu(isVisible: $isEndRouteMenuVisible)
                        .frame(maxWidth: 200)
                        .transition(.move(edge: .trailing))
                        .shadow(radius: 5)
                        .offset(y: 75)
                }
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

