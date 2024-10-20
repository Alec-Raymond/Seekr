//
//  SeekrApp.swift
//  Seekr
//
//  Created by Alec Raymond on 10/3/24.
//

import SwiftUI
import Firebase

@main
struct SeekrApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(viewModel)
        }
    }
}
