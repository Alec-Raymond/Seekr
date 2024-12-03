//
//  NotificationSettingsView.swift
//  Seekr
//
//  Created by Lisa Systaliuk on 12/2/24.
//
import SwiftUI

struct NotificationSettingsView: View {
    var onPermissionChange: (() -> Void)? // Callback to notify ContentView of permission changes
    @State private var showSettingsAlert = false
    private let notificationManager = NotificationManager.shared

    var body: some View {
        VStack {
            Text("Notifications are disabled.")
                .font(.title)
                .padding()

            Button("Enable Notifications") {
                notificationManager.checkForPermission { allowed in
                    if !allowed {
                        showSettingsAlert = true
//                        print(allowed)
                    } else {
                        onPermissionChange?() // Trigger permission change callback
                    }
                }
            }
            .alert(isPresented: $showSettingsAlert) {
                Alert(
                    title: Text("Notifications Disabled"),
                    message: Text("Please enable notifications in Settings to proceed."),
                    primaryButton: .default(Text("Open Settings")) {
                        notificationManager.openAppNotificationSettings()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .padding()
    }
}

