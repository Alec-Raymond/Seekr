//
//  ProfileView.swift
//  FirebaseTest
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains the user profile page for the app.
// So far it has fields for displaying general version of
// the app and options to sign out (not done) and delete
// account (not done). This is all subject to change.

// Please comment the changes you make and leave your name.

// Ryan: Integrated new account signout and deletion functions

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var userData: AppUser?
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showCopiedAlert = false
    
    private var initials: String {
        guard let fullname = userData?.fullname else {return ""}
        return parseInitials(from: fullname)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
            else if let user = userData {
                List {
                    Section {
                        HStack {
                            if #available(iOS 17.0, *) {
                                Text(initials)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.white))
                                    .frame(width: 72, height: 72)
                                    .background(Color(.blue.opacity(0.7)))
                                    .clipShape(Circle())
                            } else {
                                // Fallback on earlier versions
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear",
                                          title: "Version",
                                          tintColor: .accentColor)
                            Spacer()
                            Text("1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Share link feature, allows for users to invite their friends to promote app community growth
                    Section("Share") {
                        Button {
                            let inviteMessage = "Join me on Seekr! Download the app and start exploring: [App Store Link Here]"
                            UIPasteboard.general.string = inviteMessage
                            showCopiedAlert = true
                        } label: {
                            SettingsRowView(imageName: "square.and.arrow.up",
                                          title: "Invite Friends",
                                          tintColor: .accentColor)
                        }
                    }
                    
                    // Account Sign Out and Deletion buttons (routes imported from AuthViewModel)
                    Section("Account") {
                        Button {
                            Task{
                                authViewModel.signOut()
                            }
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill",
                                          title: "Sign out",
                                          tintColor: .accentColor)
                        }
                        
                        Button {
                            Task{
                                try await
                                authViewModel.deleteAccount()
                            }
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill",
                                          title: "Delete account",
                                          tintColor: .red)
                        }
                    }
                }
            }
            // This else case is only reachable if a user somehow is not logged in or has incomplete/corrupted account data in the DB
            // In the event of this, cached data should be wiped to reset the session
            else {
                Text("No user data available.")
                    .foregroundColor(.gray)
                    .padding()
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        .padding()
        .navigationTitle("Profile")
        .task {
            await loadUserData()
        }
        .alert("Copied to Clipboard", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Invitation message has been copied to your clipboard")
        }
    }

    //Fetch user data to be used to populate that user's profile page
    private func loadUserData() async {
        Task {
            isLoading = true
            await authViewModel.fetchUser()
            userData = authViewModel.currentUser
            isLoading = false
        }
    }
    
    // Strip the initials from the user's name to format to be displayed
    private func parseInitials(from fullname: String) -> String{
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
