//
//  SideMenu.swift
//  Seekr
//
//  Created by Ryan Trimble on 11/20/24.
//
//  This file contains the nav bar elements that are rendered when the toggle button is clicked on the MainView page. It acts as a hub for the rest of the features the app offers
//

import SwiftUI

struct SideMenu: View {
    @Binding var isVisible: Bool
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Profile Button (leads to Profile View)
            NavigationLink(destination: ProfileView()) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
            }
            .simultaneousGesture(TapGesture().onEnded {
                // Collapse the menu when navigation occurs
                withAnimation {
                    isVisible = false
                }
            })
            // View Pins Button
            NavigationLink(destination: PinsView()) { // Make sure you have created PinsView
                HStack {
                    Image(systemName: "mappin.circle.fill") // Using a pin icon
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("View Pins")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
            }
            .simultaneousGesture(TapGesture().onEnded {
                // Collapse the menu when navigation occurs
                withAnimation {
                    isVisible = false
                }
            })
            Spacer()
        }
        .padding(.top, 100)
        .padding(.horizontal, 20)
        .frame(minWidth: 200, maxWidth: 250, alignment: .leading)
        .background(Color("DarkBlue"))
        .cornerRadius(10, corners: [.topRight, .bottomRight])
        .shadow(radius: 5)
    }
}

// Preview for localized testing in Xcode
struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(isVisible: .constant(true))
            .environmentObject(AuthViewModel())
    }
}
