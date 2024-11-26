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

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var userData: AppUser?
    @State private var isLoading = false
    @State private var errorMessage = ""
    
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
    }

    private func loadUserData() async {
        Task {
            isLoading = true
            await authViewModel.fetchUser()
            userData = authViewModel.currentUser
            isLoading = false
        }
    }
    private func parseInitials(from fullname: String) -> String{
            let formatter = PersonNameComponentsFormatter()
            if let components = formatter.personNameComponents (from: fullname) {
                formatter.style = .abbreviated
                return formatter.string (from: components)
            }
            return ""
        }
    }


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
