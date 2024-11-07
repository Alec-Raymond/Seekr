//
//  RegistrationView.swift
//  FirebaseTest
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains registration page. This is linked to
// Firebase, and everything is set up.

// Please comment the changes you make and leave your name.

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



//import SwiftUI
//
//struct RegistrationView: View {
//    @State private var email: String = ""
//    @State private var fullname: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var viewModel: AuthViewModel
//    
//    var body: some View {
//        VStack {
//            // Image
//            Image("Logo")
//                .padding() //.padding(.vertical, 32)
//            
//            VStack(spacing: 24){
//                InputView(text: $email,
//                          title: "Email Address",
//                          placeholder: "Enter your email")
//                //.autocapitalization(.none)
//                
//                InputView(text: $fullname,
//                          title: "Name",
//                          placeholder: "Enter your full name")
//                
//                InputView(text: $password,
//                          title: "Password",
//                          placeholder: "Enter your password",
//                          isSecureField: true)
//                
//                InputView(text: $confirmPassword,
//                          title: "Confirm Password",
//                          placeholder: "Confirm your password",
//                          isSecureField: true)
//            }
//            .padding(.horizontal)
//            .padding(.top, 12)
//            
//            Button{
//                Task {
//                    try await viewModel.createUser(withEmail: email, password: password, fullname: fullname)
//                }
//            } label: {
//                HStack{
//                    Text("Sign up")
//                        .fontWeight(.semibold)
//                }
//                .foregroundColor(.white)
//                .frame(width: UIScreen.main.bounds.width - 32, height: 48) // flag
//            }
//            .background(Color(.blue))
//            .cornerRadius(10)
//            .padding()
//            
//            Spacer()
//            
//            Button {
//                dismiss()
//            } label: {
//                HStack(spacing: 3){
//                    Text("Already have an account?")
//                    Text("Sign in")
//                        .fontWeight(.bold)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    RegistrationView()
//}
