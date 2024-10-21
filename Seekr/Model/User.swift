//
//  User.swift
//  FirebaseTest
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains the inner workings of the user.

// Please comment any changes you make and your name.

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents (from: fullname) {
            formatter.style = .abbreviated
            return formatter.string (from: components)
        }
        
        return ""
    }
}

extension User {
    static var TEST_USER = User(id: NSUUID().uuidString, fullname: "Test User", email: "test@gmail.com")
}
