//
//  RegistrationView.swift
//  FirebaseTest
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains registration page. This is linked to
// Firebase, and everything is set up.

// Please comment the changes you make and leave your name.
//
// Ryan Trimble: I made adjusments to the Firebase routes used to add users to the database after authenticating their credentials as well as added error message displays

import SwiftUI

struct RegistrationView: View {
    @State private var fullname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""

    @Binding var isRegistering: Bool
        @EnvironmentObject var authViewModel: AuthViewModel
        
    // Add password validation
    private var passwordsMatch: Bool {
        password == confirmPassword
    }

    var body: some View {
        VStack(spacing: 20) {
            Image("Logo")
                .padding() //.padding(.vertical, 32)

            TextField("Full Name", text: $fullname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Confirm Password", text: $confirmPassword)  // Added confirm password field
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                        
            if !passwordsMatch && !confirmPassword.isEmpty {  // Show mismatch warning
                Text("Passwords do not match")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Button(action: {
                Task {
                    do {
                        try await authViewModel.createUser(withEmail: email, password: password, fullname: fullname)
                        // Navigation handled by ContentView
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            Button(action: {
                isRegistering.toggle()
                errorMessage = ""
            }) {
                Text("Already have an account? Log in")
                    .foregroundColor(.blue)
            }
            .padding(.top)

            Spacer()
        }
        .padding(.top, 50)
    }
}
