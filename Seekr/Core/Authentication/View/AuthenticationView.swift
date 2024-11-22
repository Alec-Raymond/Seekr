//
//  AuthenticationView.swift
//  Seekr
//
//  Created by Ryan Trimble on 11/6/24.
//

// This file serves as a singular entry point for the login/registration
// views, and handles deciding between the two accordingly

import SwiftUI

struct AuthenticationView: View {
    @State private var isRegistering = false // Toggle between login and register pages
        // False = Login page
        // True = Registration page

    var body: some View {
        VStack {
            // isRegistering determines which view gets rendered/served to the user. Toggled via the button at the bottom of these views
            if isRegistering {
                RegistrationView(isRegistering: $isRegistering)
            } else {
                LoginView(isRegistering: $isRegistering)
            }
        }
        .animation(.easeInOut, value: isRegistering) // Smooth transition
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthViewModel())
    }
}
