//
//  ContentView.swift
//  Seekr
//
//  Created by Alec Raymond on 10/3/24.
//

// This file contains the basic structure of the app.
//
// Please comment any changes you make and your name.

// Ryan Trimble: The entry point is now routed through a new View called MainView() for logged in users.

import SwiftUI

struct ContentView: View {
    // AuthViewModel object used to track if a user is logged in via its private state userSession. If the user has an active session, the main home page is rendered. If not, the authenticationView() is rendered, which contains the LOGIN and REGISTRATION pages
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notificationsAllowed = true // Tracks notification permission status

    var body: some View {
        Group {
            if !notificationsAllowed {
                // Navigate to NotificationSettingsView if notifications are not allowed
                
                NotificationSettingsView(onPermissionChange: checkNotificationPermission)
            } else if authViewModel.userSession != nil {
                //Home page View
                MainView()
            } else {
                // Login/Registration page View
                AuthenticationView()
            }
        }
        // This onappear task ensures that no action for rendering is made until the result for the current user's session status is returned.
        // (This avoids redundant loading)
        .onAppear {
            Task {
                await authViewModel.fetchUser()
                checkNotificationPermission()

            }
        }
    }
    private func checkNotificationPermission() {
        NotificationManager.shared.checkForPermission { allowed in
            DispatchQueue.main.async {
                self.notificationsAllowed = allowed
            }
        }
    }
}

// Preview definition for testing local changes
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}

