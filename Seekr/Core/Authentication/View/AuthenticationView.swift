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
    @State private var isRegistering = false // Toggle between login and register

    var body: some View {
        VStack {
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
