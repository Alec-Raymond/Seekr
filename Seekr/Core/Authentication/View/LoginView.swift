//
//  LoginView.swift
//  FirebaseTest
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains the login page.

// Please comment the changes you make and leave your name.

// Ryan Trimble: I handled linking the updated AuthViewModel functions for logging in users to our current implementation for the LoginView in collaboration with Taya who handled designing/updating the UI

import SwiftUI

struct LoginView: View {
    // State variables for login fields and error message
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    @Binding var isRegistering: Bool
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color.blue
                    .ignoresSafeArea()
                                
                // Decorative circles
                Circle()
                    .scale(1.8)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.45)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.25)
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    // Logo image
                    Image("Logo")
                        .padding() //.padding(.vertical, 32)

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        Task {
                            do {
                                try await authViewModel.signIn(withEmail: email, password: password)
                                // Navigation handled by ContentView
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("Login")
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
                        Text("Don't have an account? Register")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isRegistering: .constant(false))
            .environmentObject(AuthViewModel())
    }
}
