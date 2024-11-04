//
//  SettingsRowView.swift
//  FirebaseTest
//
//  Created by Taya Ambrose on 10/18/24.
//

// This file contains the struture for settings bars in
// the user profile page. This file is not displayed,
// it is referenced to keep code clean without
// duplicating the body.

// Please comment the changes you make and leave your name.

import SwiftUI

struct SettingsRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            Text(title)
                .font(.footnote)
                .accentColor(tintColor)
                
        }
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.blue.opacity(0.7)))
    } else {
        // Fallback on earlier versions
    }
}
