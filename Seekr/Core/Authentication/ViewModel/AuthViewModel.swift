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

// Renamed 'User' to 'AppUser' to avoid conflict with FirebaseAuth.User
struct AppUser: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    var fullname: String
    var email: String
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: AppUser? // Updated to AppUser
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        self.userSession = auth.currentUser
        Task {
            await fetchUser()
        }
    }
    
    // Sign In Function
    func signIn(withEmail email: String, password: String) async throws {
        do {
            print("Attempting to sign in user...")
            let result = try await auth.signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("User signed in successfully: \(result.user.email ?? "No Email")")
            await fetchUser() // Fetch user data after sign-in
        } catch {
            print("DEBUG: Failed to sign in user with error \(error.localizedDescription)")
            throw error // Re-throw the error to handle it in the UI
        }
    }
    
    // Create User Function to register new accounts
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            print("Attempting to create user...")
            let result = try await auth.createUser(withEmail: email, password: password)
            self.userSession = result.user
            print("User created successfully: \(result.user.email ?? "No Email")")
            
            // Create AppUser model
            let user = AppUser(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            
            // Save user data to Firestore
            try await db.collection("users").document(user.id!).setData(encodedUser)
            self.currentUser = user
            print("User data saved to Firestore.")
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error // Re-throw the error to handle it in the UI
        }
    }
    
    // Sign Out Function
    func signOut() {
        do {
            try auth.signOut()
            self.userSession = nil
            self.currentUser = nil
            print("User signed out successfully.")
        } catch let signOutError as NSError {
            print("DEBUG: Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    // Fetch User Data Function
    func fetchUser() async {
        guard let uid = auth.currentUser?.uid else { return }
        
        do {
            print("Fetching user data for UID: \(uid)")
            let document = try await db.collection("users").document(uid).getDocument()
            if let user = try? document.data(as: AppUser.self) {
                self.currentUser = user
                print("User data fetched: \(user.fullname), \(user.email)")
            } else {
                print("DEBUG: User data does not exist.")
            }
        } catch {
            print("DEBUG: Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    // Delete Account Function
    func deleteAccount() async throws {
        guard let user = auth.currentUser else { return }
        
        do {
            print("Attempting to delete account for UID: \(user.uid)")
            // Delete user data from Firestore
            try await db.collection("users").document(user.uid).delete()
            // Delete user from Firebase Auth
            try await user.delete()
            self.userSession = nil
            self.currentUser = nil
            print("User account deleted successfully.")
        } catch {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
            throw error
        }
    }
}
