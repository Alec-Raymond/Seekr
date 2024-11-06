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

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let user = userData {
                Text("Welcome, \(user.fullname)")
                    .font(.title)
                    .bold()

                Text("Email: \(user.email)")
                    .foregroundColor(.gray)

                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Spacer()
            } else {
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
        .onAppear {
            loadUserData()
        }
    }

    private func loadUserData() {
        Task {
            isLoading = true
            await authViewModel.fetchUser()
            userData = authViewModel.currentUser
            isLoading = false
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}


//import SwiftUI
//
//struct ProfileView: View {
//    var body: some View {
//        List {
//            Section {
//                HStack {
//                    Text(User.TEST_USER.initials)
//                        .font(.title)
//                        .fontWeight(.semibold)
//                        .foregroundColor(Color(.white))
//                        .frame(width: 72, height: 72)
//                        .background(Color(.blue.opacity(0.7)))
//                        .clipShape(Circle())
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(User.TEST_USER.fullname)
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .padding(.top, 4)
//                        
//                        Text(User.TEST_USER.email)
//                            .font(.footnote)
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            
//            Section("General") {
//                HStack {
//                    SettingsRowView(imageName: "gear",
//                                    title: "Version",
//                                    tintColor: .accentColor)
//                    Spacer()
//                    Text("1.0.0")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            Section("Account") {
//                Button {
//                    print("Sign out")
//                } label: {
//                    SettingsRowView(imageName: "arrow.left.circle.fill",
//                                    title: "Sign out",
//                                    tintColor: .accentColor)
//                }
//                
//                Button {
//                    print("Delete account")
//                } label: {
//                    SettingsRowView(imageName: "xmark.circle.fill",
//                                    title: "Delete account",
//                                    tintColor: .red)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    ProfileView()
//}
