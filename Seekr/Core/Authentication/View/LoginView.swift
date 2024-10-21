//
//  LoginView.swift
//  FirebaseTest
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains the login page. This is currently not
//fully complete. The sign in button is not set up yet.
// Waiting on Database things.

// Please comment the changes you make and leave your name.

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue
                    .ignoresSafeArea()
                Circle()
                    .scale(1.8)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.45)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.25)
                    .foregroundColor(.white)
                
                VStack {
                    // Image
                    Image("Logo")
                        .padding() //.padding(.vertical, 32)
                    
                    // Form Fields
                    VStack(spacing: 24){
                        InputView(text: $email,
                                  title: "Email Address",
                                  placeholder: "Enter your email")
                        // .autocapitalisation(.none)
                        
                        InputView(text: $password,
                                  title: "Password",
                                  placeholder: "Enter your password",
                                  isSecureField: true)
                    }
                    .padding(.horizontal,30)
                    .padding(.top, 12)
                    
                    // Sign in button -- not done
                    
                    Button{
                        Task {
                            try await viewModel.signIn(withEmail: email, password: password)
                        }
                    } label: {
                        HStack{
                            Text("Sign in")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48) // flag
                    }
                    .background(Color(.blue))
                    .cornerRadius(10)
                    .padding()
                    
                    //Spacer() // makes logo at top
                    
                    // Sign up button
                    
                    NavigationLink{
                        RegistrationView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack(spacing: 3){
                            Text("Don't have an account?")
                            Text("Sign up")
                                .fontWeight(.bold)
                        }
                    }
            }
                
            }
        }
    }
}

#Preview {
    LoginView()
}
