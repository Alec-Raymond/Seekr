//
//  AuthViewModel.swift
//  Seekr
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains authentication methods for login and
// user creation. I am having some issues here so far, and
// this is not done. Firebase is not able to fully register
// the user group due to "insufficient permissions."

// Please comment the changes you make and leave your name.

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser // this keeps user logged in. put in if wanted
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        print("sign in")
    }
    
//    func createUser(withEmail email: String, password: String, fullname: String) async throws {
//        do {
//            let result = try await Auth.auth().createUser(withEmail: email, password: password)
//            self.userSession = result.user
//            let user = User(id: result.user.uid, fullname: fullname, email: email)
//            let encodedUser = try Firestore.Encoder().encode(user)
//            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
//        } catch {
//            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
//        }
//    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error // Re-throw the error to the caller
        }
    }
    
    func signOut() {
        print("sign out")
    }
    
    func deleteAccount() {
        print("delete")
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
    }
}
