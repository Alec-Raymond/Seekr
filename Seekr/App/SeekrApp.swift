//
//  SeekrApp.swift
//  Seekr
//
//  Created by Alec Raymond on 10/3/24.
//

import SwiftUI

@main
struct SeekrApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
